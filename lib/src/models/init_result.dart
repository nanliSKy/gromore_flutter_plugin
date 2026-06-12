/// SDK 初始化与启动结果模型。
///
/// 对应需求 1（SDK 初始化与启动）。该模型由 Native_Layer 经 MethodChannel 的
/// `init` 方法返回，向 Dart_API 报告初始化是否成功、是否已初始化以及失败时的
/// 错误信息。
///
/// 字段语义：
/// - [success]：是否初始化成功（Requirements 1.2、1.3）。
/// - [errorCode]：可空错误码，失败时携带（Requirements 1.3）。
/// - [errorMessage]：可空错误信息，失败时携带（Requirements 1.3）。
/// - [alreadyInitialized]：是否为重复初始化（已就绪后再次调用 init，
///   Requirements 1.5）。此时 [success] 为 `true` 且不重复执行底层初始化。
///
/// 序列化约束：[toMap] 与 [fromMap] 互为逆操作，仅使用可被
/// `StandardMessageCodec` 编解码的基本类型（`bool`、可空 `int`、可空 `String`），
/// 保证往返序列化一致（设计文档 Property 2）。
class InitResult {
  /// 创建一个初始化结果。
  const InitResult({
    required this.success,
    this.errorCode,
    this.errorMessage,
    this.alreadyInitialized = false,
  });

  /// 初始化成功的便捷构造。
  const InitResult.success({bool alreadyInitialized = false})
      : this(success: true, alreadyInitialized: alreadyInitialized);

  /// 初始化失败的便捷构造，携带错误码与错误信息。
  const InitResult.failure({int? errorCode, String? errorMessage})
      : this(
          success: false,
          errorCode: errorCode,
          errorMessage: errorMessage,
        );

  /// 已初始化（幂等）结果的便捷构造（Requirements 1.5）。
  const InitResult.alreadyInitialized() : this(success: true, alreadyInitialized: true);

  /// 是否初始化成功（Requirements 1.2、1.3）。
  final bool success;

  /// 失败时的错误码，成功时为 `null`（Requirements 1.3）。
  final int? errorCode;

  /// 失败时的错误信息，成功时为 `null`（Requirements 1.3）。
  final String? errorMessage;

  /// 是否为重复初始化（Requirements 1.5）。
  final bool alreadyInitialized;

  /// 序列化为可经由通道传递的键值映射。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'alreadyInitialized': alreadyInitialized,
    };
  }

  /// 从键值映射反序列化为 [InitResult]，与 [toMap] 互为逆操作。
  ///
  /// 缺失或类型不匹配的字段回退到安全默认值。
  factory InitResult.fromMap(Map<String, dynamic> map) {
    return InitResult(
      success: map['success'] is bool ? map['success'] as bool : false,
      errorCode: map['errorCode'] is int ? map['errorCode'] as int : null,
      errorMessage: map['errorMessage'] is String ? map['errorMessage'] as String : null,
      alreadyInitialized: map['alreadyInitialized'] is bool ? map['alreadyInitialized'] as bool : false,
    );
  }

  /// 返回一个替换了部分字段的副本。
  ///
  /// 由于 [errorCode] 与 [errorMessage] 可空，使用哨兵参数以支持显式置空。
  InitResult copyWith({
    bool? success,
    Object? errorCode = _sentinel,
    Object? errorMessage = _sentinel,
    bool? alreadyInitialized,
  }) {
    return InitResult(
      success: success ?? this.success,
      errorCode: identical(errorCode, _sentinel) ? this.errorCode : errorCode as int?,
      errorMessage: identical(errorMessage, _sentinel) ? this.errorMessage : errorMessage as String?,
      alreadyInitialized: alreadyInitialized ?? this.alreadyInitialized,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InitResult &&
        other.success == success &&
        other.errorCode == errorCode &&
        other.errorMessage == errorMessage &&
        other.alreadyInitialized == alreadyInitialized;
  }

  @override
  int get hashCode => Object.hash(success, errorCode, errorMessage, alreadyInitialized);

  @override
  String toString() {
    return 'InitResult(success: $success, errorCode: $errorCode, '
        'errorMessage: $errorMessage, alreadyInitialized: $alreadyInitialized)';
  }
}

/// 用于 [InitResult.copyWith] 区分"未传参"与"显式传 null"的哨兵值。
const Object _sentinel = Object();
