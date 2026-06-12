/// 通道层强类型错误定义。
///
/// 原生层通过 `MethodChannel` 的 `error(code, message, details)` 返回错误，
/// Dart 侧据此抛出 [PlatformException]。本文件将这些字符串错误码
/// （见 `GromoreErrorCodes`）映射为强类型的 [GromoreErrorType] 枚举，并以
/// [GromoreException] 统一向上层 API 暴露，避免调用方直接处理字符串错误码
/// （Requirements 10.1）。
library;

import 'package:flutter/services.dart' show PlatformException;

import 'gromore_channels.dart';

/// GroMore 插件的强类型错误类别。
///
/// 每个枚举值与 [GromoreErrorCodes] 中的字符串错误码一一对应；无法识别的错误
/// 码归类为 [GromoreErrorType.unknown]，保证向前兼容（Requirements 10.1）。
enum GromoreErrorType {
  /// 参数校验失败（如缺少 appId、slotId 长度非法等）。
  invalidArgument,

  /// SDK 未初始化即调用广告接口。
  notInitialized,

  /// 实例尚未加载完成即展示（Requirements 4.7）。
  adNotReady,

  /// adId 不在注册表中（已销毁或从未创建，Requirements 10.6、10.7）。
  adNotFound,

  /// 竞价信息不可用（实例不存在或未展示，Requirements 9.3）。
  ecpmUnavailable,

  /// SDK 初始化/启动失败（Requirements 1.3）。
  sdkInitFailed,

  /// 未能识别的错误码（向前兼容兜底）。
  unknown,
}

/// 将字符串错误码（[GromoreErrorCodes]）映射为强类型 [GromoreErrorType]。
extension GromoreErrorTypeMapping on GromoreErrorType {
  /// 该错误类型对应的字符串错误码。
  ///
  /// [GromoreErrorType.unknown] 没有对应的稳定字符串码，返回 `'unknown'`。
  String get code {
    switch (this) {
      case GromoreErrorType.invalidArgument:
        return GromoreErrorCodes.invalidArgument;
      case GromoreErrorType.notInitialized:
        return GromoreErrorCodes.notInitialized;
      case GromoreErrorType.adNotReady:
        return GromoreErrorCodes.adNotReady;
      case GromoreErrorType.adNotFound:
        return GromoreErrorCodes.adNotFound;
      case GromoreErrorType.ecpmUnavailable:
        return GromoreErrorCodes.ecpmUnavailable;
      case GromoreErrorType.sdkInitFailed:
        return GromoreErrorCodes.sdkInitFailed;
      case GromoreErrorType.unknown:
        return 'unknown';
    }
  }

  /// 从字符串错误码解析为强类型 [GromoreErrorType]。
  ///
  /// 未知或为 `null` 的错误码返回 [GromoreErrorType.unknown]。
  static GromoreErrorType fromCode(String? code) {
    switch (code) {
      case GromoreErrorCodes.invalidArgument:
        return GromoreErrorType.invalidArgument;
      case GromoreErrorCodes.notInitialized:
        return GromoreErrorType.notInitialized;
      case GromoreErrorCodes.adNotReady:
        return GromoreErrorType.adNotReady;
      case GromoreErrorCodes.adNotFound:
        return GromoreErrorType.adNotFound;
      case GromoreErrorCodes.ecpmUnavailable:
        return GromoreErrorType.ecpmUnavailable;
      case GromoreErrorCodes.sdkInitFailed:
        return GromoreErrorType.sdkInitFailed;
      default:
        return GromoreErrorType.unknown;
    }
  }
}

/// GroMore 插件向上层 API 抛出的强类型异常。
///
/// 由通道层捕获原生返回的 [PlatformException] 后转换而来，承载强类型的
/// [type]、原始字符串 [code]、可读 [message] 与可选 [details]，使调用方可以基于
/// 枚举进行分支处理而非匹配字符串（Requirements 10.1、10.6、10.7）。
class GromoreException implements Exception {
  /// 创建一个 [GromoreException]。
  const GromoreException(
    this.type, {
    required this.code,
    this.message,
    this.details,
  });

  /// 强类型错误类别。
  final GromoreErrorType type;

  /// 原生返回的原始字符串错误码（保留以便日志与排查）。
  final String code;

  /// 可读错误信息。
  final String? message;

  /// 原生附带的额外细节（如原生错误码、堆栈信息等）。
  final Object? details;

  /// 由 [PlatformException] 构造 [GromoreException]，完成错误码映射。
  factory GromoreException.fromPlatformException(PlatformException exception) {
    return GromoreException(
      GromoreErrorTypeMapping.fromCode(exception.code),
      code: exception.code,
      message: exception.message,
      details: exception.details,
    );
  }

  @override
  String toString() {
    return 'GromoreException(type: $type, code: $code, message: $message, '
        'details: $details)';
  }
}
