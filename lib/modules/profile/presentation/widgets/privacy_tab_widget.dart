import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';

class PrivacyTabWidget extends StatefulWidget {
  const PrivacyTabWidget({super.key});

  @override
  State<PrivacyTabWidget> createState() => _PrivacyTabWidgetState();
}

class _PrivacyTabWidgetState extends State<PrivacyTabWidget> {
  bool _profileVisibility = true;
  bool _showOnlineStatus = true;
  bool _allowMessagesFromStrangers = false;
  bool _showLikedArtworks = true;
  bool _shareActivityStatus = false;
  bool _allowTagging = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.sH, horizontal: 16.sW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(20.sW),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.sW),
              border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.1),
                width: 1.sW,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppColor.primaryColor,
                  size: 24.sSp,
                ),
                SizedBox(width: 12.sW),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy & Security',
                        style: TextStyleHelper.instance.title18BoldInter.copyWith(
                          color: AppColor.black,
                        ),
                      ),
                      SizedBox(height: 4.sH),
                      Text(
                        'Control who can see your information and how you interact with others',
                        style: TextStyleHelper.instance.body14RegularInter.copyWith(
                          color: AppColor.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.sH),

          // Profile Visibility Section
          _buildSectionHeader('Profile Visibility'),
          SizedBox(height: 12.sH),
          
          _buildPrivacyToggle(
            'Public Profile',
            'Allow others to find and view your profile',
            _profileVisibility,
            (value) => setState(() => _profileVisibility = value),
          ),
          
          _buildPrivacyToggle(
            'Show Online Status',
            'Let others see when you\'re active',
            _showOnlineStatus,
            (value) => setState(() => _showOnlineStatus = value),
          ),

          _buildPrivacyToggle(
            'Show Liked Artworks',
            'Display your liked artworks on your profile',
            _showLikedArtworks,
            (value) => setState(() => _showLikedArtworks = value),
          ),

          SizedBox(height: 24.sH),

          // Communication Section
          _buildSectionHeader('Communication'),
          SizedBox(height: 12.sH),
          
          _buildPrivacyToggle(
            'Messages from Anyone',
            'Allow messages from users you don\'t follow',
            _allowMessagesFromStrangers,
            (value) => setState(() => _allowMessagesFromStrangers = value),
          ),

          _buildPrivacyToggle(
            'Allow Tagging',
            'Let others tag you in posts and comments',
            _allowTagging,
            (value) => setState(() => _allowTagging = value),
          ),

          SizedBox(height: 24.sH),

          // Activity Section
          _buildSectionHeader('Activity'),
          SizedBox(height: 12.sH),
          
          _buildPrivacyToggle(
            'Share Activity Status',
            'Show your recent activity to followers',
            _shareActivityStatus,
            (value) => setState(() => _shareActivityStatus = value),
          ),

          SizedBox(height: 32.sH),

          // Data Management Section
          _buildSectionHeader('Data Management'),
          SizedBox(height: 12.sH),
          
          _buildActionButton(
            'Download My Data',
            'Get a copy of your information',
            Icons.download,
            () {
              // Handle download data
            },
          ),
          
          _buildActionButton(
            'Delete Account',
            'Permanently delete your account and data',
            Icons.delete_forever,
            () {
              // Handle account deletion
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyleHelper.instance.title16BoldInter.copyWith(
        color: AppColor.black,
      ),
    );
  }

  Widget _buildPrivacyToggle(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sH),
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.sW),
        border: Border.all(
          color: AppColor.gray400.withOpacity(0.3),
          width: 1.sW,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.title16RegularInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 4.sH),
                Text(
                  description,
                  style: TextStyleHelper.instance.body12MediumInter.copyWith(
                    color: AppColor.gray600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.sW),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColor.primaryColor,
            inactiveThumbColor: AppColor.gray400,
            inactiveTrackColor: AppColor.gray200,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sH),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.sW),
          child: Container(
            padding: EdgeInsets.all(16.sW),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(12.sW),
              border: Border.all(
                color: isDestructive 
                    ? AppColor.red.withOpacity(0.3)
                    : AppColor.gray400.withOpacity(0.3),
                width: 1.sW,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.sW,
                  height: 40.sW,
                  decoration: BoxDecoration(
                    color: isDestructive 
                        ? AppColor.red.withOpacity(0.1)
                        : AppColor.primaryColor.withOpacity(0.1),
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
                        style: TextStyleHelper.instance.title16RegularInter.copyWith(
                          color: isDestructive ? AppColor.red : AppColor.black,
                        ),
                      ),
                      SizedBox(height: 4.sH),
                      Text(
                        description,
                        style: TextStyleHelper.instance.body12MediumInter.copyWith(
                          color: AppColor.gray600,
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
}
