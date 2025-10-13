import 'package:baseqat/core/services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';

import '../../../../../core/resourses/style_manager.dart';
import 'ithra_artwork_card.dart';

class IthraArtworksSection extends StatelessWidget {
  final List<Artwork> artworks;
  final VoidCallback? onSeeMore;
  final void Function(int index)? onArtworkTap;
  final void Function(int index)? onFavoriteTap;
  final bool isLoading;

  const IthraArtworksSection({
    super.key,
    required this.artworks,
    this.onSeeMore,
    this.onArtworkTap,
    this.onFavoriteTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    // keep UI the same; only choose AR/EN strings
    final bool isRTL = LocaleService.isRTL(context.locale);

    final double horizontalPadding = isDesktop ? 16.sW : isTablet ? 12.sW : 8.sW;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 24.sH : 32.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (unchanged)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'home.art_works'.tr(),
                style: TextStyleHelper.instance.headline24BoldInter
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

          SizedBox(height: 24.sH),

          // Artworks horizontal list
          if (isLoading)
            _buildLoadingState(context, deviceType)
          else if (artworks.isEmpty)
            _buildEmptyState(context, deviceType)
          else
            _buildArtworksHorizontalList(context, deviceType, isRTL),
        ],
      ),
    );
  }

  Widget _buildArtworksHorizontalList(
    BuildContext context,
    DeviceType deviceType,
    bool isRTL,
  ) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    // Increased height + responsive for mobile (no layout change)
    final Size screenSize = MediaQuery.of(context).size;
    final double screenH = screenSize.height;

    // Mobile grows with screen height but clamped to keep visual parity
    final double cardHeight =
        isMobile
        ? (screenH * 0.62).clamp(300, 400)
        : isTablet
            ? (screenH * 0.58).clamp(350.0, 450.0)
            : (screenH * 0.54).clamp(360.0, 460.0);

    // sequence: Divider, Card, Divider, Card, ..., Divider
    final int totalItems = artworks.length * 2 + 1;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalItems,
        itemBuilder: (context, index) {
          // even indices -> divider
          if (index.isEven) {
            return SizedBox(
              width: 8.sW,
              child: VerticalDivider(
                width: 8.sW,
                thickness: 2,
                color: AppColor.gray400,
              ),
            );
          }

          // odd indices -> card
          final int artworkIndex = index ~/ 2;
          return IthraArtworkCard(
            artwork: artworks[artworkIndex],
            index: artworkIndex,
            onTap: onArtworkTap,
            onFavoriteTap: onFavoriteTap,
            deviceType: deviceType,
            isRTL: isRTL, // pass only the boolean; no layout change
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    // Taller loading skeleton, responsive
    final Size screenSize = MediaQuery.of(context).size;
    final double screenH = screenSize.height;

    final double cardHeight = isMobile
        ? (screenH * 0.68).clamp(500.0, 680.0)
        : isTablet
            ? (screenH * 0.62).clamp(560.0, 720.0) 
            : (screenH * 0.58).clamp(600.0, 780.0) ;

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(width: 16.sW),
        itemBuilder: (context, index) {
          return _LoadingArtworkCard(deviceType: deviceType);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;

    // Slightly taller empty state for mobile to match new rhythm
    final double h = isMobile ? 240.sH : 280.sH;

    return Container(
      height: h,
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
              Icons.palette_outlined,
              size: isMobile ? 36.sW : 44.sW,
              color: AppColor.gray400,
            ),
            SizedBox(height: 10.sH),
            Text(
              'home.no_artworks_available'.tr(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 14.5.sSp : 16.sSp,
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

// ============================================================================
// LOADING CARD (visual unchanged, just taller by parent constraints)
// ============================================================================
class _LoadingArtworkCard extends StatefulWidget {
  final DeviceType deviceType;

  const _LoadingArtworkCard({required this.deviceType});

  @override
  State<_LoadingArtworkCard> createState() => _LoadingArtworkCardState();
}

class _LoadingArtworkCardState extends State<_LoadingArtworkCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = widget.deviceType == DeviceType.mobile;
    final bool isTablet = widget.deviceType == DeviceType.tablet;

    final double cardWidth = isMobile ? 280.sW : isTablet ? 320.sW : 360.sW;
    final double imageH = isMobile ? 260.sH : isTablet ? 300.sH : 340.sH;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.sR),
            border: Border.all(color: AppColor.gray200, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // taller shimmer image
              Container(
                width: cardWidth,
                height: imageH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.sR),
                    topRight: Radius.circular(16.sR),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColor.gray200, AppColor.gray100, AppColor.gray200],
                    stops: [
                      (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                      _shimmerAnimation.value.clamp(0.0, 1.0),
                      (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.sW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title shimmer
                    Container(
                      width: cardWidth * 0.7,
                      height: 20.sH,
                      decoration: BoxDecoration(
                        color: AppColor.gray200,
                        borderRadius: BorderRadius.circular(4.sR),
                      ),
                    ),
                    SizedBox(height: 8.sH),
                    // desc line 1
                    Container(
                      width: cardWidth * 0.9,
                      height: 14.sH,
                      decoration: BoxDecoration(
                        color: AppColor.gray100,
                        borderRadius: BorderRadius.circular(4.sR),
                      ),
                    ),
                    SizedBox(height: 6.sH),
                    // desc line 2
                    Container(
                      width: cardWidth * 0.75,
                      height: 14.sH,
                      decoration: BoxDecoration(
                        color: AppColor.gray100,
                        borderRadius: BorderRadius.circular(4.sR),
                      ),
                    ),
                    SizedBox(height: 16.sH),
                    // artist row shimmer
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 16.sH,
                            decoration: BoxDecoration(
                              color: AppColor.gray200,
                              borderRadius: BorderRadius.circular(4.sR),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.sW),
                        Container(
                          width: isMobile ? 40.sW : 48.sW,
                          height: isMobile ? 40.sW : 48.sW,
                          decoration: BoxDecoration(
                            color: AppColor.gray200,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
