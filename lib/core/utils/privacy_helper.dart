import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/modules/profile/data/services/privacy_settings_service.dart';
import 'package:flutter/material.dart';

class PrivacyHelper {
  static bool isLocationSharingEnabled() {
    return PrivacySettingsService.instance.getLocationSharing();
  }

  static bool isActivityTrackingEnabled() {
    return PrivacySettingsService.instance.getActivityTracking();
  }

  static bool isProfileVisibilityEnabled() {
    return PrivacySettingsService.instance.getProfileVisibility();
  }

  static bool isShowLikedArtworksEnabled() {
    return PrivacySettingsService.instance.getShowLikedArtworks();
  }

  static void showLocationDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.location_off,
              color: AppColor.red,
              size: 24.sSp,
            ),
            SizedBox(width: 12.sW),
            Text(
              'Location Disabled',
              style: TextStyleHelper.instance.title18BoldInter.copyWith(
                color: AppColor.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location sharing is currently disabled in your privacy settings.',
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: AppColor.black,
              ),
            ),
            SizedBox(height: 12.sH),
            Text(
              'To use location-based features, please enable location sharing in Profile Settings > Privacy.',
              style: TextStyleHelper.instance.body12MediumInter.copyWith(
                color: AppColor.gray600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: AppColor.gray400,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to profile settings
              _navigateToProfileSettings(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Go to Settings',
              style: TextStyleHelper.instance.title14BoldInter.copyWith(
                color: AppColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showActivityTrackingDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: AppColor.red,
              size: 24.sSp,
            ),
            SizedBox(width: 12.sW),
            Text(
              'Activity Tracking Disabled',
              style: TextStyleHelper.instance.title18BoldInter.copyWith(
                color: AppColor.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity tracking is currently disabled in your privacy settings.',
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: AppColor.black,
              ),
            ),
            SizedBox(height: 12.sH),
            Text(
              'To use activity-based features, please enable activity tracking in Profile Settings > Privacy.',
              style: TextStyleHelper.instance.body12MediumInter.copyWith(
                color: AppColor.gray600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: AppColor.gray400,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToProfileSettings(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Go to Settings',
              style: TextStyleHelper.instance.title14BoldInter.copyWith(
                color: AppColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _navigateToProfileSettings(BuildContext context) {
    // Navigate to profile settings - you'll need to implement this based on your navigation structure
    Navigator.pushNamed(context, '/profile');
  }

  static Widget buildPrivacyRestrictedWidget({
    required String title,
    required String description,
    required VoidCallback onEnablePressed,
  }) {
    return Container(
      padding: EdgeInsets.all(24.sW),
      margin: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: AppColor.gray50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.gray400.withOpacity(0.3),
          width: 1.sW,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            size: 48.sSp,
            color: AppColor.gray400,
          ),
          SizedBox(height: 16.sH),
          Text(
            title,
            style: TextStyleHelper.instance.title16BoldInter.copyWith(
              color: AppColor.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.sH),
          Text(
            description,
            style: TextStyleHelper.instance.body14RegularInter.copyWith(
              color: AppColor.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.sH),
          ElevatedButton(
            onPressed: onEnablePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.sW, vertical: 12.sH),
            ),
            child: Text(
              'Enable in Settings',
              style: TextStyleHelper.instance.title14BoldInter.copyWith(
                color: AppColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
