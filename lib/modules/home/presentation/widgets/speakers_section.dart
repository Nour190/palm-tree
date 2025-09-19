import 'package:baseqat/core/components/custom_widgets/custom_button.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:flutter/material.dart';

// Your helpers/utilities
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class SpeakersSection extends StatelessWidget {
  const SpeakersSection({
    super.key,
    this.title = 'Speakers',
    this.seeMoreText = 'See More',
    this.heroHeadline = 'A lineup of 300+ voices from industry leaders',
    this.heroBody =
        'Meet a selection of experts and professionals sharing their knowledge and success stories in the world of dates and palm cultivation during the exhibition',
    // Make assets nullable; resolve defaults at runtime to avoid non-const default errors
    this.avatarImagePath,
    this.sideImagePath,
    this.topEmblemPath,
    this.leftEmblemPath,
    this.badgeAssetPaths,
    this.onSeeMore,
    this.onJoinNow,
  });

  // Texts (safe literal defaults)
  final String title;
  final String seeMoreText;
  final String heroHeadline;
  final String heroBody;

  // Assets (nullable -> resolved at runtime)
  final String? avatarImagePath;
  final String? sideImagePath;
  final String? topEmblemPath;
  final String? leftEmblemPath;
  final List<String>? badgeAssetPaths;

  // Actions
  final VoidCallback? onSeeMore;
  final VoidCallback? onJoinNow;

  @override
  Widget build(BuildContext context) {
    // Resolve runtime defaults here (no const requirement)
    final String _avatarPath =
        avatarImagePath ?? AppAssetsManager.imgPhoto72x72;
    final String _sidePath = sideImagePath ?? AppAssetsManager.imgInfo;
    final String _topEmblem =
        topEmblemPath ?? AppAssetsManager.imgVectorWhiteA700;
    final String _leftEmblem = leftEmblemPath ?? AppAssetsManager.imgGroup;
    final List<String> _badges =
        badgeAssetPaths ??
        [
          AppAssetsManager.imgVectorWhiteA70050x66,
          AppAssetsManager.imgVectorWhiteA70050x66,
          AppAssetsManager.imgVectorWhiteA70050x66,
          AppAssetsManager.imgVectorWhiteA70050x66,
        ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final device = Responsive.deviceTypeOf(context);
        final bool isMobile = device == DeviceType.mobile;
        final bool isTablet = device == DeviceType.tablet;
        final bool isDesktop = device == DeviceType.desktop;

        final horizontalPad = isDesktop
            ? 32.sW
            : isTablet
            ? 24.sW
            : 16.sW;
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
            ? 24.sW
            : isTablet
            ? 20.sW
            : 16.sW;
        final heroImageHeight = isDesktop
            ? 420.sH
            : isTablet
            ? 380.sH
            : 320.sH;
        final emblemSize = isDesktop
            ? 82.sH
            : isTablet
            ? 76.sH
            : 72.sH;

        final gap = 16.sW;
        final wrapCtaToColumn = w < 520; // tight phones

        return Column(
          children: [
            SizedBox(height: vSpacing),

            // Hero (text card + image)
            if (isMobile) ...[
              _HeroTextCard(
                cardRadius: cardRadius,
                paddingAll: heroPadding,
                emblemPath: _topEmblem,
                emblemSize: emblemSize,
                headline: heroHeadline,
                body: heroBody,
                desktop: false,
              ),
              SizedBox(height: gap),
              ClipRRect(
                borderRadius: BorderRadius.circular(cardRadius),
                child: CustomImageView(
                  imagePath: _sidePath,
                  height: heroImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _HeroTextCard(
                      cardRadius: cardRadius,
                      paddingAll: heroPadding,
                      emblemPath: _topEmblem,
                      emblemSize: emblemSize,
                      headline: heroHeadline,
                      body: heroBody,
                      desktop: true,
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
                      ),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: vSpacing),

            Row(
              children: [
                _Avatar(
                  imagePath: _avatarPath,
                  size: _avatarSize(isMobile, isTablet, isDesktop),
                ),
                SizedBox(width: 16.sW),
                Expanded(
                  child: _CtaPill(
                    leftEmblemPath: _leftEmblem,
                    badgeAssetPaths: _badges,
                    onJoinNow: onJoinNow,
                  ),
                ),
              ],
            ),
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
            padding: EdgeInsets.only(top: desktop ? 40.sH : 28.sH, left: 10.sW),
            child: CustomImageView(
              imagePath: emblemPath,
              height: emblemSize,
              width: emblemSize,
            ),
          ),
          SizedBox(height: desktop ? 28.sH : 22.sH),

          // Headline (constrained for readability on wide layouts)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: desktop ? 560.sW : 520.sW),
            child: Text(
              headline,
              style: TextStyleHelper.instance.headline32MediumInter.copyWith(
                height: 1.35,
                // Optional: use Responsive.responsiveFontSize if you want extra tuning
                fontSize: Responsive.responsiveFontSize(context, 32).sSp,
              ),
            ),
          ),
          SizedBox(height: 8.sH),

          // Body
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: desktop ? 640.sW : 560.sW),
            child: Text(
              body,
              style: TextStyleHelper.instance.title16LightInter.copyWith(
                color: AppColor.whiteCustom,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: desktop ? 40.sH : 28.sH),
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
  final List<String> badgeAssetPaths;
  final VoidCallback? onJoinNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.sH, horizontal: 12.sW),
      decoration: BoxDecoration(
        color: AppColor.gray900,
        borderRadius: BorderRadius.circular(24.sH),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left emblem
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 8.sW),
                CustomImageView(
                  imagePath: leftEmblemPath,
                  height: 30.sH,
                  width: 45.sW,
                ),

                SizedBox(width: 8.sW),

                // Badges (scroll horizontally if tight)
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        for (int i = 0; i < badgeAssetPaths.length; i++) ...[
                          CustomImageView(
                            imagePath: badgeAssetPaths[i],
                            height: 55.sH,
                            width: 100.sW,
                          ),
                          if (i != badgeAssetPaths.length - 1)
                            SizedBox(width: 4.sW),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Spacer(),
          // CTA button
          CustomButton(
            text: 'Join Now',
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
