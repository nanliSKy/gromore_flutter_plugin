# Android 原生依赖 .aar 放置说明

`android/build.gradle` 通过 `flatDir { dirs "libs", "libs/adn", "libs/adapter" }` 打包以下
工作区现有 `.aar`。请将文件按下述路径放置（本目录已由构建配置引用）。

> 注意：以下 .aar 体积较大，需手动拷贝（自动化环境的 shell 拷贝被禁用）。
> 源目录：`android/adapter_list_1780907022/`

## libs/（核心 SDK）
- open_ad_sdk.aar
  - 源：`android/adapter_list_1780907022/demo/app/libs/open_ad_sdk.aar`

## libs/adn/（各 ADN SDK）
- Baidu_MobAds_SDK_v9.4503.aar
- GDTSDK.unionNormal.4.680.1550.aar
- kssdk-ad-5.3.20.1.aar
- windAd-4.25.14.aar
- windAd-common-2.0.1.aar
  - 源：`android/adapter_list_1780907022/adn/*.aar`

## libs/adapter/（聚合适配器）
- mediation_baidu_adapter_9.4503.0.aar
- mediation_gdt_adapter_4.680.1550.0.aar
- mediation_ks_adapter_5.3.20.1.0.aar
- mediation_sigmob_adapter_4.25.14.0.aar
  - 源：`android/adapter_list_1780907022/adapter/*.aar`

## 拷贝命令（Windows PowerShell，从工作区根目录执行）

```powershell
$base = "android\adapter_list_1780907022"
$dst  = "gromore_flutter_plugin\android\libs"
New-Item -ItemType Directory -Force -Path $dst, "$dst\adn", "$dst\adapter" | Out-Null
Copy-Item "$base\demo\app\libs\open_ad_sdk.aar" "$dst\open_ad_sdk.aar" -Force
Copy-Item "$base\adn\*.aar" "$dst\adn\" -Force
Copy-Item "$base\adapter\*.aar" "$dst\adapter\" -Force
```

## 按需 ADN 开关
见 `android/gradle.properties`：`gromore.enableBaidu` / `gromore.enableGdt` /
`gromore.enableKs` / `gromore.enableSigmob`（默认全部 `true`）。
禁用某 ADN 时，其对应的 ADN SDK 与适配器 .aar 不会被纳入构建，但仍需保留文件在 libs
目录中（flatDir 仅在被 `implementation` 引用时才打包）。
