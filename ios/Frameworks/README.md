# iOS 原生依赖 framework / bundle 放置说明

`gromore_flutter_plugin.podspec` 通过 `vendored_frameworks` 与 `resources` 打包以下
工作区现有的 `.xcframework` 与资源 `.bundle`。请将文件按下述路径放置到本目录
（`ios/Frameworks/`，podspec 已按这些路径引用）。

> 注意：以下 framework 体积较大，需手动拷贝（自动化环境的 shell 拷贝被禁用）。
> 源目录：`ios/union_platform_iOS_7.6.0.4/`

## 核心 SDK（默认 subspec `Core`，始终引入）

放入 `ios/Frameworks/`：

| 文件 | 源路径 |
|------|--------|
| `BUAdSDK.xcframework` | `ios/union_platform_iOS_7.6.0.4/SDK/BUAdSDK.xcframework` |
| `CSJMediation.xcframework` | `ios/union_platform_iOS_7.6.0.4/SDK/CSJMediation.xcframework` |
| `BUAdTestMeasurement.xcframework` | `ios/union_platform_iOS_7.6.0.4/SDK/BUAdTestMeasurement.xcframework` |
| `CSJAdSDK.bundle` | `ios/union_platform_iOS_7.6.0.4/SDK/CSJAdSDK.bundle` |
| `BUAdTestMeasurement.bundle` | `ios/union_platform_iOS_7.6.0.4/SDK/BUAdTestMeasurement.bundle` |

## ADN 适配器 framework（按需 subspec）

放入 `ios/Frameworks/`（每个适配器对应一个 podspec subspec，详见下方表格）：

| 文件 | 源路径 | subspec |
|------|--------|---------|
| `CSJMBaiduAdapter.xcframework` | `ios/union_platform_iOS_7.6.0.4/SDKs/CSJMBaiduAdapter_10.050.0/CSJMBaiduAdapter.xcframework` | `Baidu` |
| `CSJMGdtAdapter.xcframework` | `ios/union_platform_iOS_7.6.0.4/SDKs/CSJMGdtAdapter_4.15.80.0/CSJMGdtAdapter.xcframework` | `GDT` |
| `CSJMKsAdapter.xcframework` | `ios/union_platform_iOS_7.6.0.4/SDKs/CSJMKsAdapter_5.3.20.1.0/CSJMKsAdapter.xcframework` | `KS` |
| `CSJMSigmobAdapter.xcframework` | `ios/union_platform_iOS_7.6.0.4/SDKs/CSJMSigmobAdapter_4.20.10.0/CSJMSigmobAdapter.xcframework` | `Sigmob` |

## 拷贝命令（Windows PowerShell，从工作区根目录执行）

```powershell
$base = "ios\union_platform_iOS_7.6.0.4"
$dst  = "gromore_flutter_plugin\ios\Frameworks"
New-Item -ItemType Directory -Force -Path $dst | Out-Null

# 核心 SDK + 资源 bundle
Copy-Item "$base\SDK\BUAdSDK.xcframework"             $dst -Recurse -Force
Copy-Item "$base\SDK\CSJMediation.xcframework"        $dst -Recurse -Force
Copy-Item "$base\SDK\BUAdTestMeasurement.xcframework" $dst -Recurse -Force
Copy-Item "$base\SDK\CSJAdSDK.bundle"                 $dst -Recurse -Force
Copy-Item "$base\SDK\BUAdTestMeasurement.bundle"      $dst -Recurse -Force

# ADN 适配器
Copy-Item "$base\SDKs\CSJMBaiduAdapter_10.050.0\CSJMBaiduAdapter.xcframework"   $dst -Recurse -Force
Copy-Item "$base\SDKs\CSJMGdtAdapter_4.15.80.0\CSJMGdtAdapter.xcframework"      $dst -Recurse -Force
Copy-Item "$base\SDKs\CSJMKsAdapter_5.3.20.1.0\CSJMKsAdapter.xcframework"       $dst -Recurse -Force
Copy-Item "$base\SDKs\CSJMSigmobAdapter_4.20.10.0\CSJMSigmobAdapter.xcframework" $dst -Recurse -Force
```

macOS / Linux 等价命令见同目录下 `copy_frameworks.sh`。

## 按需 ADN 选择机制（podspec subspec，Req 11.4 / 11.5）

`gromore_flutter_plugin.podspec` 使用 subspec 实现 ADN 粒度的启用/禁用：

- `Core`：核心 BUAdSDK + CSJMediation + BUAdTestMeasurement（始终引入）。
- `Baidu` / `GDT` / `KS` / `Sigmob`：各家 ADN 的 Pod 依赖 + 对应 `CSJM*Adapter.xcframework`。

`s.default_subspecs` 默认包含全部 4 家 ADN（`Baidu`、`GDT`、`KS`、`Sigmob`），
即默认启用全部受支持 ADN（Req 11.4）。

集成方若仅需部分 ADN，可在自身工程的 `Podfile` 中显式指定 subspec 子集来覆盖默认值，例如仅启用百度与优量汇：

```ruby
pod 'gromore_flutter_plugin', :path => '...', :subspecs => ['Baidu', 'GDT']
```

此时其余 ADN（KS / Sigmob）的 ADN Pod 与适配器 framework 不会纳入构建产物，
不影响已启用 ADN（Req 11.5）。注意：未被任何已选 subspec 引用的 `CSJM*Adapter.xcframework`
即使存在于本目录也不会被打包（CocoaPods 仅打包被 subspec 引用的 vendored_frameworks）。

> 各 ADN 的三方 SDK（`BaiduMobAdSDK` / `GDTMobSDK` / `SigmobAd-iOS` / `KSAdSDK`）
> 通过 CocoaPods 远端仓库以固定版本拉取，无需手动拷贝。
