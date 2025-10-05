import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import '../../../../../core/resourses/style_manager.dart';

class MonthSelector extends StatelessWidget {
  final String monthLabel; 
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isDesktop;

  const MonthSelector({
    super.key,
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(icon: Icons.chevron_left, onTap: onPrev),
        SizedBox(width: 12.sH),
        Expanded(
          child: Text(
            monthLabel,
            textAlign: TextAlign.center,
            style: (isDesktop
                    ? TextStyleHelper.instance.title16BoldInter
                    : TextStyleHelper.instance.title14BoldInter)
                .copyWith(color: AppColor.gray900),
          ),
        ),
        SizedBox(width: 12.sH),
        _CircleButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.blueGray100),
          ),
          child: Icon(icon, size: 18, color: AppColor.gray900),
        ),
      ),
    );
  }
}
