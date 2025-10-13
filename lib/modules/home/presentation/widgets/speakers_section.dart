import 'package:baseqat/core/components/custom_widgets/custom_button.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class SpeakersSection extends StatelessWidget {
  const SpeakersSection({
    super.key,
    this.onSeeMore,
    this.onJoinNow,
  });

  final VoidCallback? onSeeMore;
  final VoidCallback? onJoinNow;

  @override
  Widget build(BuildContext context) {
    final String _avatarPath =
        AppAssetsManager.imgPhoto72x72;
    final String _sidePath = AppAssetsManager.imgInfo;
    final String _topEmblem =
        AppAssetsManager.imgVectorWhiteA700;
    final String _leftEmblem = AppAssetsManager.imgGroup;
    final String badges = AppAssetsManager.imgVectorWhiteA70050x66;

    return LayoutBuilder(
      builder: (context, constraints) {
        final device = Responsive.deviceTypeOf(context);
        final bool isMobile = device == DeviceType.mobile;
        final bool isTablet = device == DeviceType.tablet;
        final bool isDesktop = device == DeviceType.desktop;

        // final horizontalPad = isDesktop
        //     ? 32.sW
        //     : isTablet
        //     ? 24.sW
        //     : 16.sW;
        final vSpacing = isDesktop
            ? 24.sH
            : isTablet
            ? 20.sH
            : 14.sH;
        final cardRadius = isDesktop
            ? 24.sH
            : isTablet
            ? 22.sH
            : 20.sH;

        final heroPadding = isDesktop
            ? 30.sW
            : isTablet
            ? 28.sW
            : 24.sW;
        final heroImageHeight = isDesktop
            ? 350.sH
            : isTablet
            ? 325.sH
            : 300.sH;
        final emblemSize = isDesktop
            ? 75.sSp
            : isTablet
            ? 55.sSp
            : 49.sSp;

        final gap = 16.sW;

        return Column(
          children: [
            SizedBox(height: vSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'home.speakers'.tr(),
                  style:TextStyleHelper.instance.headline24BoldInter
                ),
                if (onSeeMore != null)
                  GestureDetector(
                    onTap: onSeeMore,
                    child: Text(
                      'home.see_more'.tr(),
                      style:TextStyleHelper.instance.title16RegularInter
                    ),
                  ),
              ],
            ),

            SizedBox(height: 24.sH),
            // Hero (text card + image)
            if (isMobile) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.sW),
                child: _HeroTextCard(
                  cardRadius: cardRadius,
                  paddingAll: heroPadding,
                  emblemPath: _topEmblem,
                  emblemSize: emblemSize,
                  headline: 'home.speakers_headline'.tr(),
                  body: 'home.speakers_body'.tr(),
                  desktop: false,
                  //onJoinNow: onJoinNow,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.sW),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cardRadius),
                  child: CustomImageView(
                    imagePath: _sidePath,
                    height: heroImageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.sW),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _HeroTextCard(
                        cardRadius: cardRadius,
                        paddingAll: heroPadding,
                        emblemPath: _topEmblem,
                        emblemSize: emblemSize,
                        headline: 'home.speakers_headline'.tr(),
                        body: 'home.speakers_body'.tr(),
                        desktop: true,
                       // onJoinNow: onJoinNow,
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(cardRadius),
                        child: CustomImageView(
                          imagePath: _sidePath,
                          height: heroImageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: vSpacing),

            // Row(
            //   children: [
            //     _Avatar(
            //       imagePath: _avatarPath,
            //       size: _avatarSize(isMobile, isTablet, isDesktop),
            //     ),
            //     SizedBox(width: 8.sW),
            //     Expanded(
            //       child: _CtaPill(
            //         leftEmblemPath: _leftEmblem,
            //         badgeAssetPaths: badges,
            //         onJoinNow: onJoinNow,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        );
      },
    );
  }

  double _avatarSize(bool isMobile, bool isTablet, bool isDesktop) {
    if (isDesktop) return 84.sH;
    if (isTablet) return 76.sH;
    return 72.sH;
  }
}

class _HeroTextCard extends StatelessWidget {
  const _HeroTextCard({
    required this.cardRadius,
    required this.paddingAll,
    required this.emblemPath,
    required this.emblemSize,
    required this.headline,
    required this.body,
    required this.desktop,
    //required this.onJoinNow,
  });

  final double cardRadius;
  final double paddingAll;
  final String emblemPath;
  final double emblemSize;
  final String headline;
  final String body;
  final bool desktop;
  //final VoidCallback? onJoinNow;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(top: devType == DeviceType.desktop ? 40.sH : 1.sH, left: devType == DeviceType.desktop ? 10.sW : 0),
                child: CustomImageView(
                  imagePath: emblemPath,
                  height: emblemSize,
                  width: emblemSize,
                ),
              ),

              // CustomButton(
              //   height:50.sH,
              //   width: 100.sW,
              //   text: 'home.join_now'.tr(),
              //   backgroundColor: AppColor.whiteCustom,
              //   textColor: AppColor.gray900,
              //   fontSize: 24.sSp,
              //   fontWeight: FontWeight.w700,
              //   borderRadius: 10.sH,
              //   padding: EdgeInsets.symmetric(horizontal: 20.sW),
              //   onPressed: onJoinNow ?? () {},
              // ),

            ],
          ),
          SizedBox(height: devType == DeviceType.desktop ? 28.sH : 20.sH),

          // Headline (constrained for readability on wide layouts)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: desktop ? 560.sW : 520.sW),
            child: Text(
              headline,
              style: TextStyleHelper.instance.headline32BoldInter.copyWith(
                height: 1.3,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 8.sH),

          // Body
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: devType == DeviceType.desktop ? 640.sW : 560.sW),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imagePath, required this.size});

  final String imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomImageView(
      imagePath: imagePath,
      height: size,
      width: size,
      radius: BorderRadius.circular(size / 2),
    );
  }
}

class _CtaPill extends StatelessWidget {
  const _CtaPill({
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
      padding: EdgeInsets.symmetric(horizontal: 4.sW),
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
                IconButton(onPressed: () {}, icon: Icon(Icons.volume_up, size: 30.sSp, color: AppColor.white)),
                SizedBox(width: 8.sW),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        CustomImageView(
                          imagePath: badgeAssetPaths,
                          height: 30.sH,
                         // width: 100.sW,
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
            height:40.sH,
            text: 'home.join_now'.tr(),
            backgroundColor: AppColor.whiteCustom,
            textColor: AppColor.gray900,
            fontSize: 24.sSp,
            fontWeight: FontWeight.w700,
            borderRadius: 10.sH,
            padding: EdgeInsets.symmetric(horizontal: 20.sW),
            onPressed: onJoinNow ?? () {},
          ),
          SizedBox(width: 6.sW),
        ],
      ),
    );
  }
}
