/// MethodChannel 封装。
///
/// 本类是 Dart 侧对原生方法调用的薄封装层（通道协议层的一部分），负责：
/// - 维护单条 `MethodChannel`（通道名见 [GromoreChannels.methodChannelName]）；
/// - 使用 `lib/src/models/` 中的强类型模型完成入参序列化与返回值反序列化；
/// - 将原生返回的 [PlatformException]（其 `code` 取自 [GromoreErrorCodes]）统一
///   转换为强类型的 [GromoreException]（Requirements 10.1、10.6、10.7）。
///
/// 该层不做参数校验（如 appId / slotId 长度），校验由顶层 API（任务 4.1、4.2）
/// 负责；本层只关心序列化与错误映射，保持职责单一。事件订阅（EventChannel）
/// 由独立的事件流分发器负责（任务 3.2），不在本文件范围内。
library;

import 'package:flutter/services.dart';

import '../models/models.dart';
import 'gromore_channels.dart';
import 'gromore_errors.dart';

/// 原生 MethodChannel 的强类型封装。
///
/// 所有方法在原生返回错误时抛出 [GromoreException]；调用方应捕获该异常以基于
/// [GromoreErrorType] 做分支处理。
class GromoreMethodChannel {
  /// 创建一个 [GromoreMethodChannel]。
  ///
  /// 可注入自定义 [channel]（便于在测试中替换为 mock 通道）；默认使用以
  /// [GromoreChannels.methodChannelName] 命名的 [MethodChannel]。
  GromoreMethodChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(GromoreChannels.methodChannelName);

  final MethodChannel _channel;

  /// 暴露底层通道，便于测试与诊断。
  MethodChannel get channel => _channel;

  // 方法名常量，作为 Dart 与原生之间的契约（Requirements 10.1）。
  static const String _mInit = 'init';
  static const String _mIsReady = 'isReady';
  static const String _mSetPrivacyConfig = 'setPrivacyConfig';
  static const String _mLoadSplashAd = 'loadSplashAd';
  static const String _mShowSplashAd = 'showSplashAd';
  static const String _mLoadRewardVideoAd = 'loadRewardVideoAd';
  static const String _mShowRewardVideoAd = 'showRewardVideoAd';
  static const String _mLoadInterstitialFullAd = 'loadInterstitialFullAd';
  static const String _mShowInterstitialFullAd = 'showInterstitialFullAd';
  static const String _mFeedDislike = 'feedDislike';
  static const String _mGetEcoCpmInfo = 'getEcoCpmInfo';
  static const String _mDestroyAd = 'destroyAd';

  /// 初始化并启动 SDK（Requirements 1.1–1.3、1.5、1.7）。
  ///
  /// 将 [config] 序列化为 `init` 调用的参数映射，返回原生回传的 [InitResult]。
  Future<InitResult> init(GromoreConfig config) async {
    final Map<String, dynamic> result = await _invokeMap(_mInit, config.toMap());
    return InitResult.fromMap(result);
  }

  /// 查询 SDK 当前是否已就绪（Requirements 1.6）。
  Future<bool> isReady() async {
    final bool? result = await _invoke<bool>(_mIsReady, const <String, dynamic>{});
    return result ?? false;
  }

  /// 更新隐私合规配置（Requirements 2.1–2.4）。
  Future<void> setPrivacyConfig(PrivacyConfig privacy) async {
    await _invoke<void>(_mSetPrivacyConfig, privacy.toMap());
  }

  /// 加载开屏广告，返回原生分配的 `adId`（Requirements 3.1）。
  Future<String> loadSplashAd(SplashAdRequest request) {
    return _invokeAdId(_mLoadSplashAd, request.toMap());
  }

  /// 展示指定的开屏广告（Requirements 3.4）。
  Future<void> showSplashAd(String adId) async {
    await _invoke<void>(_mShowSplashAd, _adIdArgs(adId));
  }

  /// 加载激励视频广告，返回原生分配的 `adId`（Requirements 4.1）。
  Future<String> loadRewardVideoAd(RewardAdRequest request) {
    return _invokeAdId(_mLoadRewardVideoAd, request.toMap());
  }

  /// 展示指定的激励视频广告（Requirements 4.4、4.7）。
  Future<void> showRewardVideoAd(String adId) async {
    await _invoke<void>(_mShowRewardVideoAd, _adIdArgs(adId));
  }

  /// 加载插全屏广告，返回原生分配的 `adId`（Requirements 5.1）。
  Future<String> loadInterstitialFullAd(InterstitialAdRequest request) {
    return _invokeAdId(_mLoadInterstitialFullAd, request.toMap());
  }

  /// 展示指定的插全屏广告（Requirements 5.4）。
  Future<void> showInterstitialFullAd(String adId) async {
    await _invoke<void>(_mShowInterstitialFullAd, _adIdArgs(adId));
  }

  /// 对信息流广告执行 dislike（不感兴趣）操作（Requirements 7.4）。
  Future<void> feedDislike(String adId) async {
    await _invoke<void>(_mFeedDislike, _adIdArgs(adId));
  }

  /// 读取指定广告实例的聚合竞价信息（Requirements 9.1–9.3）。
  ///
  /// 实例不存在或未展示时原生返回 `ecpm_unavailable`，转换为
  /// [GromoreException]（[GromoreErrorType.ecpmUnavailable]）抛出。
  Future<EcoCpmInfo> getEcoCpmInfo(String adId) async {
    final Map<String, dynamic> result = await _invokeMap(_mGetEcoCpmInfo, _adIdArgs(adId));
    return EcoCpmInfo.fromMap(result);
  }

  /// 销毁指定广告实例并释放原生资源（Requirements 10.4、10.5）。
  Future<void> destroyAd(String adId) async {
    await _invoke<void>(_mDestroyAd, _adIdArgs(adId));
  }

  /// 构造仅含 `adId` 的参数映射。
  Map<String, dynamic> _adIdArgs(String adId) => <String, dynamic>{'adId': adId};

  /// 调用原生方法并将 [PlatformException] 转换为 [GromoreException]。
  Future<T?> _invoke<T>(String method, Map<String, dynamic> arguments) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      throw GromoreException.fromPlatformException(e);
    }
  }

  /// 调用返回 `adId` 字符串的方法；原生返回空值时按未知错误处理。
  Future<String> _invokeAdId(String method, Map<String, dynamic> arguments) async {
    final String? adId = await _invoke<String>(method, arguments);
    if (adId == null) {
      throw const GromoreException(
        GromoreErrorType.unknown,
        code: 'unknown',
        message: 'Native layer returned a null adId.',
      );
    }
    return adId;
  }

  /// 调用返回映射结构的方法，并规范化为 `Map<String, dynamic>`。
  Future<Map<String, dynamic>> _invokeMap(
    String method,
    Map<String, dynamic> arguments,
  ) async {
    final Map<Object?, Object?>? result = await _invoke<Map<Object?, Object?>>(method, arguments);
    if (result == null) {
      throw GromoreException(
        GromoreErrorType.unknown,
        code: 'unknown',
        message: 'Native layer returned a null result for "$method".',
      );
    }
    return result.map(
      (Object? key, Object? value) => MapEntry<String, dynamic>('$key', value),
    );
  }
}
