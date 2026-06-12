/// 隐私合规配置模型。
///
/// 对应需求 2（隐私合规配置）。该模型把媒体应用对设备标识符采集行为与个性化
/// 推荐的控制意图，映射为 Native_Layer 的隐私控制对象（Android 端
/// `TTCustomController`、iOS 端 `privacyProvider`）所需的开关集合。
///
/// 字段语义（Requirements 2.3、2.4）：
/// - [limitPersonalAds]：限制个性化广告开关。`true` 表示关闭个性化推荐，
///   `false` 表示开启个性化推荐（Requirements 2.3）。
/// - 其余 5 项为设备标识符 / 状态采集开关，`true` 表示允许采集，`false` 表示
///   禁止采集（Requirements 2.4）。
///
/// 序列化约束：[toMap] 与 [fromMap] 互为逆操作，仅使用可被
/// `StandardMessageCodec` 编解码的基本类型（此处全部为 `bool`），以保证往返
/// 序列化一致性（Requirements 2.1，设计文档 Property 2）。
class PrivacyConfig {
  /// 创建一个隐私合规配置。
  ///
  /// 所有开关均为必填，调用方应显式表达每一项的采集意图。未提供整个
  /// [PrivacyConfig] 时由上层使用 SDK 默认隐私配置（Requirements 2.5）。
  const PrivacyConfig({
    this.limitPersonalAds = false,
    this.canUseOaid = true,
    this.canUseMacAddress = true,
    this.canUseAndroidId = true,
    this.canUseWifiState = true,
    this.canUseLocation = true,
  });

  /// 限制个性化广告。`true` 关闭个性化推荐，`false` 开启（Requirements 2.3）。
  final bool limitPersonalAds;

  /// 是否允许采集 OAID（Requirements 2.4）。
  final bool canUseOaid;

  /// 是否允许采集 MAC 地址（Requirements 2.4）。
  final bool canUseMacAddress;

  /// 是否允许采集 AndroidID（Requirements 2.4）。
  final bool canUseAndroidId;

  /// 是否允许读取 WiFi 状态（Requirements 2.4）。
  final bool canUseWifiState;

  /// 是否允许采集位置信息（Requirements 2.4）。
  final bool canUseLocation;

  /// 序列化为可经由通道传递的键值映射（Requirements 2.1）。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'limitPersonalAds': limitPersonalAds,
      'canUseOaid': canUseOaid,
      'canUseMacAddress': canUseMacAddress,
      'canUseAndroidId': canUseAndroidId,
      'canUseWifiState': canUseWifiState,
      'canUseLocation': canUseLocation,
    };
  }

  /// 从键值映射反序列化为 [PrivacyConfig]，与 [toMap] 互为逆操作。
  ///
  /// 缺失或类型不匹配的字段回退到构造函数默认值（Requirements 2.5）。
  factory PrivacyConfig.fromMap(Map<String, dynamic> map) {
    return PrivacyConfig(
      limitPersonalAds: _asBool(map['limitPersonalAds'], false),
      canUseOaid: _asBool(map['canUseOaid'], true),
      canUseMacAddress: _asBool(map['canUseMacAddress'], true),
      canUseAndroidId: _asBool(map['canUseAndroidId'], true),
      canUseWifiState: _asBool(map['canUseWifiState'], true),
      canUseLocation: _asBool(map['canUseLocation'], true),
    );
  }

  /// 返回一个替换了部分字段的副本。
  PrivacyConfig copyWith({
    bool? limitPersonalAds,
    bool? canUseOaid,
    bool? canUseMacAddress,
    bool? canUseAndroidId,
    bool? canUseWifiState,
    bool? canUseLocation,
  }) {
    return PrivacyConfig(
      limitPersonalAds: limitPersonalAds ?? this.limitPersonalAds,
      canUseOaid: canUseOaid ?? this.canUseOaid,
      canUseMacAddress: canUseMacAddress ?? this.canUseMacAddress,
      canUseAndroidId: canUseAndroidId ?? this.canUseAndroidId,
      canUseWifiState: canUseWifiState ?? this.canUseWifiState,
      canUseLocation: canUseLocation ?? this.canUseLocation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrivacyConfig &&
        other.limitPersonalAds == limitPersonalAds &&
        other.canUseOaid == canUseOaid &&
        other.canUseMacAddress == canUseMacAddress &&
        other.canUseAndroidId == canUseAndroidId &&
        other.canUseWifiState == canUseWifiState &&
        other.canUseLocation == canUseLocation;
  }

  @override
  int get hashCode {
    return Object.hash(
      limitPersonalAds,
      canUseOaid,
      canUseMacAddress,
      canUseAndroidId,
      canUseWifiState,
      canUseLocation,
    );
  }

  @override
  String toString() {
    return 'PrivacyConfig(limitPersonalAds: $limitPersonalAds, '
        'canUseOaid: $canUseOaid, canUseMacAddress: $canUseMacAddress, '
        'canUseAndroidId: $canUseAndroidId, canUseWifiState: $canUseWifiState, '
        'canUseLocation: $canUseLocation)';
  }
}

/// 将任意值安全地解释为 `bool`，无法识别时返回 [fallback]。
bool _asBool(Object? value, bool fallback) {
  if (value is bool) return value;
  return fallback;
}
