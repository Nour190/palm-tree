import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:flutter/material.dart';

class PrivacyPageView extends StatefulWidget {
  const PrivacyPageView({super.key});

  @override
  State<PrivacyPageView> createState() => _PrivacyPageViewState();
}

class _PrivacyPageViewState extends State<PrivacyPageView> {
  bool profileVisibility = true;
  bool dataSharing = false;
  bool activityTracking = true;
  bool locationSharing = false;
  bool contactSync = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.black, size: 20.sSp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Settings',
          style: TextStyleHelper.instance.title14BoldInter.copyWith(
            color: AppColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sW),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Privacy',
              style: TextStyleHelper.instance.title14BoldInter.copyWith(
                color: AppColor.black,
              ),
            ),
            SizedBox(height: 16.sH),
            _buildPrivacyItem(
              'Profile Visibility',
              'Make your profile visible to other users',
              profileVisibility,
              (value) => setState(() => profileVisibility = value),
            ),
            _buildPrivacyItem(
              'Data Sharing',
              'Share your data with third-party services',
              dataSharing,
              (value) => setState(() => dataSharing = value),
            ),
            SizedBox(height: 24.sH),
            Text(
              'Activity & Location',
              style: TextStyleHelper.instance.title14BoldInter.copyWith(
                color: AppColor.black,
              ),
            ),
            SizedBox(height: 16.sH),
            _buildPrivacyItem(
              'Activity Tracking',
              'Allow tracking of your app activity',
              activityTracking,
              (value) => setState(() => activityTracking = value),
            ),
            _buildPrivacyItem(
              'Location Sharing',
              'Share your location with the app',
              locationSharing,
              (value) => setState(() => locationSharing = value),
            ),
            SizedBox(height: 24.sH),
            Text(
              'Contacts & Communication',
              style: TextStyleHelper.instance.title14BoldInter.copyWith(
                color: AppColor.black,
              ),
            ),
            SizedBox(height: 16.sH),
            _buildPrivacyItem(
              'Contact Sync',
              'Sync your contacts with the app',
              contactSync,
              (value) => setState(() => contactSync = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyItem(String title, String subtitle, bool value, Function(bool) onChanged) {
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
}
