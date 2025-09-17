// lib/modules/artist_details/presentation/widgets/header_title.dart
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
  });
  final String title;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          InkWell(
            onTap: onBack ?? () => Navigator.maybePop(context),
            child: SizedBox(
              width: 32.h,
              height: 32.h,
              child: Icon(
                Icons.arrow_back,
                size: 24.h,
                color: AppColor.gray900,
              ),
            ),
          ),
        const Spacer(),
        Text(
          title,
          style: TextStyleHelper.instance.headline32BoldInter.copyWith(
            color: AppColor.gray900,
          ),
        ),
        SizedBox(width: 10.h),
      ],
    );
  }
}
