/// 各广告类型的加载请求参数模型。
///
/// 这些模型作为 `loadXxxAd` 方法的入参，序列化为 MethodChannel 的 `arguments`
/// 映射传递给原生层（Requirements 3.1、4.1、5.1）。可空字段在序列化时被省略，
/// 由原生层使用默认值。
library;

import 'deep_equality.dart';

/// 将任意来源的 `extra` 值规范化为 `Map<String, dynamic>`。
Map<String, dynamic>? _normalizeExtra(Object? raw) {
  if (raw is Map) {
    return raw.map(
      (Object? key, Object? value) => MapEntry<String, dynamic>('$key', value),
    );
  }
  return null;
}

/// 开屏广告加载请求参数（Requirements 3.1）。
class SplashAdRequest {
  /// 开屏广告位标识（必填）。
  final String slotId;

  /// 加载超时（毫秒），可空，缺省由原生层使用默认超时。
  final int? timeoutMs;

  /// 其他扩展参数，可空。
  final Map<String, dynamic>? extra;

  /// 创建一个 [SplashAdRequest]。
  const SplashAdRequest({
    required this.slotId,
    this.timeoutMs,
    this.extra,
  });

  /// 序列化为 MethodChannel 参数映射；可空字段为 null 时省略。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'slotId': slotId,
      if (timeoutMs != null) 'timeoutMs': timeoutMs,
      if (extra != null) 'extra': Map<String, dynamic>.from(extra!),
    };
  }

  /// 从映射反序列化为 [SplashAdRequest]。
  factory SplashAdRequest.fromMap(Map<String, dynamic> map) {
    return SplashAdRequest(
      slotId: (map['slotId'] as String?) ?? '',
      timeoutMs: map['timeoutMs'] as int?,
      extra: _normalizeExtra(map['extra']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SplashAdRequest &&
        other.slotId == slotId &&
        other.timeoutMs == timeoutMs &&
        deepEquals(other.extra, extra);
  }

  @override
  int get hashCode => Object.hash(slotId, timeoutMs, deepHash(extra));
}

/// 激励视频广告加载请求参数（Requirements 4.1）。
class RewardAdRequest {
  /// 激励视频广告位标识（必填）。
  final String slotId;

  /// 服务端校验用户标识，可空。
  final String? userId;

  /// 奖励名称，可空。
  final String? rewardName;

  /// 奖励数量，可空。
  final int? rewardAmount;

  /// 其他扩展参数，可空。
  final Map<String, dynamic>? extra;

  /// 创建一个 [RewardAdRequest]。
  const RewardAdRequest({
    required this.slotId,
    this.userId,
    this.rewardName,
    this.rewardAmount,
    this.extra,
  });

  /// 序列化为 MethodChannel 参数映射；可空字段为 null 时省略。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'slotId': slotId,
      if (userId != null) 'userId': userId,
      if (rewardName != null) 'rewardName': rewardName,
      if (rewardAmount != null) 'rewardAmount': rewardAmount,
      if (extra != null) 'extra': Map<String, dynamic>.from(extra!),
    };
  }

  /// 从映射反序列化为 [RewardAdRequest]。
  factory RewardAdRequest.fromMap(Map<String, dynamic> map) {
    return RewardAdRequest(
      slotId: (map['slotId'] as String?) ?? '',
      userId: map['userId'] as String?,
      rewardName: map['rewardName'] as String?,
      rewardAmount: map['rewardAmount'] as int?,
      extra: _normalizeExtra(map['extra']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RewardAdRequest &&
        other.slotId == slotId &&
        other.userId == userId &&
        other.rewardName == rewardName &&
        other.rewardAmount == rewardAmount &&
        deepEquals(other.extra, extra);
  }

  @override
  int get hashCode => Object.hash(slotId, userId, rewardName, rewardAmount, deepHash(extra));
}

/// 插全屏广告加载请求参数（Requirements 5.1）。
class InterstitialAdRequest {
  /// 插全屏广告位标识（必填）。
  final String slotId;

  /// 其他扩展参数，可空。
  final Map<String, dynamic>? extra;

  /// 创建一个 [InterstitialAdRequest]。
  const InterstitialAdRequest({
    required this.slotId,
    this.extra,
  });

  /// 序列化为 MethodChannel 参数映射；可空字段为 null 时省略。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'slotId': slotId,
      if (extra != null) 'extra': Map<String, dynamic>.from(extra!),
    };
  }

  /// 从映射反序列化为 [InterstitialAdRequest]。
  factory InterstitialAdRequest.fromMap(Map<String, dynamic> map) {
    return InterstitialAdRequest(
      slotId: (map['slotId'] as String?) ?? '',
      extra: _normalizeExtra(map['extra']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InterstitialAdRequest && other.slotId == slotId && deepEquals(other.extra, extra);
  }

  @override
  int get hashCode => Object.hash(slotId, deepHash(extra));
}
