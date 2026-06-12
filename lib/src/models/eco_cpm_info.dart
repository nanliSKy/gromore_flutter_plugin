import 'deep_equality.dart';

/// 聚合竞价信息模型（Eco_Cpm_Info）。
///
/// 通过 `getEcoCpmInfo` 从原生层读取当前展示广告的竞价信息，包含 ADN 来源、
/// 价格、广告位等字段（Requirements 9.2、9.4、9.6）。
class EcoCpmInfo {
  /// 竞价获胜的 ADN 名称（如 baidu / gdt / ks / sigmob / pangle）。
  final String adnName;

  /// 竞价价格（eCPM），以字符串形式承载以避免精度问题。
  final String ecpm;

  /// 对应的广告位标识。
  final String slotId;

  /// 其他附加字段（如 level_tag、reqBiddingType 等）。
  ///
  /// 仅包含可被 `StandardMessageCodec` 编解码的基本类型；缺失字段以空映射表示。
  final Map<String, dynamic> extra;

  /// 创建一个 [EcoCpmInfo]。
  EcoCpmInfo({
    required this.adnName,
    required this.ecpm,
    required this.slotId,
    Map<String, dynamic>? extra,
  }) : extra = Map<String, dynamic>.unmodifiable(extra ?? const <String, dynamic>{});

  /// 序列化为映射结构（Requirements 9.2）。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'adnName': adnName,
      'ecpm': ecpm,
      'slotId': slotId,
      'extra': Map<String, dynamic>.from(extra),
    };
  }

  /// 从原生侧传来的映射反序列化为 [EcoCpmInfo]（Requirements 9.6）。
  ///
  /// 缺失的 `adnName` / `ecpm` / `slotId` 字段回退为空字符串；`extra` 缺失或类型
  /// 不符时回退为空映射。
  factory EcoCpmInfo.fromMap(Map<String, dynamic> map) {
    return EcoCpmInfo(
      adnName: (map['adnName'] as String?) ?? '',
      ecpm: (map['ecpm'] as String?) ?? '',
      slotId: (map['slotId'] as String?) ?? '',
      extra: _normalizeExtra(map['extra']),
    );
  }

  /// 将任意来源的 `extra` 值规范化为 `Map<String, dynamic>`。
  static Map<String, dynamic> _normalizeExtra(Object? raw) {
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
    return other is EcoCpmInfo &&
        other.adnName == adnName &&
        other.ecpm == ecpm &&
        other.slotId == slotId &&
        deepEquals(other.extra, extra);
  }

  @override
  int get hashCode => Object.hash(adnName, ecpm, slotId, deepHash(extra));

  @override
  String toString() => 'EcoCpmInfo(adnName: $adnName, ecpm: $ecpm, slotId: $slotId, extra: $extra)';
}
