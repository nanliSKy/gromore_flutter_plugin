/// 用于数据模型值语义相等判断的深度相等与深度哈希工具。
///
/// 广告事件与竞价信息携带的 `data` / `extra` 映射可能包含可被
/// `StandardMessageCodec` 编解码的嵌套结构（`Map`、`List`、`String`、`bool`、
/// `int`、`double`、`null`）。经由通道往返序列化后，嵌套集合会成为全新的实例，
/// 因此必须使用深度相等来断言往返一致性（Requirements 8.5）。
library;

/// 深度比较两个值是否相等。
///
/// 对 `Map` 与 `List` 递归比较元素；其余基本类型使用 `==` 比较。
bool deepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final Object? key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (!deepEquals(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

/// 计算与 [deepEquals] 一致的深度哈希值。
///
/// `Map` 的哈希与键值对顺序无关（使用异或合并）；`List` 的哈希与元素顺序相关。
int deepHash(Object? value) {
  if (value is Map) {
    int hash = 0;
    value.forEach((Object? key, Object? v) {
      hash ^= Object.hash(deepHash(key), deepHash(v));
    });
    return hash;
  }
  if (value is List) {
    return Object.hashAll(value.map(deepHash));
  }
  return value.hashCode;
}
