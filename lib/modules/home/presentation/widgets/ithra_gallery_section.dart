import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/resourses/style_manager.dart';

class IthraGallerySection extends StatelessWidget {
  final List<String> imageUrls;
  final VoidCallback? onSeeMore;
  final void Function(int index)? onImageTap;

  const IthraGallerySection({
    super.key,
    required this.imageUrls,
    this.onSeeMore,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    final double horizontalPadding =16.sW;


    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'home.gallery'.tr(),
                style:TextStyleHelper.instance.headline24BoldInter
              ),
              if (onSeeMore != null)
                GestureDetector(
                  onTap: onSeeMore,
                  child: Text(
                    'home.see_more'.tr(),
                    style: TextStyleHelper.instance.title16RegularInter
                  ),
                ),
            ],
          ),

          SizedBox(height: isMobile ? 20.sH : 24.sH),

          if (imageUrls.isEmpty)
            _buildEmptyState(context, deviceType)
          else
            _buildStaggeredGallery(context, deviceType),
        ],
      ),
    );
  }

  Widget _buildStaggeredGallery(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    // Show max 12 images
    final displayImages = imageUrls.take(12).toList();

    final crossAxisCount = isMobile ? 2 : isTablet ? 3 : 4;
    final spacing = isMobile ? 16.sW : isTablet ? 20.sW : 24.sW;

    return MasonryGridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayImages.length,
      itemBuilder: (context, index) {
        return _buildGalleryCard(
          context,
          displayImages[index],
          index,
          deviceType,
        );
      },
    );
  }

  Widget _buildGalleryCard(
      BuildContext context,
      String imagePath,
      int index,
      DeviceType deviceType,
      ) {
    final bool isMobile = deviceType == DeviceType.mobile;

    final heights = [200.0, 280.0, 240.0, 300.0, 220.0, 260.0];
    final height = heights[index % heights.length];

    return GestureDetector(
      onTap: onImageTap != null ? () => onImageTap!(index) : null,
      child: Container(
        height: isMobile ? height * 0.8 : height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 12.sR : 16.sR),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 12.sR : 16.sR),
          child: _buildImage(imagePath),
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.toLowerCase().startsWith('http')) {
      return HomeImage(
        path: imagePath,
        fit: BoxFit.cover,
        errorChild: _buildFallbackImage(),
      );
    } else {
      return CustomImageView(
        imagePath: imagePath,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      color: AppColor.gray100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40.sW,
          color: AppColor.gray400,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;

    return Container(
      height: isMobile ? 200.sH : 300.sH,
      decoration: BoxDecoration(
        color: AppColor.gray50,
        borderRadius: BorderRadius.circular(16.sR),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: isMobile ? 48.sW : 64.sW,
              color: AppColor.gray400,
            ),
            SizedBox(height: 12.sH),
            Text(
              'home.no_gallery_images'.tr(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 14.sSp : 16.sSp,
                fontWeight: FontWeight.w500,
                color: AppColor.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
