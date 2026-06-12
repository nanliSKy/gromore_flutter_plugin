# GroMore 错误码 840040 解决方案

## 错误描述
```
error Code = 840040
error Message = 清理客户端缓存并调整广告请求在SDK初始化成功后；首次冷启动拉取不到配置导致
```

## 问题根源

错误码840040表示在**首次冷启动**时，SDK无法从服务器拉取到广告配置。主要原因：

1. **时序问题**：广告请求在SDK完全初始化之前就发起了
2. **网络问题**：首次启动时网络未就绪，无法获取远程配置
3. **配置缓存**：本地没有缓存的广告配置，完全依赖网络拉取

## 解决方案

### 1. ✅ 确保正确的初始化顺序

**修改前（错误）：**
```dart
Future<void> _initSdk() async {
  final InitResult result = await _plugin.init(config);
  final bool ready = await _plugin.isReady();
  // 立即返回，没有等待配置拉取完成
}

// 用户可能立即点击加载广告按钮
await _loadAndShowSplash(); // ❌ SDK可能还没拉取到配置
```

**修改后（正确）：**
```dart
Future<void> _initSdk() async {
  final InitResult result = await _plugin.init(config);
  
  if (result.success) {
    _appendLog('SDK初始化成功，等待配置拉取...');
    // ⚠️ 关键：等待3-5秒让SDK有时间拉取远程配置
    await Future<void>.delayed(const Duration(seconds: 3));
  }
  
  final bool ready = await _plugin.isReady();
  
  if (ready) {
    _appendLog('✅ SDK已就绪，可以开始加载广告');
  } else {
    _appendLog('⚠️ SDK未就绪，请检查网络连接和配置');
  }
}
```

### 2. ✅ 加载广告前检查SDK就绪状态

```dart
Future<void> _loadAndShowSplash() async {
  // 🔧 加载前检查SDK是否就绪
  if (!_ready) {
    _appendLog('⚠️ SDK未就绪，请先初始化SDK并等待就绪');
    return;
  }
  
  try {
    final String adId = await _plugin.loadSplashAd(request);
    // ...
  } catch (e) {
    // ...
  }
}
```

### 3. ✅ 在Application中提前初始化

对于生产环境，建议在Application启动时就初始化SDK：

**Android原生侧（推荐）：**

```kotlin
// example/android/app/src/main/kotlin/.../MainActivity.kt
class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 提前初始化GroMore SDK
        initGromoreSDK()
    }
    
    private fun initGromoreSDK() {
        val config = TTAdConfig.Builder()
            .appId("YOUR_APP_ID")
            .useMediation(true)
            .debug(true)
            .build()
        
        TTAdSdk.init(this, config, object : TTAdSdk.InitCallback {
            override fun success() {
                Log.d("GroMore", "SDK初始化成功")
            }
            
            override fun fail(code: Int, msg: String) {
                Log.e("GroMore", "SDK初始化失败: $code - $msg")
            }
        })
    }
}
```

### 4. ✅ 清理缓存（如果问题持续）

如果问题持续出现，可能是缓存损坏：

```bash
# 清理应用数据和缓存
adb shell pm clear com.example.gromore_flutter_plugin_example

# 或在设置中清除应用数据
```

### 5. ✅ 检查网络配置

确保网络权限已配置并且设备有网络连接：

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 6. ✅ 验证App ID和Slot ID

确保在穿山甲平台申请的App ID和广告位ID正确：

```dart
const String kAppId = '5836571';  // ⚠️ 必须是真实有效的App ID
const String kSplashSlotId = '104130014';  // ⚠️ 必须是对应类型的广告位ID
```

检查方法：
1. 登录穿山甲平台：https://www.csjplatform.com
2. 进入"应用管理" - "应用列表"
3. 确认App ID
4. 进入"代码位管理"确认各广告位ID和类型

## 最佳实践

### 推荐的初始化流程

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // 显示启动页
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAndWait();
  }
  
  Future<void> _initAndWait() async {
    // 1. 初始化SDK
    final result = await GromoreFlutterPlugin.instance.init(config);
    
    if (result.success) {
      // 2. 等待配置拉取（关键！）
      await Future.delayed(Duration(seconds: 3));
      
      // 3. 验证就绪状态
      final ready = await GromoreFlutterPlugin.instance.isReady();
      
      if (ready) {
        // 4. SDK就绪，跳转到主页
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        // SDK未就绪，显示错误提示
        _showError('SDK未就绪，请检查网络');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

## 测试验证

### 验证步骤

1. **完全卸载应用**（模拟首次安装）
```bash
adb uninstall com.example.gromore_flutter_plugin_example
```

2. **重新安装并运行**
```bash
flutter run
```

3. **观察日志**
```
[时间] SDK初始化成功，等待配置拉取...
[时间] init -> 初始化成功 (isReady=true)
[时间] ✅ SDK已就绪，可以开始加载广告
```

4. **等待3-5秒后再点击广告加载按钮**

### 成功标志

- ✅ 日志显示 `isReady=true`
- ✅ 没有840040错误
- ✅ 广告成功加载并展示
- ✅ 后续冷启动也能正常加载（配置已缓存）

## 常见问题

### Q: 为什么要等待3秒？
A: SDK需要从服务器拉取广告配置（包含各ADN的配置信息、竞价规则等），这个过程需要网络请求时间。3秒是一个经验值，可根据实际网络情况调整。

### Q: 第二次启动还会有840040错误吗？
A: 不会。首次成功后，配置会缓存到本地。后续启动会先使用缓存配置，同时后台更新。

### Q: 生产环境如何处理？
A: 在启动页（Splash Screen）期间完成SDK初始化和等待，用户看到的是加载动画，体验更好。

### Q: 能否缩短等待时间？
A: 可以通过轮询`isReady()`来动态判断：

```dart
// 轮询方式（更灵活）
for (int i = 0; i < 30; i++) { // 最多等待3秒
  await Future.delayed(Duration(milliseconds: 100));
  final ready = await _plugin.isReady();
  if (ready) {
    _appendLog('✅ SDK就绪（用时${i * 100}ms）');
    break;
  }
}
```

## 参考文档

- 穿山甲SDK初始化文档：https://www.csjplatform.com/union/media/union/download/detail?id=195&osType=android
- 错误码查询：https://www.csjplatform.com/supportcenter/5885

## 总结

**核心要点：**
1. ⏱️ SDK初始化后，**必须等待**配置拉取完成
2. ✅ 加载广告前，**必须检查**`isReady()`状态
3. 🚀 生产环境，**建议在启动页**完成初始化
4. 🔄 首次成功后，配置会缓存，后续启动更快

修改后的代码已经实现了这些要点，应该可以解决840040错误。
