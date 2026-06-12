<div align="center">

# 🚀 GroMore Flutter Plugin

**穿山甲 GroMore 聚合广告 Flutter 插件**

[![pub package](https://img.shields.io/badge/pub-v1.0.0-blue)](https://pub.dev/packages/gromore_flutter_plugin)
[![platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-green)](https://www.csjplatform.com/)
[![license](https://img.shields.io/badge/license-MIT-orange)](LICENSE)

[English](README_EN.md) | 简体中文

一款功能强大、易于集成的穿山甲 GroMore 聚合广告 Flutter 插件，支持多种广告形式和多家广告平台。

[快速开始](#-快速开始) • [功能特性](#-功能特性) • [安装配置](#-安装配置) • [使用示例](#-使用示例) • [常见问题](#-常见问题) • [技术支持](#-技术支持)

</div>

---

## 📱 产品介绍

**GroMore** 是字节跳动旗下的广告聚合平台，通过穿山甲（[www.csjplatform.com](https://www.csjplatform.com/)）为开发者提供一站式广告变现解决方案。

### 为什么选择 GroMore？

<table>
<tr>
<td width="50%">

**💰 收益最大化**
- 多平台竞价机制
- 智能流量分配
- 实时 eCPM 优化
- 广告填充率提升 30%+

</td>
<td width="50%">

**🎯 一站式接入**
- 统一 SDK 集成
- 支持 10+ 主流广告平台
- 无需对接多家 SDK
- 降低 50% 开发成本

</td>
</tr>
<tr>
<td>

**📊 数据透明**
- 实时数据报表
- 多维度数据分析
- A/B 测试支持
- 精准收益预测

</td>
<td>

**🛡️ 安全合规**
- 隐私合规配置
- 广告质量保障
- 防作弊机制
- 符合各国法规要求

</td>
</tr>
</table>

### 支持的广告平台

| 平台 | 状态 | 说明 |
|------|------|------|
| 穿山甲（Pangle） | ✅ | 字节跳动官方广告平台 |
| 百度（Baidu） | ✅ | 国内主流广告平台 |
| 优量汇（GDT） | ✅ | 腾讯广告平台 |
| 快手（Kuaishou） | ✅ | 短视频广告平台 |
| Sigmob | ✅ | 新兴移动广告平台 |

---

## ✨ 功能特性

### 🎨 丰富的广告形式

<table>
<tr>
<td align="center" width="20%">
<img src="images/init.jpg" width="120"/><br/>
<b>开屏广告</b><br/>
<sub>高曝光，强品牌</sub>
</td>
<td align="center" width="20%">
<img src="images/reward.jpg" width="120"/><br/>
<b>激励视频</b><br/>
<sub>高互动，强转化</sub>
</td>
<td align="center" width="20%">
<img src="images/banner.jpg" width="120"/><br/>
<b>Banner 广告</b><br/>
<sub>常驻展示，稳定收益</sub>
</td>
<td align="center" width="20%">
<b>信息流广告</b><br/>
<sub>原生融合，用户体验好</sub>
</td>
<td align="center" width="20%">
<b>插全屏广告</b><br/>
<sub>强制展示，高收益</sub>
</td>
</tr>
</table>

### 🔧 核心功能

- ✅ **SDK 初始化** - 支持隐私合规配置、调试模式、多平台聚合
- ✅ **开屏广告** - 应用启动时展示，支持倒计时、跳过按钮
- ✅ **激励视频** - 完整观看获得奖励，支持自定义奖励规则
- ✅ **插全屏广告** - 沉浸式全屏展示，支持横竖屏
- ✅ **Banner 广告** - 固定尺寸横幅广告，支持自动刷新
- ✅ **信息流广告** - 原生广告样式，支持自定义渲染
- ✅ **事件监听** - 统一的广告生命周期事件流
- ✅ **eCPM 查询** - 实时获取广告竞价信息
- ✅ **资源管理** - 自动和手动销毁广告实例
- ✅ **隐私合规** - 支持 GDPR、COPPA、CCPA 等隐私法规
- ✅ **ADN 裁剪** - 按需启用/禁用特定广告平台，减小包体积

### 🎯 技术优势

| 特性 | 说明 |
|------|------|
| 🚀 **高性能** | 异步加载，不阻塞主线程 |
| 🔄 **热更新** | 支持远程配置更新 |
| 📦 **模块化** | 按需集成，灵活裁剪 |
| 🛠️ **易调试** | 完善的日志系统 |
| 📱 **跨平台** | Android & iOS 统一 API |
| 🔒 **类型安全** | 强类型接口，减少错误 |

---

## 📦 安装配置

### 添加依赖

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  gromore_flutter_plugin: ^1.0.0
```

或使用命令安装：

```bash
flutter pub add gromore_flutter_plugin
```

### Android 配置

#### 1. 最低 SDK 要求

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 24  // GroMore 要求最低 API 24
    }
}
```

#### 2. 配置仓库

在 `android/build.gradle` 中添加：

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://artifact.bytedance.com/repository/AwemeOpenSDK" }
    }
}
```

#### 3. 添加权限

在 `AndroidManifest.xml` 中添加必要权限：

```xml
<!-- 必需权限 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- 可选权限（提升广告投放精准度） -->
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### 4. 裁剪 ADN（可选）

在 `gradle.properties` 中配置：

```properties
# 禁用不需要的广告平台，减小包体积
gromore.enableBaidu=false     # 禁用百度
gromore.enableGdt=false       # 禁用优量汇
gromore.enableKs=false        # 禁用快手
gromore.enableSigmob=false    # 禁用 Sigmob
```

### iOS 配置

#### 1. 最低版本要求

```ruby
# ios/Podfile
platform :ios, '12.0'  # GroMore 要求 iOS 12.0+
```

#### 2. 安装依赖

```bash
cd ios
pod install
```

#### 3. 添加权限说明

在 `Info.plist` 中添加：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<!-- 可选：访问相册（用于保存广告素材） -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>保存广告图片到相册</string>
```

---

## 🚀 快速开始

### 1. 初始化 SDK

```dart
import 'package:gromore_flutter_plugin/gromore_flutter_plugin.dart';

// 初始化 SDK
final result = await GromoreFlutterPlugin.instance.init(
  const GromoreConfig(
    appId: 'YOUR_APP_ID',           // 穿山甲平台申请的 App ID
    useMediation: true,              // 启用聚合功能
    debug: true,                     // 开发阶段开启调试
    privacy: PrivacyConfig(
      limitPersonalAds: false,       // 是否限制个性化广告
      canUseOaid: true,              // 是否使用 OAID
    ),
  ),
);

if (result.success) {
  print('✅ SDK 初始化成功');
} else {
  print('❌ SDK 初始化失败: ${result.errorMessage}');
}
```

<img src="images/init.jpg" width="250" alt="SDK 初始化"/>

### 2. 展示开屏广告

```dart
// 加载开屏广告
final adId = await GromoreFlutterPlugin.instance.loadSplashAd(
  const SplashAdRequest(
    slotId: 'YOUR_SPLASH_SLOT_ID',
    timeoutMs: 5000,
  ),
);

// 展示开屏广告
await GromoreFlutterPlugin.instance.showSplashAd(adId);
```

### 3. 展示激励视频

```dart
// 加载激励视频
final adId = await GromoreFlutterPlugin.instance.loadRewardVideoAd(
  const RewardAdRequest(
    slotId: 'YOUR_REWARD_SLOT_ID',
    userId: 'user123',              // 用户 ID
    rewardName: '金币',             // 奖励名称
    rewardAmount: 100,               // 奖励数量
  ),
);

// 展示激励视频
await GromoreFlutterPlugin.instance.showRewardVideoAd(adId);
```

<img src="images/reward.jpg" width="250" alt="激励视频广告"/>

### 4. 展示 Banner 广告

```dart
BannerAdView(
  slotId: 'YOUR_BANNER_SLOT_ID',
  width: 320,
  height: 50,
  onAdEvent: (event) {
    print('Banner 事件: ${event.eventType}');
  },
)
```

<img src="images/banner.jpg" width="250" alt="Banner 广告"/>

### 5. 展示信息流广告

```dart
final controller = FeedAdController();

FeedAdView(
  slotId: 'YOUR_FEED_SLOT_ID',
  width: 350,
  height: 250,
  controller: controller,
  onAdEvent: (event) {
    print('信息流事件: ${event.eventType}');
  },
)

// 用户不感兴趣时
controller.dislike();
```

### 6. 监听广告事件

```dart
GromoreFlutterPlugin.instance.events.listen((event) {
  switch (event.eventType) {
    case GromoreEventTypes.onAdLoaded:
      print('✅ 广告加载成功: ${event.adId}');
      break;
    case GromoreEventTypes.onAdLoadFailed:
      print('❌ 广告加载失败: ${event.data}');
      break;
    case GromoreEventTypes.onAdClicked:
      print('👆 广告被点击');
      break;
    case GromoreEventTypes.onRewardVerify:
      print('🎁 激励验证成功: ${event.data}');
      // 发放奖励给用户
      break;
  }
});
```

---

## 📖 使用示例

完整的示例代码请查看 [example](example/) 目录。

### 运行示例应用

```bash
# 克隆仓库
git clone https://github.com/yourusername/gromore_flutter_plugin.git

# 进入示例目录
cd gromore_flutter_plugin/example

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 核心功能演示

示例应用包含以下功能演示：

- ✅ SDK 初始化与配置
- ✅ 开屏广告加载与展示
- ✅ 激励视频广告
- ✅ 插全屏广告
- ✅ Banner 广告
- ✅ 信息流广告
- ✅ 事件监听与日志
- ✅ eCPM 信息查询
- ✅ 广告资源管理

---

## 🔧 高级用法

### 获取广告竞价信息

```dart
final info = await GromoreFlutterPlugin.instance.getEcoCpmInfo(adId);
print('广告平台: ${info.adnName}');
print('竞价价格: ${info.ecpm}');
print('广告位ID: ${info.slotId}');
```

### 手动销毁广告

```dart
await GromoreFlutterPlugin.instance.destroyAd(adId);
```

### 更新隐私配置

```dart
await GromoreFlutterPlugin.instance.setPrivacyConfig(
  const PrivacyConfig(
    limitPersonalAds: true,
    canUseOaid: false,
  ),
);
```

### 查询 SDK 就绪状态

```dart
final isReady = await GromoreFlutterPlugin.instance.isReady();
if (isReady) {
  // SDK 已就绪，可以加载广告
}
```

---

## ❓ 常见问题

<details>
<summary><b>Q: 如何获取穿山甲 App ID 和广告位 ID？</b></summary>

**A:** 
1. 访问 [穿山甲平台](https://www.csjplatform.com/)
2. 注册并登录开发者账号
3. 创建应用获取 App ID
4. 创建广告位获取各类型广告位 ID
</details>

<details>
<summary><b>Q: Android 编译报错 "Could not find open_ad_sdk.aar"</b></summary>

**A:** 确保在 `android/build.gradle` 中配置了正确的仓库：
```gradle
maven { url "https://artifact.bytedance.com/repository/AwemeOpenSDK" }
```
</details>

<details>
<summary><b>Q: iOS 编译失败怎么办？</b></summary>

**A:** 
1. 确保 iOS 版本 >= 12.0
2. 清理缓存：`cd ios && pod cache clean --all && pod install`
3. 更新 CocoaPods：`sudo gem install cocoapods`
</details>

<details>
<summary><b>Q: 广告加载失败，显示错误码？</b></summary>

**A:** 常见原因：
- 广告位 ID 不正确
- SDK 未初始化完成
- 网络连接问题
- 广告填充率低（测试阶段）
- 应用未通过审核

建议开启 `debug: true` 查看详细日志。
</details>

<details>
<summary><b>Q: 如何减小应用包体积？</b></summary>

**A:** 使用 ADN 裁剪功能，在 `gradle.properties` 中禁用不需要的广告平台：
```properties
gromore.enableBaidu=false
gromore.enableGdt=false
```
</details>

<details>
<summary><b>Q: 隐私合规如何配置？</b></summary>

**A:** 根据目标市场配置隐私选项：
```dart
const PrivacyConfig(
  limitPersonalAds: true,    // GDPR - 限制个性化广告
  canUseOaid: false,         // 禁用 OAID
  canUseLocation: false,     // 禁用位置信息
)
```
</details>

---

## 📊 性能优化建议

### 1. 预加载广告

```dart
// 在合适的时机预加载，提高展示速度
await _preloadAds();
```

### 2. 广告缓存

```dart
// 保持 2-3 个广告实例，循环使用
final adPool = <String>[];
```

### 3. 内存管理

```dart
// 及时销毁不再使用的广告
await GromoreFlutterPlugin.instance.destroyAd(adId);
```

### 4. 事件优化

```dart
// 使用单一订阅，避免内存泄漏
final subscription = GromoreFlutterPlugin.instance.events.listen(...);
// 页面销毁时取消订阅
subscription.cancel();
```

---

## 🛣️ 开发计划

- [ ] 支持更多广告平台（AdMob、Unity Ads）
- [ ] 添加 WebView 广告支持
- [ ] 提供广告测试工具
- [ ] 增加更多示例场景
- [ ] 支持自定义广告样式
- [ ] 添加 A/B 测试功能

---

## 📄 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

---

## 🤝 技术支持

### 📞 联系方式

<table>
<tr>
<td align="center" width="33%">

**💬 微信咨询**

<img src="images/wechat.jpg" alt="微信二维码" width="150"/>

**微信号：Ayiboz**

扫码添加好友，获取：
- 🎯 技术支持
- 📚 集成指导
- 🐛 问题解答
- 💡 优化建议

</td>
<td align="center" width="33%">

**📧 邮件支持**

nanli0709@foxmail.com

- 工作日 9:00-18:00
- 24 小时内响应
- 专业技术团队

</td>
<td align="center" width="33%">

**🌐 在线资源**

- [穿山甲官方文档](https://www.csjplatform.com/supportcenter)
- [GitHub Issues](https://github.com/yourusername/gromore_flutter_plugin/issues)
- [Flutter 文档](https://flutter.dev/docs)

</td>
</tr>
</table>

### 🆘 获取帮助

遇到问题？我们提供多种支持方式：

1. **微信一对一咨询**（推荐）
   - 添加微信：**Ayiboz**
   - 备注：GroMore 插件咨询
   - 获得快速响应和专业指导

2. **提交 Issue**
   - [GitHub Issues](https://github.com/yourusername/gromore_flutter_plugin/issues)
   - 详细描述问题和复现步骤
   - 附上相关日志和配置

3. **查阅文档**
   - [插件文档](docs/)
   - [穿山甲官方文档](https://www.csjplatform.com/supportcenter)
   - [常见问题解答](#-常见问题)

### 💼 商业合作

如需定制开发、技术培训或商业合作，请添加微信 **Ayiboz** 详谈。

---

## 🌟 贡献指南

欢迎提交 Issue 和 Pull Request！

### 参与贡献

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

### 贡献者

感谢所有贡献者的付出！

<a href="https://github.com/yourusername/gromore_flutter_plugin/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=yourusername/gromore_flutter_plugin" />
</a>

---

## 📈 项目统计

![GitHub stars](https://img.shields.io/github/stars/yourusername/gromore_flutter_plugin?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/gromore_flutter_plugin?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/yourusername/gromore_flutter_plugin?style=social)

---

## 🙏 鸣谢

- [字节跳动穿山甲](https://www.csjplatform.com/) - 提供优质的广告聚合服务
- [Flutter 团队](https://flutter.dev/) - 优秀的跨平台框架
- 所有贡献者和使用者

---

<div align="center">

**如果这个插件对你有帮助，请给个 ⭐️ Star 支持一下！**

**添加微信 Ayiboz 获取更多技术支持！**

Made with ❤️ by Flutter Community

</div>

