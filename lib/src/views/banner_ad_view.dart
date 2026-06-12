/// Banner 广告 PlatformView 包装组件（Requirements 6.1、6.2、6.8）。
///
/// [BannerAdView] 是一个 [StatefulWidget]，在 Android 上通过 [AndroidView]、在
/// iOS 上通过 [UiKitView] 嵌入原生 Banner 广告视图。视图创建参数
/// （`creationParams`）携带 `adId`、`slotId` 与展示尺寸（`width` / `height`），
/// 由原生层据此加载并嵌入广告（Requirements 6.1）。
///
/// 参数校验策略（Requirements 6.2）：在 Dart 侧对 slotId 非空与尺寸 1–4096 像素
/// 做前置校验。校验失败时**不创建** PlatformView，转而通过 [onAdEvent] 回调一个
/// 携带 `invalid_argument` 错误码的 `onAdLoadFailed` 事件，并渲染一个空占位
/// （[SizedBox]），与原生侧推送参数校验失败事件的行为保持一致。
///
/// 资源释放（Requirements 6.8）：视图 `dispose` 时调用 [GromoreMethodChannel.destroyAd]
/// 释放与该 Banner 关联的原生资源。
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../channel/gromore_channels.dart';
import '../channel/gromore_method_channel.dart';
import '../models/models.dart';
import 'ad_view_support.dart';

/// 在 Flutter 布局中嵌入 GroMore Banner 广告的组件。
class BannerAdView extends StatefulWidget {
  /// 创建一个 [BannerAdView]。
  ///
  /// [methodChannel] 可注入用于测试；缺省时使用默认 [GromoreMethodChannel]。
  const BannerAdView({
    super.key,
    required this.slotId,
    required this.width,
    required this.height,
    this.onAdEvent,
    GromoreMethodChannel? methodChannel,
  }) : _methodChannel = methodChannel;

  /// Banner 聚合广告位标识。
  final String slotId;

  /// 期望的展示宽度（逻辑像素，须在 1–4096 范围内）。
  final double width;

  /// 期望的展示高度（逻辑像素，须在 1–4096 范围内）。
  final double height;

  /// 广告事件回调（展示、点击、关闭，以及参数校验失败）。
  final void Function(AdEvent event)? onAdEvent;

  final GromoreMethodChannel? _methodChannel;

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  late final GromoreMethodChannel _methodChannel;

  /// 本视图实例的唯一 adId；仅在参数校验通过、创建 PlatformView 时分配。
  String? _adId;

  /// Dart 侧参数校验失败信息；非空表示不创建 PlatformView。
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _methodChannel = widget._methodChannel ?? GromoreMethodChannel();

    final String? error = validateBannerParams(
      slotId: widget.slotId,
      width: widget.width,
      height: widget.height,
    );

    if (error != null) {
      _validationError = error;
      // 在首帧结束后回调参数错误事件，避免在 build 期间触发回调。
      final String adId = AdViewIdGenerator.next(GromoreAdTypes.banner);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAdEvent?.call(
          buildInvalidParamsEvent(
            adId: adId,
            adType: GromoreAdTypes.banner,
            message: error,
          ),
        );
      });
      return;
    }

    _adId = AdViewIdGenerator.next(GromoreAdTypes.banner);
  }

  @override
  void dispose() {
    // 视图销毁时释放原生资源（Requirements 6.8）。
    final String? adId = _adId;
    if (adId != null) {
      // 释放失败（如实例已不存在）不应影响视图销毁流程。
      _methodChannel.destroyAd(adId).catchError((Object _) {});
    }
    super.dispose();
  }

  Map<String, dynamic> _creationParams(String adId) {
    return <String, dynamic>{
      'adId': adId,
      'slotId': widget.slotId,
      'width': widget.width,
      'height': widget.height,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_validationError != null || _adId == null) {
      // 参数校验失败：不创建 PlatformView，渲染空占位。
      return const SizedBox.shrink();
    }

    final String adId = _adId!;
    final Map<String, dynamic> params = _creationParams(adId);

    Widget platformView;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        platformView = AndroidView(
          viewType: GromoreViewTypes.banner,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
        break;
      case TargetPlatform.iOS:
        platformView = UiKitView(
          viewType: GromoreViewTypes.banner,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
        break;
      default:
        // 其他平台不支持（Requirements 10.8）：渲染空占位。
        return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: platformView,
    );
  }
}
