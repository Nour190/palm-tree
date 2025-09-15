// lib/core/utils/scale_config.dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Global scaler that clamps ScreenUtil scale factors to avoid explosion on wide desktop screens.
/// Works together with SizeExt (see size_ext.dart).
class ScaleConfig {
  /// Minimum & maximum multipliers (tweak if needed)
  static double minScale = 0.75;
  static double maxScale = 1.25;

  static double _clamped(double value) => value.clamp(minScale, maxScale);

  static double widthScale() => _clamped(ScreenUtil().scaleWidth);
  static double heightScale() => _clamped(ScreenUtil().scaleHeight);
  static double textScale() => _clamped(ScreenUtil().scaleText);

  /// Convert design width -> clamped width in runtime px
  static double sw(double designSize) => designSize * widthScale();

  /// Convert design height -> clamped height in runtime px
  static double sh(double designSize) => designSize * heightScale();

  /// Convert design fontSize -> clamped sp in runtime px
  static double ssp(double fontSize) => fontSize * textScale();

  static void setClamp({double? min, double? max}) {
    if (min != null) minScale = min;
    if (max != null) maxScale = max;
  }
}
