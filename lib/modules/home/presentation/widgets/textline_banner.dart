import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:flutter/material.dart';

class TextLineBanner extends StatelessWidget {
  const TextLineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    return Container(
      height: 72.h,
      width: double.infinity,
      color: AppColor.gray900,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      alignment: Alignment.center,
      child: Text(
        'FINEST DATES  *  YOUR DATE WITH THE  *',
        style: styles.display40BoldInter,
        textAlign: TextAlign.center,
      ),
    );
  }
}
