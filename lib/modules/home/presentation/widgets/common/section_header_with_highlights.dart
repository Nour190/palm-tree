// lib/modules/home/presentation/widgets/section_header_with_highlights.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/app_section_header.dart';
import 'package:baseqat/modules/home/presentation/widgets/highlights_section.dart';

class SectionHeaderWithHighlights extends StatelessWidget {
  const SectionHeaderWithHighlights({
    super.key,
    required this.title,
    this.subtitle,
    required this.images,
    this.sectionGap = 24.0,
    this.emphasize = true,
    this.webRowMinWidth = 900.0, // set 0 to force row on any web width
    this.desktopGap = 32.0,
    this.headerFractionOnRow = 0.6, // header width share in row layout
  });

  final String title;
  final String? subtitle;
  final List<String> images;

  /// Vertical gap between header and highlights in stacked mode.
  final double sectionGap;

  /// Apply emphasis style to AppSectionHeader.
  final bool emphasize;

  /// When running on web, use row layout if available width >= this.
  /// Set to 0 to always use row on web.
  final double webRowMinWidth;

  /// Horizontal gap between header and highlights in row mode.
  final double desktopGap;

  /// Fraction of total width given to the header in row mode.
  /// Clamped internally to [0.4, 0.8].
  final double headerFractionOnRow;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);

    // Original fractions preserved for stacked mode
    final double stackedMaxTextWidthFraction = isDesktop
        ? 0.6
        : isTablet
        ? 0.74
        : 0.9;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useRowLayout =
            isDesktop || (kIsWeb && constraints.maxWidth >= webRowMinWidth);

        if (useRowLayout) {
          final double clampedHeaderFraction = headerFractionOnRow.clamp(
            0.4,
            0.8,
          );
          final double headerWidth =
              constraints.maxWidth * clampedHeaderFraction;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  child: AppSectionHeader(
                    title: title,
                    subtitle: subtitle,
                    // In row mode we already constrain width; let header fill it.
                    maxTextWidthFraction: 3,

                    emphasize: emphasize,
                  ),
                ),
              ),
              SizedBox(width: 100),
              Expanded(
                flex: 3,
                child: EnhancedHighlightsSection(images: images),
              ),
            ],
          );
        }

        // Tablet / Mobile / narrow web: stacked
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionHeader(
              title: title,
              subtitle: subtitle,
              maxTextWidthFraction: stackedMaxTextWidthFraction,
              emphasize: emphasize,
            ),
            SizedBox(height: sectionGap),
            EnhancedHighlightsSection(images: images),
          ],
        );
      },
    );
  }
}
