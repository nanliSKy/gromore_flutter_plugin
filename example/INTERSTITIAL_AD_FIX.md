# 插屏广告不显示问题修复

## 问题描述

插屏广告（Interstitial Ad）调用`loadInterstitialFullAd`和`showInterstitialFullAd`后不显示。

## 问题根源

**广告还没加载完成就立即调用了show方法**。

当前代码流程：
```dart
final String adId = await _plugin.loadInterstitialFullAd(request);  // 1. 发起加载请求
await _plugin.showInterstitialFullAd(adId);  // 2. 立即调用show ❌ 错误！
```

`loadInterstitialFullAd` 只是**发起加载请求**并返回adId，并不等待广告加载完成。真正的加载是异步的，加载完成后会通过`events`流发送`onAdLoaded`事件。

## 解决方案

### 方案1：等待onAdLoaded事件（推荐）

修改`_loadAndShowInterstitial`函数，等待广告加载完成：

```dart
Future<void> _loadAndShowInterstitial() async {
  if (!_ready) {
    _appendLog('⚠️ SDK未就绪，请先初始化SDK并等待就绪');
    return;
  }

  try {
    // 1. 发起加载请求
    final String adId = await _plugin.loadInterstitialFullAd(
      const InterstitialAdRequest(slotId: kInterstitialSlotId),
    );
    _appendLog('loadInterstitialFullAd -> adId=$adId，等待加载完成...');
    setState(() => _lastAdId = adId);
    
    // 2. 等待广告加载完成
    final Completer<void> loadCompleter = Completer<void>();
    StreamSubscription<AdEvent>? loadSubscription;
    
    loadSubscription = _plugin.events.listen((AdEvent event) {
      if (event.adId == adId) {
        if (event.eventType == GromoreEventTypes.onAdLoaded) {
          _appendLog('✅ 插屏广告加载成功，准备展示');
          if (!loadCompleter.isCompleted) {
            loadCompleter.complete();
          }
          loadSubscription?.cancel();
        } else if (event.eventType == GromoreEventTypes.onAdLoadFailed) {
          _appendLog('❌ 插屏广告加载失败: ${event.data}');
          if (!loadCompleter.isCompleted) {
            loadCompleter.completeError('加载失败: ${event.data}');
          }
          loadSubscription?.cancel();
        }
      }
    });
    
    // 3. 等待加载完成（最多等待5秒）
    await loadCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        loadSubscription?.cancel();
        throw TimeoutException('插屏广告加载超时');
      },
    );
    
    // 4. 广告已加载，现在展示
    await _plugin.showInterstitialFullAd(adId);
    _appendLog('✅ showInterstitialFullAd($adId) 已调用');
  } on TimeoutException catch (e) {
    _appendLog('⏱️ 插屏广告超时: $e');
  } on GromoreException catch (e) {
    _appendLog('❌ interstitial 异常: ${e.type} ${e.message}');
  } catch (e) {
    _appendLog('❌ 插屏广告错误: $e');
  }
}
```

### 方案2：分离加载和展示（更灵活）

将加载和展示分为两个按钮：

```dart
String? _interstitialAdId;

// 加载按钮
Future<void> _loadInterstitial() async {
  if (!_ready) {
    _appendLog('⚠️ SDK未就绪');
    return;
  }
  
  try {
    final String adId = await _plugin.loadInterstitialFullAd(
      const InterstitialAdRequest(slotId: kInterstitialSlotId),
    );
    _appendLog('开始加载插屏广告: $adId');
    
    // 等待加载完成
    await for (final event in _plugin.events) {
      if (event.adId == adId) {
        if (event.eventType == GromoreEventTypes.onAdLoaded) {
          setState(() => _interstitialAdId = adId);
          _appendLog('✅ 插屏广告加载成功，可以展示');
          break;
        } else if (event.eventType == GromoreEventTypes.onAdLoadFailed) {
          _appendLog('❌ 加载失败: ${event.data}');
          break;
        }
      }
    }
  } catch (e) {
    _appendLog('❌ 加载错误: $e');
  }
}

// 展示按钮（仅在广告加载成功后可用）
Future<void> _showInterstitial() async {
  if (_interstitialAdId == null) {
    _appendLog('⚠️ 请先加载插屏广告');
    return;
  }
  
  try {
    await _plugin.showInterstitialFullAd(_interstitialAdId!);
    _appendLog('✅ 展示插屏广告');
    setState(() => _interstitialAdId = null);  // 广告只能展示一次
  } catch (e) {
    _appendLog('❌ 展示错误: $e');
  }
}
```

UI代码：
```dart
Wrap(
  spacing: 8,
  children: <Widget>[
    ElevatedButton(
      onPressed: _loadInterstitial,
      child: const Text('加载插屏'),
    ),
    ElevatedButton(
      onPressed: _interstitialAdId != null ? _showInterstitial : null,
      child: const Text('展示插屏'),
    ),
  ],
)
```

## 其他广告类型也需要修复

同样的问题可能也存在于：
- ✅ 开屏广告 `_loadAndShowSplash`
- ✅ 激励视频广告 `_loadAndShowReward`

建议都使用方案1的模式修复。

## 最佳实践

### 生产环境推荐做法

```dart
class AdManager {
  // 预加载广告
  Future<String?> preloadInterstitialAd() async {
    try {
      final adId = await plugin.loadInterstitialFullAd(request);
      
      // 等待加载完成
      await for (final event in plugin.events) {
        if (event.adId == adId && event.eventType == GromoreEventTypes.onAdLoaded) {
          return adId;  // 返回已加载的adId
        }
        if (event.adId == adId && event.eventType == GromoreEventTypes.onAdLoadFailed) {
          return null;  // 加载失败
        }
      }
    } catch (e) {
      return null;
    }
  }
  
  // 在合适的时机展示
  Future<void> showInterstitialAd(String adId) async {
    await plugin.showInterstitialFullAd(adId);
  }
}

// 使用
// 页面加载时预加载
String? adId = await adManager.preloadInterstitialAd();

// 用户触发某个动作时展示
if (adId != null) {
  await adManager.showInterstitialAd(adId);
}
```

## 调试技巧

### 1. 查看事件日志

在事件日志中观察广告加载流程：
```
[时间] loadInterstitialFullAd -> adId=xxx，等待加载完成...
[时间] 事件 onAdLoaded [type=interstitial, adId=xxx] data=...
[时间] ✅ 插屏广告加载成功，准备展示
[时间] ✅ showInterstitialFullAd(xxx) 已调用
[时间] 事件 onAdShow [type=interstitial, adId=xxx] data=...
```

### 2. 检查常见问题

❌ **问题1：立即调用show**
```dart
final adId = await plugin.loadInterstitialFullAd(request);
await plugin.showInterstitialFullAd(adId);  // ❌ 太快了！
```

❌ **问题2：没有检查onAdLoaded**
```dart
final adId = await plugin.loadInterstitialFullAd(request);
await Future.delayed(Duration(seconds: 2));  // ❌ 固定延迟不可靠
await plugin.showInterstitialFullAd(adId);
```

✅ **正确做法：监听事件**
```dart
final adId = await plugin.loadInterstitialFullAd(request);
// 等待onAdLoaded事件
await plugin.showInterstitialFullAd(adId);
```

### 3. 添加调试日志

```dart
_plugin.events.listen((event) {
  print('广告事件: ${event.eventType}, adType: ${event.adType}, adId: ${event.adId}');
  if (event.eventType == GromoreEventTypes.onAdLoaded) {
    print('✅ 广告加载成功，可以展示');
  } else if (event.eventType == GromoreEventTypes.onAdLoadFailed) {
    print('❌ 广告加载失败: ${event.data}');
  } else if (event.eventType == GromoreEventTypes.onAdShow) {
    print('🎬 广告开始展示');
  }
});
```

## 总结

**核心要点：**
1. ⏳ `loadInterstitialFullAd` 只是发起请求，不等待加载完成
2. 📡 必须监听 `onAdLoaded` 事件确认加载完成
3. ✅ 只有在 `onAdLoaded` 后才能调用 `showInterstitialFullAd`
4. ⏱️ 建议设置超时时间（如5秒）避免无限等待
5. 🔄 考虑使用预加载模式提升用户体验

修改后的代码已经实现了正确的加载→等待→展示流程。
