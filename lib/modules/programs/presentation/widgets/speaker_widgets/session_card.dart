import 'dart:ui' as ui;

import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:baseqat/modules/programs/presentation/view/more_details_views_tabs/speakers_info_view.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.speaker,
    required this.index,
    required this.userId,
    this.onLongPress,
    this.onTap, // Added optional onTap callback
  });

  final Speaker speaker;
  final int index;
  final String userId;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap; // Added optional onTap callback

  String _formatTimeLocal(BuildContext context, DateTime utc) =>
      DateFormat.jm(context.locale.toLanguageTag()).format(utc.toLocal());

  @override
  Widget build(BuildContext context) {
    final isHighlighted = speaker.isLive == true || index == 0;
    final background = isHighlighted ? AppColor.black : AppColor.white;
    final foreground = isHighlighted ? AppColor.white : AppColor.black;
    final borderColor = isHighlighted
        ? Colors.transparent
        : AppColor.blueGray100;

    final languageCode = context.locale.languageCode;
    final timeLabel = _formatTimeLocal(context, speaker.startAt).toUpperCase();
    final title =
        speaker.localizedTopicName(languageCode: languageCode) ??
            speaker.localizedName(languageCode: languageCode);
    final summary =
        speaker.localizedTopicDescription(languageCode: languageCode) ??
            speaker.localizedBio(languageCode: languageCode) ??
            '';

    final padding = ProgramsLayout.sectionPadding(context);
    final radius = ProgramsLayout.radius20(context);

    return GestureDetector(
      onTap: onTap ?? () {
        navigateTo(
          context,
          SpeakersInfoScreen(speaker: speaker, userId: userId),
        );
      },
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: ProgramsLayout.spacingSmall(context),
                    ),
                    child: Text(
                      timeLabel,
                      style: ProgramsTypography.headingLarge(
                        context,
                      ).copyWith(color: foreground),
                    ),
                  ),
                  SizedBox(width: ProgramsLayout.spacingLarge(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: ProgramsTypography.headingMedium(
                            context,
                          ).copyWith(color: foreground),
                        ),
                        SizedBox(height: ProgramsLayout.spacingSmall(context)),
                        if (summary.isNotEmpty)
                          Text(
                            summary,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: ProgramsTypography.bodySecondary(context)
                                .copyWith(
                              color: foreground.withValues(alpha: 0.86),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: ProgramsLayout.spacingMedium(context),
              right: ProgramsLayout.spacingMedium(context),
              child: _ArrowIndicator(isHighlighted: isHighlighted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowIndicator extends StatelessWidget {
  const _ArrowIndicator({required this.isHighlighted});

  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final size = ProgramsLayout.size(context, 32);
    final borderRadius = size / 2;
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isHighlighted
              ? Colors.white.withValues(alpha: 0.28)
              : AppColor.blueGray100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Transform.scale(
        scaleX: isRtl ? -1 : 1,
        child: Icon(
          Icons.north_east_rounded,
          size: ProgramsLayout.size(context, 18),
          color: isHighlighted ? Colors.white : AppColor.gray700,
        ),
      ),
    );
  }
}
