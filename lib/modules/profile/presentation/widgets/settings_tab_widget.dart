import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/modules/profile/data/services/privacy_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubit/privacy_settings_cubit.dart';

class SettingsTabWidget extends StatefulWidget {
  const SettingsTabWidget({super.key});

  @override
  State<SettingsTabWidget> createState() => _SettingsTabWidgetState();
}

class _SettingsTabWidgetState extends State<SettingsTabWidget> {
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool smsNotifications = true;
  bool showNotificationSettings = false;
  bool showPrivacySettings = false;

  @override
  Widget build(BuildContext context) {
    final settingsItems = [
      {
        'title': 'Account',
        'icon': Icons.person,
        'onTap': () {
          // Handle account settings
        },
      },
      {
        'title': 'Privacy',
        'icon': Icons.privacy_tip,
        'onTap': () {
          setState(() {
            showPrivacySettings = !showPrivacySettings;
          });
        },
      },
      {
        'title': 'Notification',
        'icon': Icons.notifications,
        'onTap': () {
          setState(() {
            showNotificationSettings = !showNotificationSettings;
          });
        },
      },
      {
        'title': 'Passwords',
        'icon': Icons.key,
        'onTap': () {
          // Handle password settings
        },
      },
      {
        'title': 'Language',
        'icon': Icons.language,
        'onTap': () {
          // Handle language settings
        },
      },
      {
        'title': 'Exit',
        'icon': Icons.exit_to_app,
        'isExit': true,
        'onTap': () {
          // Handle exit
        },
      },
    ];

    return BlocProvider(
      create: (context) => PrivacySettingsCubit(PrivacySettingsService.instance)..loadSettings(),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.sH),
        child: Column(
          children: [
            ...settingsItems.map((item) => _buildSettingsItem(item)).toList(),
            if (showNotificationSettings) _buildNotificationSettings(),
            if (showPrivacySettings) _buildPrivacySettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(Map<String, dynamic> item) {
    final isExit = item['isExit'] as bool? ?? false;
    final isNotification = item['title'] == 'Notification';
    final isPrivacy = item['title'] == 'Privacy';

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 1.sH),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8.sH, horizontal: 16.sW),
            leading: Container(
              width: 40.sW,
              height: 40.sW,
              decoration: BoxDecoration(
                color: isExit ? AppColor.red : AppColor.black,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'] as IconData,
                color: AppColor.white,
                size: 20.sSp,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: TextStyleHelper.instance.title16RegularInter.copyWith(
                color: isExit ? AppColor.red : AppColor.black,
              ),
            ),
            trailing: Icon(
              (isNotification && showNotificationSettings) || (isPrivacy && showPrivacySettings)
                  ? Icons.keyboard_arrow_up
                  : Icons.arrow_forward_ios,
              color: AppColor.gray400,
              size: 16.sSp,
            ),
            onTap: item['onTap'] as VoidCallback?,
          ),
        ),
        SizedBox(height: 4.sH),
        Divider(
          color: AppColor.grey200,
          thickness: 2,
          height: 2,
          indent: 40.sW,
          endIndent: 16.sW,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 8.sH),
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: AppColor.gray50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Settings',
            style: TextStyleHelper.instance.body14RegularInter.copyWith(
              color: AppColor.black,
            ),
          ),
          SizedBox(height: 16.sH),
          _buildNotificationToggle(
            'Push Notifications',
            'Receive push notifications on your device',
            pushNotifications,
                (value) => setState(() => pushNotifications = value),
          ),
          _buildNotificationToggle(
            'Email Notifications',
            'Receive notifications via email',
            emailNotifications,
                (value) => setState(() => emailNotifications = value),
          ),
          _buildNotificationToggle(
            'SMS Notifications',
            'Receive notifications via SMS',
            smsNotifications,
                (value) => setState(() => smsNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return BlocBuilder<PrivacySettingsCubit, PrivacySettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 8.sH),
            padding: EdgeInsets.all(32.sW),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 8.sH),
          padding: EdgeInsets.all(16.sW),
          decoration: BoxDecoration(
            color: AppColor.gray50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppColor.primaryColor,
                    size: 20.sSp,
                  ),
                  SizedBox(width: 8.sW),
                  Text(
                    'Privacy & Security',
                    style: TextStyleHelper.instance.title16BoldInter.copyWith(
                      color: AppColor.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.sH),

              _buildSectionHeader('Profile Visibility'),
              SizedBox(height: 8.sH),
              _buildPrivacyToggle(
                'Show Liked Artworks',
                'Display your liked artworks on your profile',
                state.showLikedArtworks,
                    (value) => context.read<PrivacySettingsCubit>().updateShowLikedArtworks(value),
              ),

              SizedBox(height: 16.sH),

              _buildSectionHeader('Activity & Location'),
              SizedBox(height: 8.sH),
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

              SizedBox(height: 16.sH),

              _buildSectionHeader('Data Management'),
              SizedBox(height: 8.sH),
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
                    () => _showDeleteAccountDialog(),
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyleHelper.instance.body14RegularInter.copyWith(
        color: AppColor.black,
      ),
    );
  }

  Widget _buildPrivacyToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sH),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.body14RegularInter.copyWith(
                    color: AppColor.black,
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
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sH),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.sH, horizontal: 4.sW),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive ? AppColor.red : AppColor.primaryColor,
                  size: 18.sSp,
                ),
                SizedBox(width: 12.sW),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyleHelper.instance.body14RegularInter.copyWith(
                          color: isDestructive ? AppColor.red : AppColor.black,
                        ),
                      ),
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

  Widget _buildNotificationToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sH),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.body14RegularInter.copyWith(
                    color: AppColor.black,
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

  Future<void> _launchPrivacyPolicy() async {
    const url = 'https://your-app.com/privacy-policy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
