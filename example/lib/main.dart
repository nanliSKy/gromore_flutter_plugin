// GroMore Flutter 插件示例工程（Requirements 11.5、11.6）。
//
// 本示例演示插件全部核心流程：
//   - SDK 初始化（含隐私合规配置 PrivacyConfig）与就绪查询 isReady
//   - 开屏（Splash）、激励视频（Reward）、插全屏（Interstitial-Full）三类
//     覆盖式广告的加载与展示
//   - Banner、信息流（Feed）两类 PlatformView 广告的嵌入展示
//   - 订阅 events 事件流并实时展示广告回调（eventType / adId / adType / data）
//   - 演示 getEcoCpmInfo（聚合竞价信息）与 destroyAd（资源释放）
//
// ⚠️ 重要：下方所有 `YOUR_APP_ID` 与 `YOUR_*_SLOT_ID` 均为占位符，运行前必须
// 替换为你在穿山甲（CSJ/GroMore）平台申请的真实 App_Id 与各类型聚合广告位 ID，
// 否则广告无法正常加载。占位符仅用于演示 API 调用方式。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gromore_flutter_plugin/gromore_flutter_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroMore Flutter Plugin Demo',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const DemoHomePage(),
    );
  }
}

// ===========================================================================
// 占位符常量 —— 运行前请替换为真实值。
// ===========================================================================

/// 穿山甲平台申请的 App_Id（Requirements 1.1）。请替换为真实 App_Id。
const String kAppId = '5836571';

/// 开屏广告聚合广告位 ID。请替换为真实 slotId。
const String kSplashSlotId = '104130014';

/// 激励视频广告聚合广告位 ID。请替换为真实 slotId。
const String kRewardSlotId = '104129377';

/// 插全屏广告聚合广告位 ID。请替换为真实 slotId。
const String kInterstitialSlotId = '104129376';

/// Banner 广告聚合广告位 ID。请替换为真实 slotId。
const String kBannerSlotId = '104130209';

/// 信息流广告聚合广告位 ID。请替换为真实 slotId。
const String kFeedSlotId = '983695126';

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  final GromoreFlutterPlugin _plugin = GromoreFlutterPlugin.instance;

  /// 订阅全量广告事件流（Requirements 8.x）。
  StreamSubscription<AdEvent>? _eventSubscription;

  /// 事件日志（最新的事件追加在末尾）。
  final List<String> _eventLog = <String>[];

  /// 是否显示 Banner / Feed 平台视图。
  bool _showBanner = false;
  bool _showFeed = false;

  /// Feed dislike 控制器（Requirements 7.4）。
  final FeedAdController _feedController = FeedAdController();

  /// 初始化状态文本。
  String _initStatus = '未初始化';

  /// isReady 查询结果。
  bool _ready = false;

  /// 最近一次加载成功并可用于 getEcoCpmInfo / destroyAd 的广告 adId。
  String? _lastAdId;

  @override
  void initState() {
    super.initState();
    // 订阅全量事件流，将每个 AdEvent 渲染到日志（Requirements 8.x、11.6）。
    _eventSubscription = _plugin.events.listen(
      (AdEvent event) {
        _appendLog(
          '事件 ${event.eventType} '
          '[type=${event.adType}, adId=${event.adId}] data=${event.data}',
        );
        // 记录加载成功事件的 adId，供 getEcoCpmInfo / destroyAd 演示使用。
        if (event.eventType == GromoreEventTypes.onAdLoaded) {
          setState(() => _lastAdId = event.adId);
        }
      },
      onError: (Object error) => _appendLog('事件流错误: $error'),
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _appendLog(String message) {
    if (!mounted) return;
    setState(() {
      final String ts = TimeOfDay.now().format(context);
      _eventLog.add('[$ts] $message');
      // 控制日志长度，避免无限增长。
      if (_eventLog.length > 200) {
        _eventLog.removeRange(0, _eventLog.length - 200);
      }
    });
  }

  // -------------------------------------------------------------------------
  // SDK 初始化与就绪查询（Requirements 1、2）。
  // -------------------------------------------------------------------------

  Future<void> _initSdk() async {
    try {
      // 演示隐私合规配置（Requirements 2.1–2.4）：限制个性化广告并按需禁用部分
      // 设备标识符采集。实际取值请根据合规要求调整。
      const PrivacyConfig privacy = PrivacyConfig(
        limitPersonalAds: false,
        canUseOaid: true,
        canUseMacAddress: false,
        canUseAndroidId: true,
        canUseWifiState: true,
        canUseLocation: false,
      );

      final InitResult result = await _plugin.init(
        const GromoreConfig(
          appId: kAppId, // ⚠️ 替换为真实 App_Id
          useMediation: true,
          debug: true,
          privacy: privacy,
        ),
      );

      // 🔧 修复840040: 初始化后等待SDK完全就绪
      if (result.success) {
        _appendLog('SDK初始化成功，等待配置拉取...');
        // 等待3秒让SDK有时间拉取远程配置
        await Future<void>.delayed(const Duration(seconds: 3));
      }

      final bool ready = await _plugin.isReady();
      setState(() {
        _ready = ready;
        if (result.success) {
          _initStatus = result.alreadyInitialized ? '已初始化（幂等）' : '初始化成功';
        } else {
          _initStatus = '初始化失败: code=${result.errorCode}, msg=${result.errorMessage}';
        }
      });
      _appendLog('init -> $_initStatus (isReady=$ready)');

      if (ready) {
        _appendLog('✅ SDK已就绪，可以开始加载广告');
      } else {
        _appendLog('⚠️ SDK未就绪，请检查网络连接和配置');
      }
    } on GromoreException catch (e) {
      setState(() => _initStatus = '初始化异常: ${e.type} ${e.message}');
      _appendLog('init 异常: $e');
    }
  }

  Future<void> _refreshReady() async {
    final bool ready = await _plugin.isReady();
    setState(() => _ready = ready);
    _appendLog('isReady -> $ready');
  }

  /// 演示更新隐私配置（Requirements 2.1）。
  Future<void> _updatePrivacy() async {
    try {
      await _plugin.setPrivacyConfig(
        const PrivacyConfig(limitPersonalAds: true),
      );
      _appendLog('setPrivacyConfig -> limitPersonalAds=true');
    } on GromoreException catch (e) {
      _appendLog('setPrivacyConfig 异常: $e');
    }
  }

  // -------------------------------------------------------------------------
  // 开屏广告（Requirements 3）。
  // -------------------------------------------------------------------------

  Future<void> _loadAndShowSplash() async {
    // 🔧 修复840040: 加载前检查SDK是否就绪
    if (!_ready) {
      _appendLog('⚠️ SDK未就绪，请先初始化SDK并等待就绪');
      return;
    }

    try {
      final String adId = await _plugin.loadSplashAd(
        const SplashAdRequest(slotId: kSplashSlotId, timeoutMs: 5000),
      );
      _appendLog('loadSplashAd -> adId=$adId，等待加载完成...');
      setState(() => _lastAdId = adId);

      // 🔧 等待广告加载完成后再展示
      final Completer<void> loadCompleter = Completer<void>();
      StreamSubscription<AdEvent>? loadSubscription;

      loadSubscription = _plugin.events.listen((AdEvent event) {
        if (event.adId == adId) {
          if (event.eventType == GromoreEventTypes.onAdLoaded) {
            _appendLog('✅ 开屏广告加载成功，准备展示');
            if (!loadCompleter.isCompleted) {
              loadCompleter.complete();
            }
            loadSubscription?.cancel();
          } else if (event.eventType == GromoreEventTypes.onAdLoadFailed) {
            _appendLog('❌ 开屏广告加载失败: ${event.data}');
            if (!loadCompleter.isCompleted) {
              loadCompleter.completeError('加载失败: ${event.data}');
            }
            loadSubscription?.cancel();
          }
        }
      });

      // 等待加载完成，最多等待6秒（开屏广告通常需要更多时间）
      await loadCompleter.future.timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          loadSubscription?.cancel();
          throw TimeoutException('开屏广告加载超时');
        },
      );

      // 广告已加载，现在展示
      await _plugin.showSplashAd(adId);
      _appendLog('✅ showSplashAd($adId) 已调用');
    } on TimeoutException catch (e) {
      _appendLog('⏱️ 开屏广告超时: $e');
    } on GromoreException catch (e) {
      _appendLog('❌ splash 异常: ${e.type} ${e.message}');
    } catch (e) {
      _appendLog('❌ 开屏广告错误: $e');
    }
  }

  // -------------------------------------------------------------------------
  // 激励视频广告（Requirements 4）。
  // -------------------------------------------------------------------------

  Future<void> _loadAndShowReward() async {
    // 🔧 修复840040: 加载前检查SDK是否就绪
    if (!_ready) {
      _appendLog('⚠️ SDK未就绪，请先初始化SDK并等待就绪');
      return;
    }

    try {
      final String adId = await _plugin.loadRewardVideoAd(
        const RewardAdRequest(
          slotId: kRewardSlotId,
          userId: 'demo_user',
          rewardName: '金币',
          rewardAmount: 10,
        ),
      );
      _appendLog('loadRewardVideoAd -> adId=$adId，等待加载完成...');
      setState(() => _lastAdId = adId);

      // 🔧 等待广告加载完成后再展示
      final Completer<void> loadCompleter = Completer<void>();
      StreamSubscription<AdEvent>? loadSubscription;

      loadSubscription = _plugin.events.listen((AdEvent event) {
        if (event.adId == adId) {
          if (event.eventType == GromoreEventTypes.onAdLoaded) {
            _appendLog('✅ 激励视频广告加载成功，准备展示');
            if (!loadCompleter.isCompleted) {
              loadCompleter.complete();
            }
            loadSubscription?.cancel();
          } else if (event.eventType == GromoreEventTypes.onAdLoadFailed) {
            _appendLog('❌ 激励视频广告加载失败: ${event.data}');
            if (!loadCompleter.isCompleted) {
              loadCompleter.completeError('加载失败: ${event.data}');
            }
            loadSubscription?.cancel();
          }
        }
      });

      // 等待加载完成，最多等待5秒
      await loadCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          loadSubscription?.cancel();
          throw TimeoutException('激励视频广告加载超时');
        },
      );

      // 广告已加载，现在展示
      await _plugin.showRewardVideoAd(adId);
      _appendLog('✅ showRewardVideoAd($adId) 已调用');
    } on TimeoutException catch (e) {
      _appendLog('⏱️ 激励视频广告超时: $e');
    } on GromoreException catch (e) {
      _appendLog('❌ reward 异常: ${e.type} ${e.message}');
    } catch (e) {
      _appendLog('❌ 激励视频广告错误: $e');
    }
  }

  // -------------------------------------------------------------------------
  // 插全屏广告（Requirements 5）。
  // -------------------------------------------------------------------------

  Future<void> _loadAndShowInterstitial() async {
    // 🔧 修复840040: 加载前检查SDK是否就绪
    if (!_ready) {
      _appendLog('⚠️ SDK未就绪，请先初始化SDK并等待就绪');
      return;
    }

    try {
      final String adId = await _plugin.loadInterstitialFullAd(
        const InterstitialAdRequest(slotId: kInterstitialSlotId),
      );
      _appendLog('loadInterstitialFullAd -> adId=$adId，等待加载完成...');
      setState(() => _lastAdId = adId);

      // 🔧 修复插屏广告不显示: 等待广告加载完成后再展示
      // 监听事件流，等待onAdLoaded事件
      final Completer<void> loadCompleter = Completer<void>();
      StreamSubscription<AdEvent>? loadSubscription;

      loadSubscription = _plugin.events.listen((AdEvent event) {
        if (event.adId == adId) {
          if (event.eventType == GromoreEventTypes.onAdLoaded) {
            _appendLog('插屏广告加载成功，准备展示');
            if (!loadCompleter.isCompleted) {
              loadCompleter.complete();
            }
            loadSubscription?.cancel();
          } else if (event.eventType == GromoreEventTypes.onAdLoadFailed) {
            _appendLog('插屏广告加载失败: ${event.data}');
            if (!loadCompleter.isCompleted) {
              loadCompleter.completeError('加载失败: ${event.data}');
            }
            loadSubscription?.cancel();
          }
        }
      });

      // 等待加载完成，最多等待5秒
      await loadCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          loadSubscription?.cancel();
          throw TimeoutException('插屏广告加载超时');
        },
      );

      // 广告已加载，现在展示
      await _plugin.showInterstitialFullAd(adId);
      _appendLog('showInterstitialFullAd($adId) 已调用');
    } on TimeoutException catch (e) {
      _appendLog('插屏广告超时: $e');
    } on GromoreException catch (e) {
      _appendLog('interstitial 异常: ${e.type} ${e.message}');
    } catch (e) {
      _appendLog('插屏广告错误: $e');
    }
  }

  // -------------------------------------------------------------------------
  // 竞价信息与资源释放（Requirements 9、10.4）。
  // -------------------------------------------------------------------------

  Future<void> _getEcoCpm() async {
    final String? adId = _lastAdId;
    if (adId == null) {
      _appendLog('getEcoCpmInfo: 暂无可用 adId');
      return;
    }
    try {
      final EcoCpmInfo info = await _plugin.getEcoCpmInfo(adId);
      _appendLog(
        'getEcoCpmInfo($adId) -> adn=${info.adnName}, '
        'ecpm=${info.ecpm}, slotId=${info.slotId}',
      );
    } on GromoreException catch (e) {
      _appendLog('getEcoCpmInfo 异常: ${e.type} ${e.message}');
    }
  }

  Future<void> _destroyLast() async {
    final String? adId = _lastAdId;
    if (adId == null) {
      _appendLog('destroyAd: 暂无可用 adId');
      return;
    }
    try {
      await _plugin.destroyAd(adId);
      _appendLog('destroyAd($adId) 完成');
      setState(() => _lastAdId = null);
    } on GromoreException catch (e) {
      _appendLog('destroyAd 异常: ${e.type} ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GroMore 插件示例')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          _buildInitSection(),
          const Divider(height: 24),
          _buildFullscreenAdSection(),
          const Divider(height: 24),
          _buildEcpmSection(),
          const Divider(height: 24),
          _buildBannerSection(),
          const Divider(height: 24),
          _buildFeedSection(),
          const Divider(height: 24),
          _buildEventLogSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildInitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionTitle('1. SDK 初始化与隐私配置'),
        Row(
          children: <Widget>[
            Icon(
              _ready ? Icons.check_circle : Icons.cancel,
              color: _ready ? Colors.green : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(child: Text('状态: $_initStatus')),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ElevatedButton(onPressed: _initSdk, child: const Text('初始化 SDK')),
            OutlinedButton(onPressed: _refreshReady, child: const Text('查询 isReady')),
            OutlinedButton(onPressed: _updatePrivacy, child: const Text('更新隐私配置')),
          ],
        ),
      ],
    );
  }

  Widget _buildFullscreenAdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionTitle('2. 覆盖式广告（开屏 / 激励 / 插全屏）'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ElevatedButton(onPressed: _loadAndShowSplash, child: const Text('开屏')),
            ElevatedButton(onPressed: _loadAndShowReward, child: const Text('激励视频')),
            ElevatedButton(onPressed: _loadAndShowInterstitial, child: const Text('插全屏')),
          ],
        ),
      ],
    );
  }

  Widget _buildEcpmSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionTitle('3. 竞价信息与资源释放'),
        Text('最近 adId: ${_lastAdId ?? '（无）'}'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            OutlinedButton(onPressed: _getEcoCpm, child: const Text('getEcoCpmInfo')),
            OutlinedButton(onPressed: _destroyLast, child: const Text('destroyAd')),
          ],
        ),
      ],
    );
  }

  Widget _buildBannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionTitle('4. Banner 广告（PlatformView）'),
        Wrap(
          spacing: 8,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // 🔧 修复 Banner 广告显示: 加载前检查SDK是否就绪
                if (!_ready) {
                  _appendLog('⚠️ SDK未就绪，请先初始化SDK并等待就绪');
                  return;
                }
                setState(() {
                  _showBanner = !_showBanner;
                  if (_showBanner) {
                    _appendLog('✅ 开始加载 Banner 广告 slotId=$kBannerSlotId');
                  } else {
                    _appendLog('隐藏 Banner 广告');
                  }
                });
              },
              child: Text(_showBanner ? '隐藏 Banner' : '显示 Banner'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_showBanner)
          // BannerAdView 在 dispose 时自动释放原生资源（Requirements 6.8）。
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: BannerAdView(
              slotId: kBannerSlotId, // ⚠️ 替换为真实 Banner slotId
              width: 320,
              height: 150,
              onAdEvent: (AdEvent event) {
                _appendLog('Banner 事件 ${event.eventType} data=${event.data}');
                // 🔧 监控加载状态
                if (event.eventType == GromoreEventTypes.onAdLoaded) {
                  _appendLog('✅ Banner 广告加载成功');
                } else if (event.eventType == GromoreEventTypes.onAdLoadFailed) {
                  _appendLog('❌ Banner 广告加载失败: ${event.data}');
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFeedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionTitle('5. 信息流广告（PlatformView）'),
        Wrap(
          spacing: 8,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // 🔧 修复信息流广告显示: 加载前检查SDK是否就绪
                if (!_ready) {
                  _appendLog('⚠️ SDK未就绪，请先初始化SDK并等待就绪');
                  return;
                }
                setState(() {
                  _showFeed = !_showFeed;
                  if (_showFeed) {
                    _appendLog('✅ 开始加载信息流广告 slotId=$kFeedSlotId');
                  } else {
                    _appendLog('隐藏信息流广告');
                  }
                });
              },
              child: Text(_showFeed ? '隐藏信息流' : '显示信息流'),
            ),
            OutlinedButton(
              onPressed: _showFeed
                  ? () {
                      // dislike（不感兴趣）操作（Requirements 7.4）。
                      _feedController.dislike();
                      _appendLog('Feed dislike() 调用');
                    }
                  : null,
              child: const Text('dislike'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_showFeed)
          // FeedAdView 在 dispose 时自动释放原生资源（Requirements 7.7）。
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FeedAdView(
              slotId: kFeedSlotId, // ⚠️ 替换为真实 Feed slotId
              width: 350,
              height: 250,
              controller: _feedController,
              onAdEvent: (AdEvent event) {
                _appendLog('Feed 事件 ${event.eventType} data=${event.data}');
                // 🔧 监控加载状态
                if (event.eventType == GromoreEventTypes.onAdLoaded) {
                  _appendLog('✅ 信息流广告加载成功');
                } else if (event.eventType == GromoreEventTypes.onAdLoadFailed) {
                  _appendLog('❌ 信息流广告加载失败: ${event.data}');
                }
              },
            ),
          ),
        if (_showFeed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '提示: 如广告未显示，请检查:\n'
              '1. SDK是否已初始化并就绪\n'
              '2. 广告位ID($kFeedSlotId)是否有效\n'
              '3. 查看事件日志了解加载状态',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildEventLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildSectionTitle('6. 事件日志（events 流）'),
            TextButton(
              onPressed: () => setState(() => _eventLog.clear()),
              child: const Text('清空'),
            ),
          ],
        ),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: _eventLog.isEmpty
              ? const Center(
                  child: Text('暂无事件', style: TextStyle(color: Colors.white54)),
                )
              : ListView.builder(
                  reverse: true,
                  itemCount: _eventLog.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String line = _eventLog[_eventLog.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
