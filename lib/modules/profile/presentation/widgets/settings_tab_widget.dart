import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';

class SettingsTabWidget extends StatelessWidget {
  const SettingsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsItems = [
      {
        'title': 'Account',
        'icon': Icons.person,
      },
      {
        'title': 'Privacy',
        'icon': Icons.lock,
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications,
      },
      {
        'title': 'Passwords',
        'icon': Icons.key,
      },
      {
        'title': 'Language',
        'icon': Icons.language,
      },
      {
        'title': 'Exit',
        'icon': Icons.exit_to_app,
        'isExit': true,
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
            onTap: () {
              // Handle settings item tap
            },
          ),
        ),
        SizedBox(height: 4.sH,),
        Divider(
          color: AppColor.grey200,
          thickness: 2,
          height: 2,
          indent: 40.sW, // Align with text content
          endIndent: 16.sW,
        ),
      ],

    );
  }
}
