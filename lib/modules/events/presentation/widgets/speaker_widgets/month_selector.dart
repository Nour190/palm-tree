import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

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
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20.sSp : 5.sSp),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(color: AppColor.blueGray100),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            monthLabel,
            style: TextStyleHelper.instance.title16BoldInter.copyWith(
              //fontSize: isDesktop ? 20 : 18,
              color: AppColor.gray900,
            ),
          ),
          Row(
            children: [
              _CircleButton(
                icon: Icons.chevron_left,
                onTap: onPrev,
                isDesktop: isDesktop,
              ),
              SizedBox(width: isDesktop ? 12 : 8),
              _CircleButton(
                icon: Icons.chevron_right,
                onTap: onNext,
                isDesktop: isDesktop,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDesktop;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final side = isDesktop ? 40.0 : 32.0;
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
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: isDesktop ? 20 : 18,
            color: AppColor.black,
          ),
        ),
      ),
    );
  }
}
