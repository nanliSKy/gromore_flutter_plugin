<div align="center">

# 🚀 GroMore Flutter Plugin

**Pangle GroMore Mediation Flutter Plugin**

[![pub package](https://img.shields.io/badge/pub-v1.0.0-blue)](https://pub.dev/packages/gromore_flutter_plugin)
[![platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-green)](https://www.csjplatform.com/)
[![license](https://img.shields.io/badge/license-MIT-orange)](LICENSE)

English | [简体中文](README.md)

A powerful and easy-to-integrate Flutter plugin for Pangle GroMore ad mediation, supporting multiple ad formats and networks.

[Quick Start](#-quick-start) • [Features](#-features) • [Installation](#-installation) • [Usage](#-usage-examples) • [FAQ](#-faq) • [Support](#-technical-support)

</div>

---

## 📱 Product Overview

**GroMore** is ByteDance's ad mediation platform, providing developers with one-stop monetization solutions through Pangle ([www.csjplatform.com](https://www.csjplatform.com/)).

### Why Choose GroMore?

<table>
<tr>
<td width="50%">

**💰 Maximize Revenue**
- Multi-platform bidding
- Smart traffic allocation
- Real-time eCPM optimization
- 30%+ fill rate improvement

</td>
<td width="50%">

**🎯 All-in-One Integration**
- Unified SDK integration
- 10+ mainstream ad networks
- No need for multiple SDKs
- 50% less development cost

</td>
</tr>
<tr>
<td>

**📊 Transparent Data**
- Real-time reporting
- Multi-dimensional analytics
- A/B testing support
- Accurate revenue prediction

</td>
<td>

**🛡️ Safe & Compliant**
- Privacy compliance
- Ad quality assurance
- Anti-fraud mechanisms
- Meets international regulations

</td>
</tr>
</table>

### Supported Ad Networks

| Network | Status | Description |
|---------|--------|-------------|
| Pangle | ✅ | ByteDance official ad platform |
| Baidu | ✅ | Leading Chinese ad network |
| GDT | ✅ | Tencent advertising platform |
| Kuaishou | ✅ | Short video ad platform |
| Sigmob | ✅ | Emerging mobile ad network |

---

## ✨ Features

### 🎨 Rich Ad Formats

<table>
<tr>
<td align="center" width="20%">
<img src="images/init.jpg" width="120"/><br/>
<b>Splash Ads</b><br/>
<sub>High exposure, strong branding</sub>
</td>
<td align="center" width="20%">
<img src="images/reward.jpg" width="120"/><br/>
<b>Rewarded Video</b><br/>
<sub>High engagement, strong conversion</sub>
</td>
<td align="center" width="20%">
<img src="images/banner.jpg" width="120"/><br/>
<b>Banner Ads</b><br/>
<sub>Persistent display, stable revenue</sub>
</td>
<td align="center" width="20%">
<b>Native Ads</b><br/>
<sub>Native integration, great UX</sub>
</td>
<td align="center" width="20%">
<b>Interstitial Ads</b><br/>
<sub>Full-screen display, high revenue</sub>
</td>
</tr>
</table>

### 🔧 Core Features

- ✅ **SDK Initialization** - Privacy compliance, debug mode, multi-platform mediation
- ✅ **Splash Ads** - App launch display with countdown and skip button
- ✅ **Rewarded Video** - Watch to earn rewards with custom reward rules
- ✅ **Interstitial Ads** - Immersive full-screen display, portrait/landscape support
- ✅ **Banner Ads** - Fixed-size banner with auto-refresh
- ✅ **Native Ads** - Native ad format with custom rendering
- ✅ **Event Listeners** - Unified ad lifecycle event stream
- ✅ **eCPM Query** - Real-time bidding information
- ✅ **Resource Management** - Auto and manual ad instance destruction
- ✅ **Privacy Compliance** - GDPR, COPPA, CCPA support
- ✅ **Network Trimming** - Enable/disable specific networks to reduce app size

---

## 📦 Installation

### Add Dependency

Add to `pubspec.yaml`:

```yaml
dependencies:
  gromore_flutter_plugin: ^1.0.0
```

Or install via command:

```bash
flutter pub add gromore_flutter_plugin
```

### Android Setup

#### 1. Minimum SDK Version

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 24  // GroMore requires API 24+
    }
}
```

#### 2. Configure Repositories

Add to `android/build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://artifact.bytedance.com/repository/AwemeOpenSDK" }
    }
}
```

#### 3. Network Trimming (Optional)

Configure in `gradle.properties`:

```properties
# Disable unused ad networks to reduce app size
gromore.enableBaidu=false
gromore.enableGdt=false
gromore.enableKs=false
gromore.enableSigmob=false
```

### iOS Setup

#### 1. Minimum Version

```ruby
# ios/Podfile
platform :ios, '12.0'  # GroMore requires iOS 12.0+
```

#### 2. Install Dependencies

```bash
cd ios
pod install
```

---

## 🚀 Quick Start

### 1. Initialize SDK

```dart
import 'package:gromore_flutter_plugin/gromore_flutter_plugin.dart';

final result = await GromoreFlutterPlugin.instance.init(
  const GromoreConfig(
    appId: 'YOUR_APP_ID',
    useMediation: true,
    debug: true,
    privacy: PrivacyConfig(
      limitPersonalAds: false,
      canUseOaid: true,
    ),
  ),
);
```

### 2. Show Splash Ad

```dart
final adId = await GromoreFlutterPlugin.instance.loadSplashAd(
  const SplashAdRequest(slotId: 'YOUR_SPLASH_SLOT_ID'),
);
await GromoreFlutterPlugin.instance.showSplashAd(adId);
```

### 3. Show Rewarded Video

```dart
final adId = await GromoreFlutterPlugin.instance.loadRewardVideoAd(
  const RewardAdRequest(
    slotId: 'YOUR_REWARD_SLOT_ID',
    userId: 'user123',
    rewardName: 'Coins',
    rewardAmount: 100,
  ),
);
await GromoreFlutterPlugin.instance.showRewardVideoAd(adId);
```

### 4. Listen to Events

```dart
GromoreFlutterPlugin.instance.events.listen((event) {
  print('Ad Event: ${event.eventType}');
});
```

---

## 📖 Usage Examples

See [example](example/) directory for complete examples.

---

## ❓ FAQ

<details>
<summary><b>Q: How to get App ID and Slot IDs?</b></summary>

**A:** 
1. Visit [Pangle Platform](https://www.csjplatform.com/)
2. Register and login
3. Create app to get App ID
4. Create ad placements to get Slot IDs
</details>

<details>
<summary><b>Q: How to reduce app size?</b></summary>

**A:** Use network trimming in `gradle.properties`:
```properties
gromore.enableBaidu=false
gromore.enableGdt=false
```
</details>

---

## 🤝 Technical Support

### 📞 Contact Us

<table>
<tr>
<td align="center" width="33%">

**💬 WeChat Support**

<img src="images/wechat.jpg" alt="WeChat QR" width="150"/>

**WeChat ID: Ayiboz**

Add for:
- 🎯 Technical support
- 📚 Integration guidance
- 🐛 Issue resolution
- 💡 Optimization tips

</td>
<td align="center" width="33%">

**📧 Email Support**

nanli0709@foxmail.com

- Business days 9:00-18:00
- 24-hour response
- Professional tech team

</td>
<td align="center" width="33%">

**🌐 Online Resources**

- [Pangle Docs](https://www.csjplatform.com/supportcenter)
- [GitHub Issues](https://github.com/yourusername/gromore_flutter_plugin/issues)
- [Flutter Docs](https://flutter.dev/docs)

</td>
</tr>
</table>

### 💼 Business Cooperation

For custom development or business cooperation, please contact WeChat: **Ayiboz**

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

---

<div align="center">

**If this plugin helps you, please give it a ⭐️ Star!**

**Add WeChat Ayiboz for more technical support!**

Made with ❤️ by Flutter Community

</div>
