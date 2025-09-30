import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';

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

    final double horizontalPadding = isDesktop
        ? 48.sW
        : isTablet
        ? 32.sW
        : 18.sW;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 24.sH : 32.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gallery',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isDesktop 
                      ? 24.sSp 
                      : isTablet 
                      ? 22.sSp 
                      : 20.sSp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),
              if (onSeeMore != null)
                GestureDetector(
                  onTap: onSeeMore,
                  child: Text(
                    'See More',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isDesktop ? 14.sSp : 13.sSp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.gray600,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 24.sH),
          
          // Gallery grid
          if (imageUrls.isEmpty)
            _buildEmptyState(context, deviceType)
          else
            _buildGalleryGrid(context, deviceType),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    
    // Show max 9 images in a masonry-style grid
    final displayImages = imageUrls.take(9).toList();
    
    if (isMobile) {
      return _buildMobileGrid(context, displayImages);
    } else {
      return _buildDesktopTabletGrid(context, displayImages, deviceType);
    }
  }

  Widget _buildMobileGrid(BuildContext context, List<String> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: images.length.clamp(0, 6), // Max 6 for mobile
      itemBuilder: (context, index) {
        return _buildGalleryItem(
          context,
          images[index],
          index,
          DeviceType.mobile,
        );
      },
    );
  }

  Widget _buildDesktopTabletGrid(BuildContext context, List<String> images, DeviceType deviceType) {
    // Create a masonry-style layout similar to the reference image
    return SizedBox(
      height: deviceType == DeviceType.tablet ? 300.sH : 350.sH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - larger images
          Expanded(
            flex: 2,
            child: Column(
              children: [
                if (images.isNotEmpty)
                  Expanded(
                    flex: 3,
                    child: _buildGalleryItem(
                      context,
                      images[0],
                      0,
                      deviceType,
                      isLarge: true,
                    ),
                  ),
                if (images.length > 1) ...[
                  SizedBox(height: 8.sH),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildGalleryItem(
                            context,
                            images[1],
                            1,
                            deviceType,
                          ),
                        ),
                        if (images.length > 2) ...[
                          SizedBox(width: 8.sW),
                          Expanded(
                            child: _buildGalleryItem(
                              context,
                              images[2],
                              2,
                              deviceType,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(width: 8.sW),
          
          // Right column - smaller images
          Expanded(
            flex: 1,
            child: Column(
              children: [
                if (images.length > 3)
                  Expanded(
                    child: _buildGalleryItem(
                      context,
                      images[3],
                      3,
                      deviceType,
                    ),
                  ),
                if (images.length > 4) ...[
                  SizedBox(height: 8.sH),
                  Expanded(
                    child: _buildGalleryItem(
                      context,
                      images[4],
                      4,
                      deviceType,
                    ),
                  ),
                ],
                if (images.length > 5) ...[
                  SizedBox(height: 8.sH),
                  Expanded(
                    child: _buildGalleryItem(
                      context,
                      images[5],
                      5,
                      deviceType,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryItem(
    BuildContext context,
    String imagePath,
    int index,
    DeviceType deviceType, {
    bool isLarge = false,
  }) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    return GestureDetector(
      onTap: onImageTap != null ? () => onImageTap!(index) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 8.sR : 12.sR),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 8.sR : 12.sR),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              _buildImage(imagePath),
              
              // Hover overlay
              _GalleryItemOverlay(
                isLarge: isLarge,
                deviceType: deviceType,
              ),
            ],
          ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.gray200,
            AppColor.gray400,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32.sW,
          color: AppColor.gray500,
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
        borderRadius: BorderRadius.circular(12.sR),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: isMobile ? 32.sW : 40.sW,
              color: AppColor.gray400,
            ),
            SizedBox(height: 8.sH),
            Text(
              'No gallery images available',
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

class _GalleryItemOverlay extends StatefulWidget {
  final bool isLarge;
  final DeviceType deviceType;

  const _GalleryItemOverlay({
    required this.isLarge,
    required this.deviceType,
  });

  @override
  State<_GalleryItemOverlay> createState() => _GalleryItemOverlayState();
}

class _GalleryItemOverlayState extends State<_GalleryItemOverlay> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: _isHovered
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColor.black.withOpacity(0.6),
                  ],
                  stops: const [0.5, 1.0],
                )
              : null,
        ),
        child: _isHovered
            ? Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(
                    widget.deviceType == DeviceType.mobile ? 8.sW : 12.sW,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.zoom_in_rounded,
                    size: widget.isLarge 
                        ? (widget.deviceType == DeviceType.mobile ? 20.sW : 24.sW)
                        : (widget.deviceType == DeviceType.mobile ? 16.sW : 20.sW),
                    color: AppColor.black,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
