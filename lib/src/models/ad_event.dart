import 'deep_equality.dart';

/// 广告生命周期事件模型。
///
/// 所有广告实例产生的事件通过 EventChannel 以扁平映射结构
/// `{eventType, adId, adType, data}` 传递。Dart 侧将其反序列化为 [AdEvent]，
/// 保证与原生侧契约一致并支持往返序列化一致性（Requirements 8.2、8.3、8.5）。
class AdEvent {
  /// 事件类型，取自 [GromoreEventTypes] 的字符串常量集合。
  final String eventType;

  /// 产生该事件的广告实例唯一标识。
  final String adId;

  /// 广告类型（splash / reward / interstitial / banner / feed）。
  final String adType;

  /// 事件附加数据（如加载失败的 errorCode / errorMessage、奖励信息等）。
  ///
  /// 仅包含可被 `StandardMessageCodec` 编解码的基本类型。
  final Map<String, dynamic> data;

  /// 创建一个 [AdEvent]。
  ///
  /// [data] 为可空入参，缺省时使用空映射，便于上层无需判空。
  AdEvent({
    required this.eventType,
    required this.adId,
    required this.adType,
    Map<String, dynamic>? data,
  }) : data = Map<String, dynamic>.unmodifiable(data ?? const <String, dynamic>{});

  /// 序列化为可通过通道传输的映射结构（Requirements 8.3）。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'eventType': eventType,
      'adId': adId,
      'adType': adType,
      'data': Map<String, dynamic>.from(data),
    };
  }

  /// 从原生侧传来的映射反序列化为 [AdEvent]（Requirements 8.3、8.5）。
  ///
  /// `eventType`、`adId`、`adType` 缺失时回退为空字符串；`data` 字段会被规范化为
  /// `Map<String, dynamic>`，缺失或类型不符时回退为空映射。
  factory AdEvent.fromMap(Map<String, dynamic> map) {
    return AdEvent(
      eventType: (map['eventType'] as String?) ?? '',
      adId: (map['adId'] as String?) ?? '',
      adType: (map['adType'] as String?) ?? '',
      data: _normalizeData(map['data']),
    );
  }

  /// 将任意来源的 `data` 值规范化为 `Map<String, dynamic>`。
  ///
  /// 通道反序列化可能产生 `Map<Object?, Object?>`，此处统一转换以保证往返一致。
  static Map<String, dynamic> _normalizeData(Object? raw) {
    if (raw is Map) {
      return raw.map(
        (Object? key, Object? value) => MapEntry<String, dynamic>('$key', value),
      );
    }
    return <String, dynamic>{};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdEvent &&
        other.eventType == eventType &&
        other.adId == adId &&
        other.adType == adType &&
        deepEquals(other.data, data);
  }

  @override
  int get hashCode => Object.hash(eventType, adId, adType, deepHash(data));

  @override
  String toString() => 'AdEvent(eventType: $eventType, adId: $adId, adType: $adType, data: $data)';
}
