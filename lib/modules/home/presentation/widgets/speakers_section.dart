// lib/modules/home/presentation/widgets/speakers_section.dart
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';

class SpeakersSection extends StatelessWidget {
  final bool isMobile, isTablet, isDesktop;
  final String pitch;
  final String description;
  final String? sideImageAsset; // optional override

  const SpeakersSection({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.pitch,
    required this.description,
    this.sideImageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final gap = isDesktop
        ? 16.0
        : isTablet
        ? 14.0
        : 12.0;
    final radius = isDesktop ? 24.0 : 20.0;

    final top = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            height: isDesktop
                ? 402
                : isTablet
                ? 360
                : 320,
            decoration: BoxDecoration(
              color: AppColor.gray900,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pitch,
                  style: styles.headline32MediumInter.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: gap),
                Text(
                  description,
                  style: styles.title16LightInter.copyWith(color: Colors.white),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          flex: 2,
          child: Container(
            height: isDesktop
                ? 402
                : isTablet
                ? 360
                : 320,
            decoration: BoxDecoration(
              color: AppColor.grey200,
              borderRadius: BorderRadius.circular(radius),
              image: DecorationImage(
                image: AssetImage(sideImageAsset ?? AppAssetsManager.imgInfo),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );

    final bottom = Row(
      children: [
        Container(
          width: isDesktop ? 73 : 60,
          height: isDesktop ? 73 : 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(sideImageAsset ?? AppAssetsManager.imgInfo),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Container(
            height: isDesktop ? 73 : 64,
            decoration: BoxDecoration(
              color: AppColor.gray900,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16 : 12,
              vertical: isDesktop ? 12 : 8,
            ),
            child: Row(
              children: [
                const Row(
                  children: [
                    Icon(Icons.graphic_eq, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                  ],
                ),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColor.gray900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Join Now',
                    style: styles.title16MediumInter.copyWith(
                      color: AppColor.gray900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: gap),
        if (isMobile)
          Column(
            children: [
              top,
              SizedBox(height: gap),
              bottom,
            ],
          )
        else ...[
          top,
          SizedBox(height: gap),
          bottom,
        ],
      ],
    );
  }
}
