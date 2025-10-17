import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
  });

  final String monthLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final spacing = ProgramsLayout.spacingMedium(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final prevIcon = isRtl ? Icons.chevron_right : Icons.chevron_left;
    final nextIcon = isRtl ? Icons.chevron_left : Icons.chevron_right;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CircleButton(icon: prevIcon, onTap: onPrev),
        SizedBox(width: ProgramsLayout.spacingMedium(context)),
        Text(
          monthLabel,
          textAlign: TextAlign.center,
          style: ProgramsTypography.bodyPrimary(
            context,
          ).copyWith(color: AppColor.black, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: ProgramsLayout.spacingMedium(context)),
        _CircleButton(icon: nextIcon, onTap: onNext),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = ProgramsLayout.size(context, 40);

    return InkWell(
      onTap: onTap,
      child: Icon(
        icon,
        size: ProgramsLayout.size(context, 30),
        color: AppColor.black,
      ),
    );
  }
}
