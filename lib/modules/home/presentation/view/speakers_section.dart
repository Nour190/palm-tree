import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

class SpeakersSection extends StatelessWidget {
  final String badgeAsset;
  final String title;
  final String subtitle;
  final String sideImageAsset;
  final Color backgroundColor;

  const SpeakersSection({
    super.key,
    required this.badgeAsset,
    required this.title,
    required this.subtitle,
    required this.sideImageAsset,
    this.backgroundColor = const Color(0xFF000000),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24.h),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24.h),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImageView(
                    imagePath: badgeAsset,
                    height: 60.h,
                    width: 60.h,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    title,
                    style: TextStyleHelper.instance.headline24BoldInter
                        .copyWith(color: AppColor.white, height: 1.5),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    subtitle,
                    style: TextStyleHelper.instance.title16LightInter.copyWith(
                      color: AppColor.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20.h),
          CustomImageView(
            imagePath: sideImageAsset,
            height: 300.h,
            width: MediaQuery.of(context).size.width * 0.35,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(24.h),
          ),
        ],
      ),
    );
  }
}
