import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/notification_settings_cubit.dart';
import '../cubit/notification_settings_state.dart';
import 'package:flutter/material.dart';

import '../service/notification_settings_service.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationSettingsCubit(NotificationSettingsService.instance),
      child: const _NotificationSettingsView(),
    );
  }
}

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.gray50,
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
                  'Notification Settings',
                  style: TextStyleHelper.instance.headline24BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 8.sH),
                Text(
                  'Manage how you receive notifications and updates',
                  style: TextStyleHelper.instance.title16RegularInter.copyWith(
                    color: AppColor.gray400,
                  ),
                ),
                SizedBox(height: 32.sH),
                Expanded(
                  child: _buildDesktopContent(),
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
          'Notification Settings',
          style: TextStyleHelper.instance.title18BoldInter.copyWith(
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
            _buildMobileContent(),
          ],
        ),
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
          _buildNavItem('Notifications', true),
          _buildNavItem('Privacy', false),
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

  Widget _buildDesktopContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
            builder: (context, state) {
              if (state.status == NotificationSettingsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == NotificationSettingsStatus.error) {
                return Center(
                  child: Text(
                    'Error: ${state.error}',
                    style: TextStyleHelper.instance.body14RegularInter.copyWith(
                      color: Colors.red,
                    ),
                  ),
                );
              }

              return _buildDesktopCard(
                'General Notifications',
                'Configure how you receive notifications',
                [
                  _buildDesktopToggle(
                    'Push Notifications',
                    'Receive push notifications on your device',
                    state.isPushEnabled,
                        (value) => context.read<NotificationSettingsCubit>().togglePushNotifications(value),
                  ),
                  _buildDesktopToggle(
                    'Email Notifications',
                    'Receive notifications via email',
                    state.isEmailEnabled,
                        (value) => context.read<NotificationSettingsCubit>().toggleEmailNotifications(value),
                  ),
                  _buildDesktopToggle(
                    'SMS Notifications',
                    'Receive notifications via SMS',
                    state.isSmsEnabled,
                        (value) => context.read<NotificationSettingsCubit>().toggleSmsNotifications(value),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('General Notifications'),
        SizedBox(height: 16.sH),
        BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
          builder: (context, state) {
            if (state.status == NotificationSettingsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == NotificationSettingsStatus.error) {
              return Center(
                child: Text(
                  'Error: ${state.error}',
                  style: TextStyleHelper.instance.body14RegularInter.copyWith(
                    color: Colors.red,
                  ),
                ),
              );
            }

            return Column(
              children: [
                _buildNotificationToggle(
                  'Push Notifications',
                  'Receive push notifications on your device',
                  state.isPushEnabled,
                      (value) => context.read<NotificationSettingsCubit>().togglePushNotifications(value),
                ),
                _buildNotificationToggle(
                  'Email Notifications',
                  'Receive notifications via email',
                  state.isEmailEnabled,
                      (value) => context.read<NotificationSettingsCubit>().toggleEmailNotifications(value),
                ),
                _buildNotificationToggle(
                  'SMS Notifications',
                  'Receive notifications via SMS',
                  state.isSmsEnabled,
                      (value) => context.read<NotificationSettingsCubit>().toggleSmsNotifications(value),
                ),
              ],
            );
          },
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
                  style: TextStyleHelper.instance.title14MediumInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 4.sH),
                Text(
                  subtitle,
                  style: TextStyleHelper.instance.caption12RegularInter.copyWith(
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

  Widget _buildNotificationToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
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
                  style: TextStyleHelper.instance.title14MediumInter.copyWith(
                    color: AppColor.black,
                  ),
                ),
                SizedBox(height: 4.sH),
                Text(
                  subtitle,
                  style: TextStyleHelper.instance.caption12RegularInter.copyWith(
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
