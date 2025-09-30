import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/profile/presentation/view/privacy_settings_screen.dart';
import 'package:baseqat/modules/profile/presentation/view/notification_settings_screen.dart';
import 'package:baseqat/modules/auth/logic/auth_gate_cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../view/account_settings_screen.dart';

class SettingsTabWidget extends StatelessWidget {
  const SettingsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsItems = [
      {
        'title': 'Account',
        'icon': Icons.person,
        'onTap': () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountSettingsScreen(),
            ),
          );
          // Handle account settings
        },
      },
      {
        'title': 'Privacy',
        'icon': Icons.privacy_tip,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrivacySettingsScreen(),
            ),
          );
        },
      },
      {
        'title': 'Notification',
        'icon': Icons.notifications,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationSettingsScreen(),
            ),
          );
        },
      },
      // {
      //   'title': 'Passwords',
      //   'icon': Icons.key,
      //   'onTap': () {
      //     // Handle password settings
      //   },
      // },
      // {
      //   'title': 'Language',
      //   'icon': Icons.language,
      //   'onTap': () {
      //     // Handle language settings
      //   },
      // },
      {
        'title': 'Logout',
        'icon': Icons.logout,
        'isExit': true,
        'onTap': () {
          _showLogoutDialog(context);
        },
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.sH),
      child: Column(
        children: settingsItems.map((item) => _buildSettingsItem(item)).toList(),
      ),
    );
  }

  Widget _buildSettingsItem(Map<String, dynamic> item) {
    final isExit = item['isExit'] as bool? ?? false;

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
              Icons.arrow_forward_ios,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyleHelper.instance.title18BoldInter,
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyleHelper.instance.body14RegularInter,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyleHelper.instance.body14RegularInter.copyWith(
                  color: AppColor.gray400,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Call logout from AuthCubit
                context.read<AuthCubit>().logout();
              },
              child: Text(
                'Logout',
                style: TextStyleHelper.instance.title14BoldInter.copyWith(
                  color: AppColor.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
