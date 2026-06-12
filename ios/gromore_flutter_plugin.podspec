#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint gromore_flutter_plugin.podspec` to validate before publishing.
#
# 依赖自包含（Req 11.3 / 11.4 / 11.5）：
#   - 核心 subspec `Core` 通过 vendored_frameworks 直接 vendoring 工作区现有的
#     BUAdSDK / CSJMediation / BUAdTestMeasurement .xcframework 与资源 bundle，
#     集成方无需手动添加任何原生 framework。
#   - 每家 ADN（百度 / 优量汇GDT / 快手KS / Sigmob）对应一个 subspec，声明该 ADN 的
#     三方 SDK Pod 依赖与对应 CSJM*Adapter.xcframework。
#   - `default_subspecs` 默认包含全部 4 家 ADN，即默认启用全部受支持 ADN（Req 11.4）。
#     集成方可在自身 Podfile 中显式指定 :subspecs => [...] 子集来按需裁剪（Req 11.5），例如：
#       pod 'gromore_flutter_plugin', :path => '...', :subspecs => ['Baidu', 'GDT']
#   - 所需的 .xcframework / .bundle 放置说明见 Frameworks/README.md。
#
Pod::Spec.new do |s|
  s.name             = 'gromore_flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin wrapping the CSJ/Pangle GroMore mediation SDK.'
  s.description      = <<-DESC
A Flutter plugin that wraps the CSJ/Pangle GroMore mediation SDK (BUAdSDK + CSJMediation)
and its ADN adapters (Baidu / GDT / KS / Sigmob) on Android and iOS.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  # GroMore SDK 最低支持 iOS 10.0；但 Flutter 工程通常要求更高。
  # 这里采用 11.0 作为兼顾两者的折中下限（如集成方 Flutter 版本要求 12.0，可在
  # 自身工程 Podfile 的 platform :ios 处提升，不影响本插件 vendoring）。
  s.platform = :ios, '11.0'
  s.swift_version = '5.0'

  # Flutter.framework / 各 vendored 静态 framework 均不包含 i386 模拟器切片。
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64',
    'CODE_SIGNING_ALLOWED' => 'NO'
  }
  s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64'
  }

  s.requires_arc = true

  # 默认启用全部受支持 ADN（Req 11.4）。集成方可覆盖 :subspecs 以按需裁剪（Req 11.5）。
  s.default_subspecs = ['Baidu', 'GDT', 'KS', 'Sigmob']

  # ---------------------------------------------------------------------------
  # Core：插件原生代码 + GroMore 核心 SDK（始终引入，被各 ADN subspec 依赖）
  # ---------------------------------------------------------------------------
  s.subspec 'Core' do |ss|
    ss.source_files = 'Classes/**/*'
    ss.dependency 'Flutter'

    # 工作区现有核心 .xcframework（放置说明见 Frameworks/README.md）
    ss.vendored_frameworks = [
      'Frameworks/BUAdSDK.xcframework',
      'Frameworks/CSJMediation.xcframework',
      'Frameworks/BUAdTestMeasurement.xcframework'
    ]

    # SDK 资源 bundle
    ss.resources = [
      'Frameworks/CSJAdSDK.bundle',
      'Frameworks/BUAdTestMeasurement.bundle'
    ]

    # 系统 framework / library（参照 BUDemoSource.podspec）
    ss.frameworks = 'UIKit', 'MapKit', 'WebKit', 'MediaPlayer', 'CoreLocation',
                    'AdSupport', 'CoreMedia', 'AVFoundation', 'CoreTelephony',
                    'StoreKit', 'SystemConfiguration', 'MobileCoreServices',
                    'CoreMotion', 'Accelerate', 'AudioToolbox', 'JavaScriptCore',
                    'Security', 'CoreImage', 'ImageIO', 'QuartzCore',
                    'CoreGraphics', 'CoreText'
    ss.weak_frameworks = 'AppTrackingTransparency', 'DeviceCheck', 'CoreML', 'CoreHaptics'
    ss.libraries = 'c++', 'resolv', 'z', 'sqlite3', 'bz2', 'xml2', 'iconv', 'c++abi'
  end

  # ---------------------------------------------------------------------------
  # 百度 ADN（subspec 'Baidu'）
  # ---------------------------------------------------------------------------
  s.subspec 'Baidu' do |ss|
    ss.dependency 'gromore_flutter_plugin/Core'
    ss.dependency 'BaiduMobAdSDK', '10.050'
    ss.vendored_frameworks = 'Frameworks/CSJMBaiduAdapter.xcframework'
  end

  # ---------------------------------------------------------------------------
  # 优量汇 GDT ADN（subspec 'GDT'）
  # ---------------------------------------------------------------------------
  s.subspec 'GDT' do |ss|
    ss.dependency 'gromore_flutter_plugin/Core'
    ss.dependency 'GDTMobSDK', '4.15.80'
    ss.vendored_frameworks = 'Frameworks/CSJMGdtAdapter.xcframework'
  end

  # ---------------------------------------------------------------------------
  # 快手 KS ADN（subspec 'KS'）
  # ---------------------------------------------------------------------------
  s.subspec 'KS' do |ss|
    ss.dependency 'gromore_flutter_plugin/Core'
    ss.dependency 'KSAdSDK', '5.3.20.1'
    ss.vendored_frameworks = 'Frameworks/CSJMKsAdapter.xcframework'
  end

  # ---------------------------------------------------------------------------
  # Sigmob ADN（subspec 'Sigmob'）
  # ---------------------------------------------------------------------------
  s.subspec 'Sigmob' do |ss|
    ss.dependency 'gromore_flutter_plugin/Core'
    ss.dependency 'SigmobAd-iOS', '4.20.10'
    ss.vendored_frameworks = 'Frameworks/CSJMSigmobAdapter.xcframework'
  end

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'gromore_flutter_plugin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
