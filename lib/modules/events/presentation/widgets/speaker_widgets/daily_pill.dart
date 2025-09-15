import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class DayPill extends StatelessWidget {
  final String label;
  final bool isSelected;

  const DayPill({super.key, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColor.black : AppColor.white;
    final fg = isSelected ? AppColor.white : AppColor.black;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.h),
        border: Border.all(
          color: isSelected ? AppColor.black : AppColor.blueGray100,
        ),
      ),
      child: Text(
        label,
        style: TextStyleHelper.instance.title16MediumInter.copyWith(
          fontSize: 12.fSize,
          color: fg,
        ),
      ),
    );
  }
}
