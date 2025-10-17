import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'session_card.dart';

class ScheduleList extends StatelessWidget {
  const ScheduleList({
    super.key,
    required this.speakers,
    required this.userId,
    this.onSpeakerTap,
  });

  final List<Speaker> speakers;
  final String userId;
  final ValueChanged<Speaker>? onSpeakerTap;

  @override
  Widget build(BuildContext context) {
    if (speakers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: ProgramsLayout.sectionPadding(context),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(ProgramsLayout.radius20(context)),
          border: Border.all(color: AppColor.blueGray100),
        ),
        child: Text(
          'speakers_empty'.tr(),
          style: ProgramsTypography.bodySecondary(
            context,
          ).copyWith(color: AppColor.gray600),
        ),
      );
    }

    final spacing = ProgramsLayout.spacingLarge(context);

    return Column(
      children: List.generate(speakers.length, (index) {
        final speaker = speakers[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == speakers.length - 1 ? 0 : spacing,
          ),
          child: SessionCard(
            speaker: speaker,
            index: index,
            userId: userId,
            onTap: onSpeakerTap != null
                ? () => onSpeakerTap!(speaker)
                : null,
            onLongPress: onSpeakerTap != null
                ? () => onSpeakerTap!(speaker)
                : null,
          ),
        );
      }),
    );
  }
}
