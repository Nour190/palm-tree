import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

class HeaderSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final double maxTextWidthFraction;

  const HeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.maxTextWidthFraction = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * maxTextWidthFraction;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyleHelper.instance.display48BoldInter.copyWith(
              color: AppColor.gray900,
              height: 1.23,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: maxWidth,
            child: Text(
              subtitle,
              style: TextStyleHelper.instance.title16LightInter.copyWith(
                color: AppColor.gray900,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
