// UI unchanged; selects EN/AR using LocaleService.isRTL + model helpers.

import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'ithra_artist_card.dart';

class IthraArtistsSection extends StatelessWidget {
  final List<Artist> artists;
  final VoidCallback? onSeeMore;
  final void Function(int index)? onArtistTap;
  final bool isLoading;

  const IthraArtistsSection({
    super.key,
    required this.artists,
    this.onSeeMore,
    this.onArtistTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;
    final locale = context.locale;
    final String languageCode = locale.languageCode;

    // Bilingual switch (no layout changes)
    final bool isRTL = LocaleService.isRTL(context.locale);

    final double horizontalPadding = 16.sW ;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical:20.sH  ,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'home.artists'.tr(),
                style: TextStyleHelper.instance.headline24BoldInter
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

          SizedBox(height: 16.sH),

          // Artists strip
          if (isLoading)
            _buildLoadingState(context, deviceType)
          else if (artists.isEmpty)
            _buildEmptyState(context, deviceType)
          else
            _buildArtistsGrid(context, deviceType, languageCode),
        ],
      ),
    );
  }

  Widget _buildArtistsGrid(
    BuildContext context,
    DeviceType deviceType,
      String languageCode,
  ) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    // Show max 5 artists in a horizontal row
    final displayArtists = artists.take(5).toList();

    return SizedBox(
      height: isMobile ? 120.sH : isTablet ? 140.sH : 160.sH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayArtists.length,
        separatorBuilder: (context, index) => SizedBox(width: 15.sW),
        itemBuilder: (context, index) {
          return IthraArtistCard(
            artist: displayArtists[index],
            index: index,
            onTap: onArtistTap,
            deviceType: deviceType,
            languageCode: languageCode,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    return SizedBox(
      height: isMobile ? 120.sH : isTablet ? 140.sH : 160.sH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          return const _LoadingArtistCard();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;

    return Container(
      height: isMobile ? 120.sH : 160.sH,
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
              Icons.people_outline,
              size: isMobile ? 32.sW : 40.sW,
              color: AppColor.gray400,
            ),
            SizedBox(height: 8.sH),
            Text(
              'home.no_artists_available'.tr(),
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

// ============================================================================
// LOADING CARD (kept here so we only have two files total)
// ============================================================================
class _LoadingArtistCard extends StatefulWidget {
  const _LoadingArtistCard();

  @override
  State<_LoadingArtistCard> createState() => _LoadingArtistCardState();
}

class _LoadingArtistCardState extends State<_LoadingArtistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  )..repeat();

  late final Animation<double> _shimmerAnimation = Tween<double>(
    begin: -1.0,
    end: 2.0,
  ).animate(CurvedAnimation(
    parent: _shimmerController,
    curve: Curves.easeInOut,
  ));

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Size values come from parent (no UI change)
    final double avatarSize = 80.sW;
    final double cardWidth = 90.sW;

    return SizedBox(
      width: cardWidth,
      child: Column(
        children: [
          // Shimmer avatar
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
              );
            },
          ),

          SizedBox(height: 12.sH),

          // Shimmer name
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                width: cardWidth * 0.8,
                height: 14.sH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.sR),
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
              );
            },
          ),

          SizedBox(height: 8.sH),

          // Shimmer subtitle
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                width: cardWidth * 0.6,
                height: 12.sH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.sR),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
