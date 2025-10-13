// speakers_header.dart
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';

class SpeakersHeader extends StatelessWidget {
  const SpeakersHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: ProgramsTypography.headingLarge(
        context,
      ).copyWith(color: AppColor.black),
    );
  }
}
