import 'package:flutter/material.dart';

/// Breakpoints dedicated to the Programs module.
class ProgramsBreakpoints {
  const ProgramsBreakpoints._();

  /// Tablet breakpoint tuned for portrait/landscape tablets only.
  static const double tablet = 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

/// Utilities for sizing, spacing, and radii within the Programs module.
class ProgramsLayout {
  const ProgramsLayout._();

  static double _scaleFor(BuildContext context) =>
      ProgramsBreakpoints.isTablet(context) ? 1.12 : 1.0;

  /// Scales a base dimension by ~12% on tablet for larger touch targets.
  static double size(BuildContext context, double base) =>
      base * _scaleFor(context);

  /// Returns consistent page padding for the module.
  static EdgeInsets pagePadding(
    BuildContext context, {
    bool includeTop = true,
    bool includeBottom = true,
  }) {
    final horizontal = size(context, 20);
    final vertical = size(context, 16);
    return EdgeInsets.only(
      left: horizontal,
      right: horizontal,
      top: includeTop ? vertical : 0,
      bottom: includeBottom ? vertical : 0,
    );
  }

  static EdgeInsets sectionPadding(BuildContext context) =>
      EdgeInsets.all(size(context, 20));

  static double spacingSmall(BuildContext context) => size(context, 8);

  static double spacingMedium(BuildContext context) => size(context, 12);

  static double spacingLarge(BuildContext context) => size(context, 16);

  static double spacingXL(BuildContext context) => size(context, 20);

  static double radius14(BuildContext context) => size(context, 14);

  static double radius16(BuildContext context) => size(context, 16);

  static double radius20(BuildContext context) => size(context, 20);
}

/// Consistent typography overrides for the Programs module.
class ProgramsTypography {
  const ProgramsTypography._();

  static double _textScale(BuildContext context) =>
      ProgramsBreakpoints.isTablet(context) ? 1.12 : 1.0;

  static TextStyle headingLarge(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: 24 * _textScale(context),
        fontWeight: FontWeight.w700,
        height: 1.2,
      ) ??
      TextStyle(
        fontSize: 24 * _textScale(context),
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headingMedium(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 20 * _textScale(context),
        fontWeight: FontWeight.w600,
        height: 1.28,
      ) ??
      TextStyle(
        fontSize: 20 * _textScale(context),
        fontWeight: FontWeight.w600,
        height: 1.28,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 16 * _textScale(context),
        height: 1.5,
      ) ??
      TextStyle(
        fontSize: 16 * _textScale(context),
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodySecondary(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 14 * _textScale(context),
        height: 1.5,
      ) ??
      TextStyle(
        fontSize: 14 * _textScale(context),
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
      );

  static TextStyle labelSmall(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 12 * _textScale(context),
        letterSpacing: 0.4,
        fontWeight: FontWeight.w600,
      ) ??
      TextStyle(
        fontSize: 12 * _textScale(context),
        letterSpacing: 0.4,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle labelSmallLight(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 12 * _textScale(context),
        letterSpacing: 0.4,
        fontWeight: FontWeight.w400,
      ) ??
          TextStyle(
            fontSize: 12 * _textScale(context),
            letterSpacing: 0.4,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
}
