import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class BottomCta extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const BottomCta({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(16.h),
              border: Border.all(color: AppColor.blueGray100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.headline24BoldInter,
                ),
                SizedBox(height: 12.h),
                Text(
                  subtitle,
                  style: TextStyleHelper.instance.title16RegularInter.copyWith(
                    color: AppColor.gray400,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.h),
        Expanded(
          flex: 2,
          child: Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: AppColor.blackGrey,
              borderRadius: BorderRadius.circular(16.h),
            ),
            child: Center(
              child: Icon(icon, color: AppColor.white, size: 48.h),
            ),
          ),
        ),
      ],
    );
  }
}
