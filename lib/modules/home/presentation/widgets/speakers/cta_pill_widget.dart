import 'package:baseqat/core/components/custom_widgets/custom_button.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CtaPillWidget extends StatelessWidget {
  const CtaPillWidget({
    super.key,
    required this.leftEmblemPath,
    required this.badgeAssetPaths,
    this.onJoinNow,
  });

  final String leftEmblemPath;
  final String badgeAssetPaths;
  final VoidCallback? onJoinNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.sH, horizontal: 4.sW),
      decoration: BoxDecoration(
        color: AppColor.gray900,
        borderRadius: BorderRadius.circular(20.sR),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left emblem
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 8.sW),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.volume_up,
                    size: 30.sSp,
                    color: AppColor.white,
                  ),
                ),
                SizedBox(width: 8.sW),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        CustomImageView(
                          imagePath: badgeAssetPaths,
                          height: 55.sH,
                          width: 100.sW,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.sW),

          // CTA button
          CustomButton(
            text: 'home.join_now'.tr(),
            backgroundColor: AppColor.whiteCustom,
            textColor: AppColor.gray900,
            fontSize: 24.sSp,
            fontWeight: FontWeight.w700,
            borderRadius: 16.sH,
            padding: EdgeInsets.symmetric(vertical: 10.sH, horizontal: 20.sW),
            onPressed: onJoinNow ?? () {},
          ),
        ],
      ),
    );
  }
}
