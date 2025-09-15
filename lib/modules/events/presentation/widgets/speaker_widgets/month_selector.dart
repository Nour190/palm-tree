import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class MonthSelector extends StatelessWidget {
  final String monthLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const MonthSelector({
    super.key,
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _CircleButton(icon: Icons.chevron_left, onTap: onPrev),
        SizedBox(width: 16.h),
        Text(monthLabel, style: TextStyleHelper.instance.title16BoldInter),
        SizedBox(width: 16.h),
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
    final side = 32.h;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.white,
            border: Border.all(color: AppColor.blueGray100),
          ),
          child: Icon(icon, size: 18.h, color: AppColor.black),
        ),
      ),
    );
  }
}
