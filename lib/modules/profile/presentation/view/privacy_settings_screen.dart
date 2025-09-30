import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/modules/profile/data/services/privacy_settings_service.dart';
import 'package:baseqat/modules/profile/presentation/cubit/privacy_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrivacySettingsCubit(PrivacySettingsService.instance)..loadSettings(),
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 768;

            if (isDesktop) {
              return _buildDesktopLayout(context);
            } else {
              return _buildMobileLayout(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 280,
          color: AppColor.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDesktopHeader(context),
              Expanded(
                child: _buildSidebarNavigation(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(32.sW),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Settings',
                  style: TextStyleHelper.instance.headline24MediumInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 8.sH),
                Text(
                  'Control your privacy and data sharing preferences',
                  style: TextStyleHelper.instance.title16RegularInter.copyWith(
                    color: AppColor.gray400,
                  ),
                ),
                SizedBox(height: 32.sH),
                Expanded(
                  child: _buildDesktopContent(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColor.black,
            size: 20.sSp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Settings',
          style: TextStyleHelper.instance.title18BoldInter.copyWith(
            color: AppColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<PrivacySettingsCubit, PrivacySettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.sW),
            child: _buildMobileContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.sW),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.grey200, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor.black,
              size: 20.sSp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8.sW),
          Text(
            'Settings',
            style: TextStyleHelper.instance.title18BoldInter.copyWith(
              color: AppColor.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavigation() {
    return Container(
      padding: EdgeInsets.all(16.sW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavItem('General', false),
          _buildNavItem('Notifications', false),
          _buildNavItem('Privacy', true),
          _buildNavItem('Security', false),
          _buildNavItem('Account', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, bool isActive) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.sH),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.sW, vertical: 8.sH),
            decoration: BoxDecoration(
              color: isActive ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              title,
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: isActive ? AppColor.primaryColor : AppColor.gray400,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return BlocBuilder<PrivacySettingsCubit, PrivacySettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildDesktopCard(
                      'Profile Visibility',
                      'Control what others can see on your profile',
                      [
                        _buildDesktopToggle(
                          'Show Liked Artworks',
                          'Display your liked artworks on your profile',
                          state.showLikedArtworks,
                              (value) => context.read<PrivacySettingsCubit>().updateShowLikedArtworks(value),
                        ),
                      ],
                    ),
                    _buildDesktopCard(
                      'Activity & Location',
                      'Manage activity tracking and location sharing',
                      [
                        _buildDesktopToggle(
                          'Activity Tracking',
                          'Allow tracking of your app activity',
                          state.activityTracking,
                              (value) => context.read<PrivacySettingsCubit>().updateActivityTracking(value),
                        ),
                        _buildDesktopToggle(
                          'Location Sharing',
                          'Share your location with the app',
                          state.locationSharing,
                              (value) => context.read<PrivacySettingsCubit>().updateLocationSharing(value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.sW),
              Expanded(
                child: Column(
                  children: [
                    _buildDesktopCard(
                      'Data Management',
                      'Manage your data and account settings',
                      [
                        _buildDesktopActionButton(
                          'Privacy Policy',
                          'Read our privacy policy',
                          Icons.policy,
                              () => _launchPrivacyPolicy(),
                        ),
                        _buildDesktopActionButton(
                          'Delete Account',
                          'Permanently delete your account and data',
                          Icons.delete_forever,
                              () => _showDeleteAccountDialog(context),
                          isDestructive: true,
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

  Widget _buildMobileContent(BuildContext context, PrivacySettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Profile Visibility'),
        SizedBox(height: 16.sH),
        _buildPrivacyToggle(
          'Show Liked Artworks',
          'Display your liked artworks on your profile',
          state.showLikedArtworks,
              (value) => context.read<PrivacySettingsCubit>().updateShowLikedArtworks(value),
        ),

        SizedBox(height: 24.sH),

        _buildSectionHeader('Activity & Location'),
        SizedBox(height: 16.sH),
        _buildPrivacyToggle(
          'Activity Tracking',
          'Allow tracking of your app activity',
          state.activityTracking,
              (value) => context.read<PrivacySettingsCubit>().updateActivityTracking(value),
        ),
        _buildPrivacyToggle(
          'Location Sharing',
          'Share your location with the app',
          state.locationSharing,
              (value) => context.read<PrivacySettingsCubit>().updateLocationSharing(value),
        ),

        SizedBox(height: 24.sH),

        _buildSectionHeader('Data Management'),
        SizedBox(height: 16.sH),
        _buildActionButton(
          'Privacy Policy',
          'Read our privacy policy',
          Icons.policy,
              () => _launchPrivacyPolicy(),
        ),
        _buildActionButton(
          'Delete Account',
          'Permanently delete your account and data',
          Icons.delete_forever,
              () => _showDeleteAccountDialog(context),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildDesktopCard(String title, String subtitle, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.sH),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.sW),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColor.grey200, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.title16BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 4.sH),
                Text(
                  subtitle,
                  style: TextStyleHelper.instance.body14RegularInter.copyWith(
                    color: AppColor.gray400,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.sW),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sH),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.title14BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 4.sH),
                Text(
                  subtitle,
                  style: TextStyleHelper.instance.body12MediumInter.copyWith(
                    color: AppColor.gray400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColor.primaryColor,
            inactiveThumbColor: AppColor.gray400,
            inactiveTrackColor: AppColor.grey200,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopActionButton(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sH),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.all(16.sW),
            decoration: BoxDecoration(
              color: AppColor.gray50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.grey200),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.sW,
                  height: 32.sW,
                  decoration: BoxDecoration(
                    color: isDestructive ? AppColor.red.withOpacity(0.1) : AppColor.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? AppColor.red : AppColor.primaryColor,
                    size: 16.sSp,
                  ),
                ),
                SizedBox(width: 12.sW),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyleHelper.instance.title14BoldInter.copyWith(
                          color: isDestructive ? AppColor.red : AppColor.black,
                        ),
                      ),
                      SizedBox(height: 2.sH),
                      Text(
                        subtitle,
                        style: TextStyleHelper.instance.body12MediumInter.copyWith(
                          color: AppColor.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColor.gray400,
                  size: 14.sSp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.sH),
      child: Text(
        title,
        style: TextStyleHelper.instance.title16BoldInter.copyWith(
          color: AppColor.black,
        ),
      ),
    );
  }

  Widget _buildPrivacyToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sH),
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: AppColor.gray50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.grey200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.title14BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 4.sH),
                Text(
                  subtitle,
                  style: TextStyleHelper.instance.body12MediumInter.copyWith(
                    color: AppColor.gray400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColor.primaryColor,
            inactiveThumbColor: AppColor.gray400,
            inactiveTrackColor: AppColor.grey200,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sH),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.sW),
            decoration: BoxDecoration(
              color: AppColor.gray50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.grey200),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.sW,
                  height: 40.sW,
                  decoration: BoxDecoration(
                    color: isDestructive ? AppColor.red.withOpacity(0.1) : AppColor.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? AppColor.red : AppColor.primaryColor,
                    size: 20.sSp,
                  ),
                ),
                SizedBox(width: 16.sW),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyleHelper.instance.title14BoldInter.copyWith(
                          color: isDestructive ? AppColor.red : AppColor.black,
                        ),
                      ),
                      SizedBox(height: 2.sH),
                      Text(
                        subtitle,
                        style: TextStyleHelper.instance.body12MediumInter.copyWith(
                          color: AppColor.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColor.gray400,
                  size: 16.sSp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    const url = 'https://your-app.com/privacy-policy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Account',
          style: TextStyleHelper.instance.title18BoldInter.copyWith(
            color: AppColor.red,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
          style: TextStyleHelper.instance.body14RegularInter.copyWith(
            color: AppColor.black,
          ),
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle account deletion
            },
            child: Text(
              'Delete',
              style: TextStyleHelper.instance.title14BoldInter.copyWith(
                color: AppColor.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
