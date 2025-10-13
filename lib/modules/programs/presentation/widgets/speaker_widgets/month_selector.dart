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
      children: [
        _CircleButton(icon: prevIcon, onTap: onPrev),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            monthLabel,
            textAlign: TextAlign.center,
            style: ProgramsTypography.headingMedium(
              context,
            ).copyWith(color: AppColor.gray900),
          ),
        ),
        SizedBox(width: spacing),
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

    return Material(
      color: AppColor.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.blueGray100),
          ),
          child: Icon(
            icon,
            size: ProgramsLayout.size(context, 20),
            color: AppColor.gray900,
          ),
        ),
      ),
    );
  }
}
