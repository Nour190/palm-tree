import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RTLHelper {
  /// Check if current locale is RTL
  static bool isRTL(BuildContext context) {
    return context.locale.languageCode == 'ar';
  }

  /// Get text direction based on current locale
  static TextDirection getTextDirection(BuildContext context) {
    return isRTL(context) ? TextDirection.RTL : TextDirection.LTR;
  }

  /// Get appropriate EdgeInsets for RTL support
  static EdgeInsetsDirectional getDirectionalPadding({
    double start = 0.0,
    double top = 0.0,
    double end = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsetsDirectional.fromSTEB(start, top, end, bottom);
  }

  /// Get appropriate EdgeInsets for RTL support (all sides)
  static EdgeInsetsDirectional getDirectionalPaddingAll(double value) {
    return EdgeInsetsDirectional.all(value);
  }

  /// Get appropriate EdgeInsets for RTL support (horizontal)
  static EdgeInsetsDirectional getDirectionalPaddingHorizontal(double value) {
    return EdgeInsetsDirectional.symmetric(horizontal: value);
  }

  /// Get appropriate EdgeInsets for RTL support (vertical)
  static EdgeInsetsDirectional getDirectionalPaddingVertical(double value) {
    return EdgeInsetsDirectional.symmetric(vertical: value);
  }

  /// Get appropriate Alignment for RTL support
  static AlignmentDirectional getDirectionalAlignment({
    required double start,
    required double y,
  }) {
    return AlignmentDirectional(start, y);
  }

  /// Common directional alignments
  static AlignmentDirectional get centerStart => AlignmentDirectional.centerStart;
  static AlignmentDirectional get centerEnd => AlignmentDirectional.centerEnd;
  static AlignmentDirectional get topStart => AlignmentDirectional.topStart;
  static AlignmentDirectional get topEnd => AlignmentDirectional.topEnd;
  static AlignmentDirectional get bottomStart => AlignmentDirectional.bottomStart;
  static AlignmentDirectional get bottomEnd => AlignmentDirectional.bottomEnd;

  /// Get mirrored icon for RTL languages
  static Widget getMirroredIcon(
    BuildContext context,
    IconData icon, {
    double? size,
    Color? color,
  }) {
    return Transform(
      alignment: Alignment.center,
      transform: isRTL(context) ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
      child: Icon(icon, size: size, color: color),
    );
  }

  /// Get appropriate MainAxisAlignment for RTL
  static MainAxisAlignment getDirectionalMainAxisAlignment(
    BuildContext context,
    MainAxisAlignment alignment,
  ) {
    if (!isRTL(context)) return alignment;
    
    switch (alignment) {
      case MainAxisAlignment.start:
        return MainAxisAlignment.end;
      case MainAxisAlignment.end:
        return MainAxisAlignment.start;
      default:
        return alignment;
    }
  }

  /// Get appropriate CrossAxisAlignment for RTL
  static CrossAxisAlignment getDirectionalCrossAxisAlignment(
    BuildContext context,
    CrossAxisAlignment alignment,
  ) {
    if (!isRTL(context)) return alignment;
    
    switch (alignment) {
      case CrossAxisAlignment.start:
        return CrossAxisAlignment.end;
      case CrossAxisAlignment.end:
        return CrossAxisAlignment.start;
      default:
        return alignment;
    }
  }
}
