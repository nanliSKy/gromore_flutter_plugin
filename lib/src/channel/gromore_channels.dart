/// 通道名、PlatformView viewType、事件类型与错误码的共享常量定义。
///
/// 这些常量是 Dart 侧与 Android / iOS 原生侧的"单一事实来源"（single source
/// of truth）。Android 与 iOS 原生实现必须使用与此处完全一致的字符串字面量，
/// 以保证双端契约一致（Requirements 10.1）与事件往返序列化一致（Requirements 8.2）。
library;

/// 通道名常量。
///
/// 插件使用一条 [methodChannelName] 承载方法调用（init / load / show /
/// destroy / getEcoCpmInfo 等），使用一条 [eventChannelName] 承载所有广告
/// 生命周期事件。
class GromoreChannels {
  GromoreChannels._();

  /// MethodChannel 名称，承载所有方法调用。
  static const String methodChannelName = 'gromore_flutter_plugin/methods';

  /// EventChannel 名称，承载所有广告生命周期事件。
  static const String eventChannelName = 'gromore_flutter_plugin/events';
}

/// PlatformView 的 viewType 常量。
///
/// Banner 与 Feed/原生广告需要把原生广告视图嵌入 Flutter 渲染树，分别通过这两个
/// viewType 注册对应的 PlatformViewFactory（Requirements 6.1、7.1）。
class GromoreViewTypes {
  GromoreViewTypes._();

  /// Banner 广告 PlatformView 的 viewType。
  static const String banner = 'gromore_flutter_plugin/banner';

  /// 信息流/原生广告 PlatformView 的 viewType。
  static const String feed = 'gromore_flutter_plugin/feed';
}

/// 双端共享的广告事件类型字符串常量集合。
///
/// 每个广告实例产生的 `AdEvent.eventType` 必须取自该集合，Android 与 iOS 原生
/// 侧必须使用相同字符串（Requirements 8.2、10.1）。
class GromoreEventTypes {
  GromoreEventTypes._();

  /// 广告加载成功。
  static const String onAdLoaded = 'onAdLoaded';

  /// 广告加载失败（data 含 errorCode / errorMessage）。
  static const String onAdLoadFailed = 'onAdLoadFailed';

  /// 广告展示。
  static const String onAdShow = 'onAdShow';

  /// 广告点击。
  static const String onAdClick = 'onAdClick';

  /// 广告关闭。
  static const String onAdClose = 'onAdClose';

  /// 开屏广告被跳过。
  static const String onSkip = 'onSkip';

  /// 开屏广告倒计时结束。
  static const String onCountdownFinish = 'onCountdownFinish';

  /// 激励视频奖励发放（data 含 rewardVerify / rewardName / rewardAmount）。
  static const String onReward = 'onReward';

  /// 视频播放完成。
  static const String onVideoComplete = 'onVideoComplete';

  /// 模板渲染成功。
  static const String onRenderSuccess = 'onRenderSuccess';

  /// 模板渲染失败（data 含 errorCode / errorMessage）。
  static const String onRenderFail = 'onRenderFail';

  /// 信息流广告 dislike（移除）。
  static const String onDislike = 'onDislike';

  /// 所有合法事件类型的集合，便于 Dart 侧校验反序列化结果。
  static const Set<String> all = <String>{
    onAdLoaded,
    onAdLoadFailed,
    onAdShow,
    onAdClick,
    onAdClose,
    onSkip,
    onCountdownFinish,
    onReward,
    onVideoComplete,
    onRenderSuccess,
    onRenderFail,
    onDislike,
  };
}

/// 双端共享的错误码常量集合。
///
/// 原生层通过 MethodChannel 的 `error(code, message, details)` 返回这些错误码，
/// Dart 侧据此映射为强类型错误（Requirements 10.1）。
class GromoreErrorCodes {
  GromoreErrorCodes._();

  /// 参数校验失败（如缺少 appId、slotId 长度非法等）。
  static const String invalidArgument = 'invalid_argument';

  /// SDK 未初始化即调用广告接口。
  static const String notInitialized = 'not_initialized';

  /// 实例尚未加载完成即展示。
  static const String adNotReady = 'ad_not_ready';

  /// adId 不在注册表中（已销毁或从未创建）。
  static const String adNotFound = 'ad_not_found';

  /// 竞价信息不可用（实例不存在或未展示）。
  static const String ecpmUnavailable = 'ecpm_unavailable';

  /// SDK 初始化/启动失败。
  static const String sdkInitFailed = 'sdk_init_failed';

  /// 所有错误码的集合，便于 Dart 侧校验与一致性测试。
  static const Set<String> all = <String>{
    invalidArgument,
    notInitialized,
    adNotReady,
    adNotFound,
    ecpmUnavailable,
    sdkInitFailed,
  };
}
