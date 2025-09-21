import 'package:baseqat/core/components/custom_widgets/custom_top_bar.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_header_widget.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_tab_navigation_widget.dart';
import 'package:baseqat/modules/profile/presentation/widgets/likes_tab_widget.dart';
import 'package:baseqat/modules/profile/presentation/widgets/chat_tab_widget.dart';
import 'package:baseqat/modules/profile/presentation/widgets/notification_tab_widget.dart';
import 'package:baseqat/modules/profile/presentation/widgets/settings_tab_widget.dart';
import 'package:flutter/material.dart';

class ProfileMobileTabletLayout extends StatelessWidget {
  const ProfileMobileTabletLayout({
    super.key,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.userId, // Adding userId parameter
  });

  final int selectedTabIndex;
  final Function(int) onTabChanged;
  final String userId; // Adding userId field

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sW),
              child: const ProfileHeaderWidget(),
            ),

            SizedBox(height: 16.sH),

            ProfileTabNavigationWidget(
              selectedTabIndex: selectedTabIndex,
              onTabTap: onTabChanged,
              tabs: const ['Likes', 'Chat', 'Notification', 'Settings'],
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.sW),
                    topRight: Radius.circular(20.sW),
                  ),
                ),
                child: _buildTabContent(selectedTabIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0: return const LikesTabWidget();
      case 1: return ChatTabWidget(userId: userId); // Passing userId to ChatTabWidget
      case 2: return const NotificationTabWidget();
      case 3: return const SettingsTabWidget();
      default: return const SizedBox.shrink();
    }
  }
}
