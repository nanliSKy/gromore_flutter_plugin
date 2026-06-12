/// PlatformView 包装组件（Banner / Feed）的内部支撑工具。
///
/// 本文件为 `lib/src/views/` 内部使用，不对外导出。集中放置：
/// - 每个视图实例的唯一 `adId` 生成（Requirements 8.1）；
/// - Banner / Feed 的 Dart 侧参数校验（尺寸 1–4096 像素、feed slotId 1–64，
///   Requirements 6.2、7.2）；
/// - 校验失败时构造统一的参数错误 [AdEvent]。
library;

import '../channel/gromore_channels.dart';
import '../models/models.dart';

/// PlatformView 展示尺寸允许的最小逻辑像素（含端点）。
const double kGromoreMinViewDimension = 1.0;

/// PlatformView 展示尺寸允许的最大逻辑像素（含端点）。
const double kGromoreMaxViewDimension = 4096.0;

/// Feed slotId 允许的最小长度（含端点）。
const int kGromoreFeedSlotIdMinLength = 1;

/// Feed slotId 允许的最大长度（含端点）。
const int kGromoreFeedSlotIdMaxLength = 64;

/// 为 PlatformView 包装组件分配在插件运行生命周期内唯一的 `adId`。
///
/// 采用 `"<adType>-<递增序号>"` 的形式（如 `banner-1`、`feed-2`），保证同一插件
/// 运行周期内两两互不相同（Requirements 8.1）。该标识符在视图创建参数中下发给
/// 原生层，并用于 `dispose` 时的 `destroyAd` 与 feed 的 `feedDislike` 路由。
class AdViewIdGenerator {
  AdViewIdGenerator._();

  static int _counter = 0;

  /// 生成一个带 [adType] 前缀的唯一 `adId`。
  static String next(String adType) {
    _counter += 1;
    return '$adType-$_counter';
  }
}

/// 校验某一展示尺寸值是否落在 [kGromoreMinViewDimension] 到
/// [kGromoreMaxViewDimension] 的闭区间内（拒绝 NaN / 无穷大）。
bool isValidViewDimension(double value) {
  if (value.isNaN || value.isInfinite) {
    return false;
  }
  return value >= kGromoreMinViewDimension && value <= kGromoreMaxViewDimension;
}

/// 校验 Banner 参数。
///
/// 返回 `null` 表示校验通过；否则返回可读的错误信息（Requirements 6.2）：
/// - slotId 必须非空；
/// - width、height 必须在 1–4096 像素范围内。
String? validateBannerParams({
  required String slotId,
  required double width,
  required double height,
}) {
  if (slotId.isEmpty) {
    return 'Banner slotId must not be empty.';
  }
  if (!isValidViewDimension(width)) {
    return 'Banner width must be within $kGromoreMinViewDimension–$kGromoreMaxViewDimension px, got $width.';
  }
  if (!isValidViewDimension(height)) {
    return 'Banner height must be within $kGromoreMinViewDimension–$kGromoreMaxViewDimension px, got $height.';
  }
  return null;
}

/// 校验 Feed 参数。
///
/// 返回 `null` 表示校验通过；否则返回可读的错误信息（Requirements 7.2）：
/// - slotId 长度必须在 1–64 个字符范围内；
/// - width、height 必须在 1–4096 像素范围内。
String? validateFeedParams({
  required String slotId,
  required double width,
  required double height,
}) {
  if (slotId.length < kGromoreFeedSlotIdMinLength || slotId.length > kGromoreFeedSlotIdMaxLength) {
    return 'Feed slotId length must be within $kGromoreFeedSlotIdMinLength–$kGromoreFeedSlotIdMaxLength characters, got ${slotId.length}.';
  }
  if (!isValidViewDimension(width)) {
    return 'Feed width must be within $kGromoreMinViewDimension–$kGromoreMaxViewDimension px, got $width.';
  }
  if (!isValidViewDimension(height)) {
    return 'Feed height must be within $kGromoreMinViewDimension–$kGromoreMaxViewDimension px, got $height.';
  }
  return null;
}

/// 构造一个表示参数校验失败的加载失败 [AdEvent]。
///
/// 事件类型为 [GromoreEventTypes.onAdLoadFailed]，`data` 携带错误码
/// [GromoreErrorCodes.invalidArgument] 与可读 [message]，与原生侧推送的参数
/// 校验失败事件结构保持一致（Requirements 6.2、7.2）。
AdEvent buildInvalidParamsEvent({
  required String adId,
  required String adType,
  required String message,
}) {
  return AdEvent(
    eventType: GromoreEventTypes.onAdLoadFailed,
    adId: adId,
    adType: adType,
    data: <String, dynamic>{
      'errorCode': GromoreErrorCodes.invalidArgument,
      'errorMessage': message,
    },
  );
}

/// PlatformView 创建参数中携带的广告类型常量。
class GromoreAdTypes {
  GromoreAdTypes._();

  /// Banner 广告类型标识。
  static const String banner = 'banner';

  /// 信息流/原生广告类型标识。
  static const String feed = 'feed';
}
