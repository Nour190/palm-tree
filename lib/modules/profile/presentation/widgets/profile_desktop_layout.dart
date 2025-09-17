import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/profile/presentation/widgets/likes_tab_widget.dart';
import 'package:baseqat/modules/profile/presentation/widgets/chat_tab_widget.dart';
import 'package:baseqat/modules/profile/presentation/widgets/notification_tab_widget.dart';
import 'package:baseqat/modules/profile/presentation/widgets/settings_tab_widget.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/custom_widgets/custom_top_bar.dart';

class ProfileDesktopLayout extends StatelessWidget {
  const ProfileDesktopLayout({
    super.key,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  final int selectedTabIndex;
  final Function(int) onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Row(
        children: [
          // Left Sidebar - Profile Info & Navigation
          Container(
            width: 320.sW,
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border(
                right: BorderSide(
                  color: AppColor.gray.withOpacity(0.2),
                  width: 1.sW,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(0.05),
                  blurRadius: 10.sW,
                  offset: Offset(2.sW, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Header Section
                Container(
                  padding: EdgeInsets.all(32.sSp),
                  child: Column(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 120.sW,
                        height: 120.sH,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.primaryColor.withOpacity(0.2),
                            width: 3.sW,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryColor.withOpacity(0.1),
                              blurRadius: 20.sW,
                              spreadRadius: 2.sW,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppAssetsManager.imgPhoto,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.primaryColor.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 60.sW,
                                  color: AppColor.primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 20.sH),

                      // User Name
                      Text(
                        'John Doe',
                        style: TextStyleHelper.instance.headline24BoldInter.copyWith(
                          color: AppColor.black,
                        ),
                      ),

                      // SizedBox(height: 8.sH),
                      //
                      // // User Email/Handle
                      // Text(
                      //   '@johndoe',
                      //   style: TextStyleHelper.instance.title16RegularInter.copyWith(
                      //     color: AppColor.gray,
                      //   ),
                      // ),
                      //
                      // SizedBox(height: 24.sH),
                      //
                      // // Stats Row
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     _buildStatItem('Posts', '124'),
                      //     Container(
                      //       width: 1.sW,
                      //       height: 40.sH,
                      //       color: AppColor.gray.withOpacity(0.3),
                      //     ),
                      //     _buildStatItem('Following', '256'),
                      //     Container(
                      //       width: 1.sW,
                      //       height: 40.sH,
                      //       color: AppColor.gray.withOpacity(0.3),
                      //     ),
                      //     _buildStatItem('Followers', '1.2K'),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                // Navigation Tabs
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.sW),
                    child: Column(
                      children: [
                        _buildNavItem(0, Icons.favorite_outline, 'Likes'),
                        _buildNavItem(1, Icons.chat_bubble_outline, 'Chat'),
                        _buildNavItem(2, Icons.notifications_outlined, 'Notifications'),
                        _buildNavItem(3, Icons.settings_outlined, 'Settings'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(32.sSp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.sH),
                    child: TopBar(
                      items: const ['Home', 'Events', 'Profile', 'More'],
                      selectedIndex: 2, // Profile is selected
                      onItemTap: (index) {
                        // Handle main app navigation
                      },
                      onLoginTap: () {},
                      showScanButton: true,
                      onScanTap: () {},
                      compactOnMobile: true,
                    ),
                  ),

                  // Content Header
                  Container(
                    padding: EdgeInsets.only(bottom: 24.sH),
                    child: Row(
                      children: [
                        Text(
                          _getTabTitle(selectedTabIndex),
                          style: TextStyleHelper.instance.headline32BoldInter.copyWith(
                            color: AppColor.black,
                          ),
                        ),
                        const Spacer(),
                        // Action buttons can be added here
                      ],
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(12.sW),
                        border: Border.all(
                          color: AppColor.gray.withOpacity(0.2),
                          width: 1.sW,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.black.withOpacity(0.05),
                            blurRadius: 10.sW,
                            spreadRadius: 1.sW,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.sW),
                        child: _buildTabContent(selectedTabIndex),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyleHelper.instance.title20RegularRoboto.copyWith(
            color: AppColor.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.sH),
        Text(
          label,
          style: TextStyleHelper.instance.body12LightInter.copyWith(
            color: AppColor.gray,
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final bool isSelected = selectedTabIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: 8.sH),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabChanged(index),
          borderRadius: BorderRadius.circular(12.sW),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: 16.sW,
              vertical: 16.sH,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.sW),
              border: isSelected
                  ? Border.all(
                color: AppColor.primaryColor.withOpacity(0.3),
                width: 1.sW,
              )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColor.primaryColor : AppColor.gray,
                  size: 24.sW,
                ),
                SizedBox(width: 16.sW),
                Text(
                  title,
                  style: TextStyleHelper.instance.title16MediumInter.copyWith(
                    color: isSelected ? AppColor.primaryColor : AppColor.gray,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0: return 'Liked Posts';
      case 1: return 'Messages';
      case 2: return 'Notifications';
      case 3: return 'Settings';
      default: return 'Profile';
    }
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0: return const LikesTabWidget();
      case 1: return const ChatTabWidget();
      case 2: return const NotificationTabWidget();
      case 3: return const SettingsTabWidget();
      default: return const SizedBox.shrink();
    }
  }
}
