import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

class VirtualTourSection extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String subtitle;
  final String usersAsset;
  final String ctaText;
  final VoidCallback? onTapCta;

  const VirtualTourSection({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.usersAsset,
    required this.ctaText,
    this.onTapCta,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeaderWidget(
            title: 'Virtual Tour',
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              CustomImageView(
                imagePath: imageAsset,
                height: 300.h,
                width: MediaQuery.of(context).size.width * 0.4,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(24.h),
              ),
              SizedBox(width: 20.h),
              Expanded(
                child: Container(
                  height: 300.h,
                  padding: EdgeInsets.all(20.h),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(24.h),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyleHelper.instance.headline24BoldInter
                            .copyWith(color: AppColor.gray900, height: 1.22),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        subtitle,
                        style: TextStyleHelper.instance.title16LightInter
                            .copyWith(color: AppColor.gray900, height: 1.5),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          CustomImageView(
                            imagePath: usersAsset,
                            height: 32.h,
                            width: 100.h,
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onTapCta,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.h,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.gray900,
                                borderRadius: BorderRadius.circular(16.h),
                              ),
                              child: Text(
                                ctaText,
                                style: TextStyleHelper.instance.title16BoldInter
                                    .copyWith(color: AppColor.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
