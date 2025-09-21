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

  /// NEW: current user id (passed down, not used internally other than semantics)
  final String userId;

  /// NEW: whether this artist is currently favorited for the user
  final bool isFavorite;

  /// NEW: callback to toggle favorite
  final VoidCallback? onFavoriteTap;

  const ArtistCardWidget({
    super.key,
    required this.artist,
    required this.userId, // <-- NEW (required)
    this.onTap,
    this.viewType = ArtistCardViewType.list,
    this.isFavorite = false, // <-- NEW
    this.onFavoriteTap, // <-- NEW
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
                ? _buildGridCard(context, isDesktop)
                : _buildListCard(context, isDesktop),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDesktop) {
    return BoxDecoration(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(16.h),
      border: Border.all(color: AppColor.gray200, width: 1.h),
      boxShadow: [
        BoxShadow(
          color: AppColor.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ===================== LIST CARD =====================
  Widget _buildListCard(BuildContext context, bool isDesktop) {
    final favIcon = isFavorite
        ? Icons.favorite_rounded
        : Icons.favorite_border_rounded;
    final favColor = isFavorite ? AppColor.primaryColor : AppColor.gray600;

    return Padding(
      padding: EdgeInsets.all(16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
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
                // Title row: Name + Country chip + Fav button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        artist.name,
                        style: TextStyleHelper.instance.title16BoldInter
                            .copyWith(color: AppColor.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.h),
                    if (artist.country?.isNotEmpty == true)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.h,
                          vertical: 4.h,
                        ),
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
                              style: TextStyleHelper.instance.body12MediumInter
                                  .copyWith(color: AppColor.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(width: 8.h),
                    // NEW: Favorite button (list)
                    Semantics(
                      button: true,
                      label: 'Favorite ${artist.name} (user $userId)',
                      child: _CircleIconButton(
                        icon: favIcon,
                        size: 34.h,
                        iconSize: 18.h,
                        bgColor: AppColor.white,
                        borderColor: AppColor.gray200,
                        iconColor: favColor,
                        onTap: onFavoriteTap,
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

  // ===================== GRID CARD =====================
  Widget _buildGridCard(BuildContext context, bool isDesktop) {
    final favIcon = isFavorite
        ? Icons.favorite_rounded
        : Icons.favorite_border_rounded;
    final favColor = isFavorite ? AppColor.primaryColor : AppColor.gray600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile image section with fav overlay
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
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                  // NEW: Favorite icon overlay (clickable)
                  Positioned(
                    top: 12.h,
                    right: 12.h,
                    child: Semantics(
                      button: true,
                      label: 'Favorite ${artist.name} (user $userId)',
                      child: _CircleIconButton(
                        icon: favIcon,
                        size: 32.h,
                        iconSize: 18.h,
                        bgColor: AppColor.white,
                        borderColor: AppColor.gray200,
                        iconColor: favColor,
                        onTap: onFavoriteTap,
                        elevation: 8,
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
                        child: Text(
                          artist.country!,
                          style: TextStyleHelper.instance.caption12RegularInter
                              .copyWith(
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

  // ===================== Placeholders =====================
  Widget _buildPlaceholderAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.gray100,
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Icon(Icons.person_rounded, size: 40.h, color: AppColor.gray400),
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
        child: Icon(Icons.person_rounded, size: 48.h, color: AppColor.gray400),
      ),
    );
  }
}

/// Small reusable circular icon button with ripple + optional elevation
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback? onTap;
  final double elevation;

  const _CircleIconButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    this.onTap,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColor.black.withOpacity(0.1),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onTap ?? () {}, // default no-op
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );

    return child;
  }
}
