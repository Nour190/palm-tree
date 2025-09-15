import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyleHelper.instance.headline24BoldInter.copyWith(
              color: AppColor.gray900,
              height: 1.3,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
