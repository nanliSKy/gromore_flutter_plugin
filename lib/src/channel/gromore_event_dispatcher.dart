/// 事件流分发器：监听 EventChannel 并按 adId 路由广告事件。
///
/// 原生侧通过 [GromoreChannels.eventChannelName] 推送扁平映射结构
/// `{eventType, adId, adType, data}`。本分发器负责：
///
/// - 将每条原生事件映射反序列化为 [AdEvent]（[AdEvent.fromMap]）；
/// - 暴露全量事件流 [events] 与按 adId 过滤的子流 [eventsForAd]；
/// - 丢弃缺少 `eventType` 或 `adId` 的事件（Requirements 8.6）；
/// - 反序列化失败（payload 非映射，或 `eventType` 不在
///   [GromoreEventTypes.all] 中）时向订阅者发出错误通知，且不中断后续事件
///   （Requirements 8.7）；
/// - 通过按 adId 过滤天然保证：无订阅者的 adId 事件不会投递给任何子流
///   （Requirements 8.8）。
library;

import 'dart:async';

import 'package:flutter/services.dart';

import '../models/models.dart';
import 'gromore_channels.dart';

/// 表示一条原生事件无法被反序列化为已知 [AdEvent] 的错误通知。
///
/// 通过 [events] / [eventsForAd] 子流以错误事件（`addError`）的形式投递给订阅者，
/// 不会中断流本身，后续合法事件仍可正常接收（Requirements 8.7）。
class GromoreEventDeserializationException implements Exception {
  /// 创建一个反序列化失败通知。
  GromoreEventDeserializationException(this.payload, this.reason);

  /// 触发失败的原始 payload（来自原生侧的未处理数据）。
  final Object? payload;

  /// 失败原因的可读描述。
  final String reason;

  @override
  String toString() => 'GromoreEventDeserializationException(reason: $reason, payload: $payload)';
}

/// EventChannel 事件流分发器。
///
/// 默认监听插件的 EventChannel；为便于单元 / 属性测试，可通过
/// [GromoreEventDispatcher.fromStream] 注入任意 `Stream<dynamic>` 作为事件源，
/// 从而在无真实平台通道的情况下喂入合成事件。
class GromoreEventDispatcher {
  /// 使用插件默认 EventChannel（[GromoreChannels.eventChannelName]）创建分发器。
  factory GromoreEventDispatcher() {
    const EventChannel channel = EventChannel(GromoreChannels.eventChannelName);
    return GromoreEventDispatcher.fromStream(channel.receiveBroadcastStream());
  }

  /// 使用注入的事件源创建分发器。
  ///
  /// [source] 通常是 `EventChannel.receiveBroadcastStream()`，但在测试中可以是
  /// 任意广播或单订阅流，用于喂入合成的原生事件映射。
  GromoreEventDispatcher.fromStream(Stream<dynamic> source) : _source = source {
    _controller = StreamController<AdEvent>.broadcast(
      onListen: _subscribeToSource,
      onCancel: _maybeUnsubscribeFromSource,
    );
  }

  final Stream<dynamic> _source;
  late final StreamController<AdEvent> _controller;
  StreamSubscription<dynamic>? _sourceSubscription;
  bool _disposed = false;

  /// 全量广告事件流（所有 adId 的合法事件）。
  ///
  /// 该流为广播流，支持多个独立订阅者；反序列化失败会以错误事件投递。
  Stream<AdEvent> get events => _controller.stream;

  /// 按 [adId] 过滤的事件子流（Requirements 8.4）。
  ///
  /// 仅投递 `adId` 与入参相等的合法事件。由于过滤天然只面向已订阅该 adId 的
  /// 订阅者，未被任何子流订阅的 adId 事件不会被投递（Requirements 8.8）。
  Stream<AdEvent> eventsForAd(String adId) => _controller.stream.where((AdEvent event) => event.adId == adId);

  /// 在首个订阅者出现时开始监听底层事件源。
  void _subscribeToSource() {
    if (_disposed || _sourceSubscription != null) {
      return;
    }
    _sourceSubscription = _source.listen(
      _handleRawEvent,
      onError: _handleSourceError,
    );
  }

  /// 在最后一个订阅者取消时停止监听底层事件源。
  void _maybeUnsubscribeFromSource() {
    if (_controller.hasListener) {
      return;
    }
    _sourceSubscription?.cancel();
    _sourceSubscription = null;
  }

  /// 处理一条来自事件源的原始事件。
  void _handleRawEvent(dynamic raw) {
    if (_controller.isClosed) {
      return;
    }

    // 反序列化失败：payload 非映射结构（Requirements 8.7）。
    if (raw is! Map) {
      _emitDeserializationError(raw, 'payload 不是映射结构');
      return;
    }

    final Map<String, dynamic> map = raw.map(
      (Object? key, Object? value) => MapEntry<String, dynamic>('$key', value),
    );
    final AdEvent event = AdEvent.fromMap(map);

    // 丢弃缺少 eventType 或 adId 的事件（Requirements 8.6）。
    // AdEvent.fromMap 在字段缺失或类型不符时回退为空字符串。
    if (event.eventType.isEmpty || event.adId.isEmpty) {
      return;
    }

    // 反序列化失败：eventType 不属于已知事件类型集合（Requirements 8.7）。
    if (!GromoreEventTypes.all.contains(event.eventType)) {
      _emitDeserializationError(
        raw,
        '未知的 eventType: "${event.eventType}"',
      );
      return;
    }

    _controller.add(event);
  }

  /// 透传底层事件源自身的错误（例如平台通道异常），不中断流。
  void _handleSourceError(Object error, StackTrace stackTrace) {
    if (_controller.isClosed) {
      return;
    }
    _controller.addError(error, stackTrace);
  }

  /// 向订阅者发出反序列化失败的错误通知（Requirements 8.7）。
  void _emitDeserializationError(Object? payload, String reason) {
    if (_controller.isClosed) {
      return;
    }
    _controller.addError(
      GromoreEventDeserializationException(payload, reason),
    );
  }

  /// 释放分发器持有的资源：取消事件源订阅并关闭内部控制器。
  ///
  /// 释放后该实例不应再被使用。
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await _sourceSubscription?.cancel();
    _sourceSubscription = null;
    await _controller.close();
  }
}
