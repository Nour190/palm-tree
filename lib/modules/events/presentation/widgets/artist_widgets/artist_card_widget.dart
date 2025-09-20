import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart' hide DeviceType;
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/responsive.dart';

enum ArtistCardViewType { list, grid }

class ArtistCardWidget extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final ArtistCardViewType viewType;

  const ArtistCardWidget({
    super.key,
    required this.artist,
    this.onTap,
    this.viewType = ArtistCardViewType.list,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return Semantics(
      button: onTap != null,
      label: 'Artist card: ${artist.name}',
      child: Container(
        decoration: _cardDecoration(isDesktop),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.h),
            child: viewType == ArtistCardViewType.grid
                ? _buildGridCard(isDesktop)
                : _buildListCard(isDesktop),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDesktop) {
    return BoxDecoration(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(16.h),
      border: Border.all(
        color: AppColor.gray200,
        width: 1.h,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColor.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildListCard(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.all(16.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.h),
            child: Container(
              width: 70.sW,
              height: 90.sH,
              decoration: BoxDecoration(
                color: AppColor.gray100,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: artist.profileImage?.isNotEmpty == true
                  ? Image.network(
                artist.profileImage!,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => _buildPlaceholderAvatar(),
              )
                  : _buildPlaceholderAvatar(),
            ),
          ),
          SizedBox(width: 16.h),
          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        artist.name,
                        style: TextStyleHelper.instance.title16BoldInter.copyWith(
                          color: AppColor.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 12.h),
                    // Country flag and location
                    if (artist.country?.isNotEmpty == true)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              size: 14.h,
                              color: AppColor.primaryColor,
                            ),
                            SizedBox(width: 4.h),
                            Text(
                              artist.country!,
                              style: TextStyleHelper.instance.body12MediumInter.copyWith(
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                if (artist.about?.isNotEmpty == true)
                  Text(
                    artist.about!,
                    style: TextStyleHelper.instance.body12LightInter.copyWith(
                      color: AppColor.gray600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile image section
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.h),
                topRight: Radius.circular(16.h),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.h),
                topRight: Radius.circular(16.h),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  artist.profileImage?.isNotEmpty == true
                      ? Image.network(
                    artist.profileImage!,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                      : _buildPlaceholderImage(),
                  // Favorite icon overlay
                  Positioned(
                    top: 12.h,
                    right: 12.h,
                    child: Container(
                      width: 32.h,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(16.h),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 18.h,
                        color: AppColor.gray600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Content section
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: TextStyleHelper.instance.title16BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                // Small description
                if (artist.about?.isNotEmpty == true)
                  Text(
                    artist.about!,
                    style: TextStyleHelper.instance.body12LightInter.copyWith(
                      color: AppColor.gray600,
                      height: 1.3.sH,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Spacer(),
                // Country info
                if (artist.country?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16.sSp,
                        color: AppColor.gray500,
                      ),
                      SizedBox(width: 4.sH),
                      Expanded(
                        child: // Using managed text style for country in grid
                        Text(
                          artist.country!,
                          style: TextStyleHelper.instance.caption12RegularInter.copyWith(
                            color: AppColor.gray500,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.gray100,
        borderRadius: BorderRadius.circular(12.h), // Changed from circular to square corners
      ),
      child: Icon(
        Icons.person_rounded,
        size: 40.h, // Increased icon size for larger image
        color: AppColor.gray400,
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.gray100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.h),
          topRight: Radius.circular(16.h),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 48.h,
          color: AppColor.gray400,
        ),
      ),
    );
  }
}
