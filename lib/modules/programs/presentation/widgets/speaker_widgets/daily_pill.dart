import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';

class DayPill extends StatelessWidget {
  const DayPill({super.key, required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final background = isSelected ? AppColor.black : AppColor.white;
    final foreground = isSelected ? AppColor.white : AppColor.black;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ProgramsLayout.spacingLarge(context),
        vertical: ProgramsLayout.spacingSmall(context),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(ProgramsLayout.radius20(context)),
        border: Border.all(
          color: isSelected ? AppColor.black : AppColor.blueGray100,
        ),
      ),
      child: Text(
        label,
        style: ProgramsTypography.bodyPrimary(
          context,
        ).copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
