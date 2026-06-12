/// `gromore_flutter_plugin` 顶层 API 入口。
///
/// 本文件暴露插件面向 Flutter 应用的统一入口 [GromoreFlutterPlugin]（单例），
/// 封装通道协议层（[GromoreMethodChannel] + [GromoreEventDispatcher]），并实现
/// SDK 初始化与启动、就绪查询、隐私合规配置与广告事件流订阅等能力。
///
/// 设计参考：`/.kiro/specs/gromore-flutter-plugin/design.md`。
///
/// 本任务（4.1）实现 init / isReady / setPrivacyConfig / events / eventsForAd 与
/// 单例脚手架；广告 load / show / destroy / getEcoCpmInfo 等方法由任务 4.2 在本
/// 文件继续扩展。
library;

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'src/channel/gromore_errors.dart';
import 'src/channel/gromore_event_dispatcher.dart';
import 'src/channel/gromore_method_channel.dart';
import 'src/models/models.dart';

export 'src/channel/gromore_channels.dart' show GromoreEventTypes, GromoreErrorCodes, GromoreViewTypes;
export 'src/channel/gromore_errors.dart';
export 'src/channel/gromore_event_dispatcher.dart' show GromoreEventDeserializationException;
export 'src/models/models.dart';
export 'src/views/views.dart';

/// GroMore 聚合变现插件的顶层入口（单例）。
///
/// 通过 [instance] 获取全局唯一实例；该实例封装一条 [GromoreMethodChannel]
/// 承载方法调用，封装一条 [GromoreEventDispatcher] 承载广告生命周期事件。
///
/// 关于 [init] 的关键行为（Requirements 1.1、1.4、1.5、1.6）：
/// - **参数校验前置**：在触达原生之前对 `appId` 做校验，仅空白字符（含空字符串）
///   或长度超过 64 个字符视为非法，直接返回参数校验失败的 [InitResult]，
///   且不调用原生初始化（Requirements 1.4、1.5；设计文档 Property 5）。
/// - **幂等**：已成功初始化（就绪）后再次调用 [init] 返回
///   [InitResult.alreadyInitialized]，不重复触发原生初始化
///   （Requirements 1.5；设计文档 Property 6）。
/// - **就绪状态缓存**：仅在原生初始化成功后将内部就绪标志置为 `true`；
///   失败或参数非法不改变就绪状态（Requirements 1.3）。[isReady] 返回该缓存
///   状态（Requirements 1.6）。
class GromoreFlutterPlugin {
  /// 内部构造函数；默认创建生产环境使用的通道与事件分发器。
  GromoreFlutterPlugin._({
    GromoreMethodChannel? methodChannel,
    GromoreEventDispatcher? eventDispatcher,
  })  : _methodChannel = methodChannel ?? GromoreMethodChannel(),
        _eventDispatcher = eventDispatcher ?? GromoreEventDispatcher();

  /// 可注入依赖的测试构造函数。
  ///
  /// 允许在测试中替换通道层（用计数 mock 断言原生初始化的调用次数，支撑
  /// 设计文档 Property 5 / Property 6）与事件分发器（喂入合成事件）。
  @visibleForTesting
  GromoreFlutterPlugin.forTesting({
    required GromoreMethodChannel methodChannel,
    required GromoreEventDispatcher eventDispatcher,
  })  : _methodChannel = methodChannel,
        _eventDispatcher = eventDispatcher;

  static GromoreFlutterPlugin? _instance;

  /// 全局唯一实例（单例入口）。
  static GromoreFlutterPlugin get instance => _instance ??= GromoreFlutterPlugin._();

  /// 覆盖单例实例，仅供测试使用。传入 `null` 可在用例之间重置。
  @visibleForTesting
  static set instance(GromoreFlutterPlugin? value) => _instance = value;

  /// 参数校验失败时 [InitResult.errorCode] 携带的错误码（Requirements 1.4、1.5）。
  static const int kInvalidArgumentErrorCode = -1;

  /// 开屏广告 `slotId` 的最大长度（Requirements 3.1）。
  static const int kSplashSlotIdMaxLength = 128;

  /// 激励视频广告 `slotId` 的最大长度（Requirements 4.1）。
  static const int kRewardSlotIdMaxLength = 128;

  /// 插全屏广告 `slotId` 的最大长度（Requirements 5.1）。
  static const int kInterstitialSlotIdMaxLength = 64;

  final GromoreMethodChannel _methodChannel;
  final GromoreEventDispatcher _eventDispatcher;

  /// SDK 就绪状态缓存（Requirements 1.6）。仅原生初始化成功后置为 `true`。
  bool _ready = false;

  /// 暴露通道层，便于子任务（4.2）扩展与测试诊断。
  @visibleForTesting
  GromoreMethodChannel get methodChannel => _methodChannel;

  /// 暴露事件分发器，便于子任务扩展与测试诊断。
  @visibleForTesting
  GromoreEventDispatcher get eventDispatcher => _eventDispatcher;

  /// 全量广告事件流（所有 adId 的合法事件，Requirements 8.x）。
  Stream<AdEvent> get events => _eventDispatcher.events;

  /// 按 [adId] 过滤的广告事件子流（Requirements 8.4）。
  Stream<AdEvent> eventsForAd(String adId) => _eventDispatcher.eventsForAd(adId);

  /// 初始化并启动 GroMore SDK（Requirements 1.1–1.6）。
  ///
  /// 处理顺序：
  /// 1. **幂等**：若当前已就绪，直接返回 [InitResult.alreadyInitialized]，
  ///    不触达原生（Requirements 1.5）。
  /// 2. **参数校验**：`appId` 仅空白字符（含空字符串）或长度超过 64，返回参数
  ///    校验失败结果且不调用原生（Requirements 1.4、1.5）。
  /// 3. **委派原生**：调用 [GromoreMethodChannel.init]；成功时缓存就绪状态，
  ///    失败时保持未就绪（Requirements 1.2、1.3）。
  Future<InitResult> init(GromoreConfig config) async {
    // 幂等：已就绪则不重复初始化（Requirements 1.5）。
    if (_ready) {
      return const InitResult.alreadyInitialized();
    }

    // 参数校验前置：非法 appId 直接拒绝，不触达原生（Requirements 1.4、1.5）。
    final String? validationError = _validateAppId(config.appId);
    if (validationError != null) {
      return InitResult.failure(
        errorCode: kInvalidArgumentErrorCode,
        errorMessage: validationError,
      );
    }

    final InitResult result = await _methodChannel.init(config);
    // 仅成功时缓存就绪状态；失败不改变就绪状态（Requirements 1.2、1.3）。
    if (result.success) {
      _ready = true;
    }
    return result;
  }

  /// 查询当前 SDK 是否已就绪（Requirements 1.6）。
  ///
  /// 返回内部缓存的就绪状态——该状态是初始化幂等性的唯一事实来源
  /// （设计文档 Property 6）。
  Future<bool> isReady() async => _ready;

  /// 更新隐私合规配置（Requirements 2.1）。
  Future<void> setPrivacyConfig(PrivacyConfig privacy) {
    return _methodChannel.setPrivacyConfig(privacy);
  }

  /// 加载开屏广告，返回原生分配的 `adId`（Requirements 3.1）。
  ///
  /// 在触达原生之前对 `slotId` 做长度校验（开屏 1–128 个字符）。非法时抛出
  /// [GromoreException]（[GromoreErrorType.invalidArgument]），且不调用原生
  /// （Requirements 3.1）。
  Future<String> loadSplashAd(SplashAdRequest request) {
    _validateSlotId(request.slotId, maxLength: kSplashSlotIdMaxLength);
    return _methodChannel.loadSplashAd(request);
  }

  /// 展示指定的开屏广告（Requirements 3.x）。
  Future<void> showSplashAd(String adId) {
    return _methodChannel.showSplashAd(adId);
  }

  /// 加载激励视频广告，返回原生分配的 `adId`（Requirements 4.1）。
  ///
  /// 在触达原生之前对 `slotId` 做长度校验（激励 1–128 个字符）。非法时抛出
  /// [GromoreException]（[GromoreErrorType.invalidArgument]），且不调用原生
  /// （Requirements 4.1）。
  Future<String> loadRewardVideoAd(RewardAdRequest request) {
    _validateSlotId(request.slotId, maxLength: kRewardSlotIdMaxLength);
    return _methodChannel.loadRewardVideoAd(request);
  }

  /// 展示指定的激励视频广告（Requirements 4.x）。
  Future<void> showRewardVideoAd(String adId) {
    return _methodChannel.showRewardVideoAd(adId);
  }

  /// 加载插全屏广告，返回原生分配的 `adId`（Requirements 5.1）。
  ///
  /// 在触达原生之前对 `slotId` 做长度校验（插全屏 1–64 个字符）。非法时抛出
  /// [GromoreException]（[GromoreErrorType.invalidArgument]），且不调用原生
  /// （Requirements 5.1）。
  Future<String> loadInterstitialFullAd(InterstitialAdRequest request) {
    _validateSlotId(request.slotId, maxLength: kInterstitialSlotIdMaxLength);
    return _methodChannel.loadInterstitialFullAd(request);
  }

  /// 展示指定的插全屏广告（Requirements 5.x）。
  Future<void> showInterstitialFullAd(String adId) {
    return _methodChannel.showInterstitialFullAd(adId);
  }

  /// 读取指定广告实例的聚合竞价信息（Requirements 9.1）。
  Future<EcoCpmInfo> getEcoCpmInfo(String adId) {
    return _methodChannel.getEcoCpmInfo(adId);
  }

  /// 销毁指定广告实例并释放原生资源（Requirements 10.4、10.5）。
  Future<void> destroyAd(String adId) {
    return _methodChannel.destroyAd(adId);
  }

  /// 校验 `appId`：合法返回 `null`，非法返回可读错误信息。
  ///
  /// 规则（Requirements 1.4、1.5）：
  /// - 仅由空白字符组成（含空字符串）视为非法；
  /// - 长度超过 64 个字符视为非法。
  String? _validateAppId(String appId) {
    if (appId.trim().isEmpty) {
      return 'Invalid appId: must not be empty or whitespace-only.';
    }
    if (appId.length > 64) {
      return 'Invalid appId: length must be between 1 and 64 characters.';
    }
    return null;
  }

  /// 校验广告位 `slotId` 长度（Requirements 3.1、4.1、5.1）。
  ///
  /// 规则：非空且长度为 1 到 [maxLength] 个字符。非法时抛出
  /// [GromoreException]（[GromoreErrorType.invalidArgument]），调用方据此在不
  /// 触达原生的前提下感知参数错误（设计文档 Property 9 同源校验思路）。
  void _validateSlotId(String slotId, {required int maxLength}) {
    if (slotId.isEmpty || slotId.length > maxLength) {
      throw GromoreException(
        GromoreErrorType.invalidArgument,
        code: GromoreErrorType.invalidArgument.code,
        message: 'Invalid slotId: length must be between 1 and $maxLength characters.',
      );
    }
  }
}
