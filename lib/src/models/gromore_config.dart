import 'privacy_config.dart';

/// GroMore SDK 初始化配置模型。
///
/// 对应需求 1（SDK 初始化与启动）与需求 2（隐私合规配置）。该模型承载初始化
/// 所需的应用标识、聚合开关、调试开关以及可选的隐私合规配置，并通过
/// MethodChannel 的 `init` 方法传递给 Native_Layer。
///
/// 字段语义：
/// - [appId]：媒体在穿山甲平台申请的 App_Id（Requirements 1.1）。Dart 顶层
///   API 在调用通道前对其做长度校验（任务 4.1），本模型仅负责承载与序列化。
/// - [useMediation]：是否启用 GroMore 聚合功能，默认 `true`
///   （Android `useMediation(true)` / iOS `useMediation = YES`，Requirements 1.1）。
/// - [debug]：调试模式开关，透传给 SDK 调试配置项（Requirements 1.7）。
/// - [privacy]：可空的隐私合规配置；为 `null` 时由 Native_Layer 使用 SDK 默认
///   隐私配置完成初始化（Requirements 2.4、2.5）。
///
/// 序列化约束：[toMap] 与 [fromMap] 互为逆操作，仅使用可被
/// `StandardMessageCodec` 编解码的基本类型。嵌套的 [privacy] 在 [toMap] 中序列化
/// 为嵌套的 `Map`，并在 [fromMap] 中按相同结构读回，保证嵌套往返一致
/// （设计文档 Property 2）。
class GromoreConfig {
  /// 创建一个初始化配置。
  const GromoreConfig({
    required this.appId,
    this.useMediation = true,
    this.debug = false,
    this.privacy,
  });

  /// 媒体应用 ID（Requirements 1.1）。
  final String appId;

  /// 是否启用 GroMore 聚合功能，默认 `true`（Requirements 1.1）。
  final bool useMediation;

  /// 调试模式开关，透传给 SDK（Requirements 1.7）。
  final bool debug;

  /// 可选隐私合规配置；为 `null` 时使用 SDK 默认隐私配置（Requirements 2.4、2.5）。
  final PrivacyConfig? privacy;

  /// 序列化为可经由通道传递的键值映射。
  ///
  /// 当 [privacy] 为 `null` 时，`privacy` 键的值为 `null`，从而在 [fromMap] 中
  /// 还原为 `null`，保持往返一致。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appId': appId,
      'useMediation': useMediation,
      'debug': debug,
      'privacy': privacy?.toMap(),
    };
  }

  /// 从键值映射反序列化为 [GromoreConfig]，与 [toMap] 互为逆操作。
  ///
  /// 缺失或类型不匹配的字段回退到默认值；嵌套的 `privacy` 映射按
  /// [PrivacyConfig.fromMap] 还原，缺失时为 `null`。
  factory GromoreConfig.fromMap(Map<String, dynamic> map) {
    final Object? rawPrivacy = map['privacy'];
    PrivacyConfig? privacy;
    if (rawPrivacy is Map) {
      privacy = PrivacyConfig.fromMap(Map<String, dynamic>.from(rawPrivacy));
    }
    final Object? rawAppId = map['appId'];
    return GromoreConfig(
      appId: rawAppId is String ? rawAppId : '',
      useMediation: map['useMediation'] is bool ? map['useMediation'] as bool : true,
      debug: map['debug'] is bool ? map['debug'] as bool : false,
      privacy: privacy,
    );
  }

  /// 返回一个替换了部分字段的副本。
  GromoreConfig copyWith({
    String? appId,
    bool? useMediation,
    bool? debug,
    PrivacyConfig? privacy,
  }) {
    return GromoreConfig(
      appId: appId ?? this.appId,
      useMediation: useMediation ?? this.useMediation,
      debug: debug ?? this.debug,
      privacy: privacy ?? this.privacy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GromoreConfig &&
        other.appId == appId &&
        other.useMediation == useMediation &&
        other.debug == debug &&
        other.privacy == privacy;
  }

  @override
  int get hashCode => Object.hash(appId, useMediation, debug, privacy);

  @override
  String toString() {
    return 'GromoreConfig(appId: $appId, useMediation: $useMediation, '
        'debug: $debug, privacy: $privacy)';
  }
}
