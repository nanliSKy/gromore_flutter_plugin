/// 信息流/原生广告 PlatformView 包装组件（Requirements 7.1、7.2、7.4、7.7）。
///
/// [FeedAdView] 是一个 [StatefulWidget]，在 Android 上通过 [AndroidView]、在 iOS
/// 上通过 [UiKitView] 嵌入原生信息流广告视图。视图创建参数携带 `adId`、`slotId`
/// 与展示尺寸（Requirements 7.1）。
///
/// 参数校验策略（Requirements 7.2）：在 Dart 侧校验 feed slotId 长度 1–64、尺寸
/// 1–4096 像素。校验失败时不创建 PlatformView，通过 [onAdEvent] 回调携带
/// `invalid_argument` 的参数校验失败事件并渲染空占位。
///
/// dislike（Requirements 7.4）：通过 [FeedAdController.dislike] 触发，经
/// MethodChannel 调用原生 `feedDislike(adId)`。
///
/// 资源释放（Requirements 7.7）：视图 `dispose` 时调用 [GromoreMethodChannel.destroyAd]。
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../channel/gromore_channels.dart';
import '../channel/gromore_method_channel.dart';
import '../models/models.dart';
import 'ad_view_support.dart';

/// 控制单个 [FeedAdView] 的命令式句柄。
///
/// 主要用于触发 dislike（不感兴趣）操作（Requirements 7.4）。控制器在其绑定的
/// [FeedAdView] 完成 PlatformView 创建后被「附着」（attach）到对应的 `adId`；
/// 在视图 `dispose` 时被「分离」（detach）。未附着或参数校验失败时调用
/// [dislike] 不会触达原生层。
class FeedAdController {
  /// 创建一个 [FeedAdController]。
  ///
  /// [methodChannel] 可注入用于测试；缺省时使用默认 [GromoreMethodChannel]。
  FeedAdController({GromoreMethodChannel? methodChannel}) : _methodChannel = methodChannel ?? GromoreMethodChannel();

  final GromoreMethodChannel _methodChannel;

  String? _adId;

  /// 当前控制器是否已绑定到一个有效的广告实例。
  bool get isAttached => _adId != null;

  /// 绑定到的广告实例 `adId`（未附着时为 `null`）。
  String? get adId => _adId;

  /// 由 [FeedAdView] 在创建 PlatformView 后调用，绑定控制器到该实例。
  void _attach(String adId) {
    _adId = adId;
  }

  /// 由 [FeedAdView] 在 `dispose` 时调用，解除绑定。
  void _detach() {
    _adId = null;
  }

  /// 对当前 Feed 广告执行 dislike（不感兴趣）操作（Requirements 7.4）。
  ///
  /// 通过 MethodChannel 调用原生 `feedDislike(adId)`。未附着到有效实例时为安全
  /// 空操作（返回已完成的 [Future]）。
  Future<void> dislike() {
    final String? adId = _adId;
    if (adId == null) {
      return Future<void>.value();
    }
    return _methodChannel.feedDislike(adId);
  }
}

/// 在内容流中嵌入 GroMore 信息流/原生广告的组件。
class FeedAdView extends StatefulWidget {
  /// 创建一个 [FeedAdView]。
  ///
  /// [methodChannel] 可注入用于测试；缺省时使用默认 [GromoreMethodChannel]。
  const FeedAdView({
    super.key,
    required this.slotId,
    required this.width,
    required this.height,
    this.onAdEvent,
    this.controller,
    GromoreMethodChannel? methodChannel,
  }) : _methodChannel = methodChannel;

  /// 信息流聚合广告位标识（长度须为 1–64 个字符）。
  final String slotId;

  /// 期望的展示宽度（逻辑像素，须在 1–4096 范围内）。
  final double width;

  /// 期望的展示高度（逻辑像素，须在 1–4096 范围内）。
  final double height;

  /// 广告事件回调（展示、点击、渲染成功/失败、移除，以及参数校验失败）。
  final void Function(AdEvent event)? onAdEvent;

  /// 可选的命令式控制器，用于触发 dislike 操作（Requirements 7.4）。
  final FeedAdController? controller;

  final GromoreMethodChannel? _methodChannel;

  @override
  State<FeedAdView> createState() => _FeedAdViewState();
}

class _FeedAdViewState extends State<FeedAdView> {
  late final GromoreMethodChannel _methodChannel;

  /// 本视图实例的唯一 adId；仅在参数校验通过、创建 PlatformView 时分配。
  String? _adId;

  /// Dart 侧参数校验失败信息；非空表示不创建 PlatformView。
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _methodChannel = widget._methodChannel ?? GromoreMethodChannel();

    final String? error = validateFeedParams(
      slotId: widget.slotId,
      width: widget.width,
      height: widget.height,
    );

    if (error != null) {
      _validationError = error;
      final String adId = AdViewIdGenerator.next(GromoreAdTypes.feed);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAdEvent?.call(
          buildInvalidParamsEvent(
            adId: adId,
            adType: GromoreAdTypes.feed,
            message: error,
          ),
        );
      });
      return;
    }

    final String adId = AdViewIdGenerator.next(GromoreAdTypes.feed);
    _adId = adId;
    widget.controller?._attach(adId);
  }

  @override
  void dispose() {
    // 解除控制器绑定并释放原生资源（Requirements 7.7）。
    widget.controller?._detach();
    final String? adId = _adId;
    if (adId != null) {
      _methodChannel.destroyAd(adId).catchError((Object _) {});
    }
    super.dispose();
  }

  Map<String, dynamic> _creationParams(String adId) {
    return <String, dynamic>{
      'adId': adId,
      'slotId': widget.slotId,
      'width': widget.width,
      'height': widget.height,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_validationError != null || _adId == null) {
      return const SizedBox.shrink();
    }

    final String adId = _adId!;
    final Map<String, dynamic> params = _creationParams(adId);

    Widget platformView;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        platformView = AndroidView(
          viewType: GromoreViewTypes.feed,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
        break;
      case TargetPlatform.iOS:
        platformView = UiKitView(
          viewType: GromoreViewTypes.feed,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
        break;
      default:
        return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: platformView,
    );
  }
}
