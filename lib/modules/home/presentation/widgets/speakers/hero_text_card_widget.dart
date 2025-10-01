import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';

class HeroTextCardWidget extends StatelessWidget {
  const HeroTextCardWidget({
    super.key,
    required this.cardRadius,
    required this.paddingAll,
    required this.emblemPath,
    required this.emblemSize,
    required this.headline,
    required this.body,
    required this.desktop,
  });

  final double cardRadius;
  final double paddingAll;
  final String emblemPath;
  final double emblemSize;
  final String headline;
  final String body;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);

    return Container(
      padding: EdgeInsets.all(paddingAll),
      decoration: BoxDecoration(
        color: AppColor.gray900,
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emblem
          Padding(
            padding: EdgeInsets.only(
              top: devType == DeviceType.desktop ? 40.sH : 1.sH,
              left: devType == DeviceType.desktop ? 10.sW : 0,
            ),
            child: CustomImageView(
              imagePath: emblemPath,
              height: emblemSize,
              width: emblemSize,
            ),
          ),
          SizedBox(height: devType == DeviceType.desktop ? 28.sH : 20.sH),

          // Headline
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: desktop ? 560.sW : 520.sW),
            child: Text(
              headline,
              style: TextStyleHelper.instance.headline32BoldInter.copyWith(
                height: 1.3,
                color: AppColor.whiteCustom,
              ),
            ),
          ),
          SizedBox(height: 8.sH),

          // Body
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: devType == DeviceType.desktop ? 640.sW : 560.sW,
            ),
            child: Text(
              body,
              style: TextStyleHelper.instance.body14LightInter.copyWith(
                color: AppColor.whiteCustom,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: devType == DeviceType.desktop ? 40.sH : 15.sH),
        ],
      ),
    );
  }
}
