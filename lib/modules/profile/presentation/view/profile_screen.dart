// import 'package:baseqat/core/components/custom_widgets/custom_top_bar.dart';
// import 'package:baseqat/core/resourses/assets_manager.dart';
// import 'package:baseqat/core/resourses/color_manager.dart';
// import 'package:baseqat/core/resourses/style_manager.dart';
// import 'package:baseqat/core/responsive/size_ext.dart';
// import 'package:baseqat/core/responsive/size_utils.dart';
// import 'package:baseqat/modules/profile/presentation/widgets/profile_header_widget.dart';
// import 'package:baseqat/modules/profile/presentation/widgets/profile_tab_navigation_widget.dart';
// import 'package:baseqat/modules/profile/presentation/widgets/likes_tab_widget.dart';
// import 'package:baseqat/modules/profile/presentation/widgets/chat_tab_widget.dart';
// import 'package:baseqat/modules/profile/presentation/widgets/notification_tab_widget.dart';
// import 'package:baseqat/modules/profile/presentation/widgets/settings_tab_widget.dart';
// import 'package:flutter/material.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({
//     super.key,
//     this.initialTabIndex = 0,
//   });
//
//   final int initialTabIndex;
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   int _selectedTabIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedTabIndex = widget.initialTabIndex;
//   }
//
//   void _goToTab(int index) => setState(() => _selectedTabIndex = index);
//
//   @override
//   Widget build(BuildContext context) {
//     return Sizer(
//       builder: (context, orientation, _) {
//         final w = SizeUtils.width;
//         final bool isDesktop = w >= 1200;
//         final bool isTablet = w >= 840 && w < 1200;
//
//         final double hPad = isDesktop ? 64.sW : (isTablet ? 32.sW : 16.sW);
//
//         return Scaffold(
//           backgroundColor: AppColor.white,
//           body: SafeArea(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(15.sH),
//                   child: Column(
//                     children: [
//                       SizedBox(height: 16.sH),
//
//                       TopBar(
//                         items: const ['Profile'],
//                         selectedIndex: 0,
//                         onItemTap: (index) {},
//                         onLoginTap: () {},
//                         showScanButton: true,
//                         onScanTap: () {},
//                       ),
//
//                       SizedBox(height: 24.sH),
//
//                       const ProfileHeaderWidget(),
//
//                       SizedBox(height: 24.sH),
//
//                       ProfileTabNavigationWidget(
//                         selectedTabIndex: _selectedTabIndex,
//                         onTabTap: _goToTab,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 Expanded(
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(maxWidth: 1200),
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: hPad),
//                         child: _buildTabContent(_selectedTabIndex),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTabContent(int index) {
//     switch (index) {
//       case 0: // Likes
//         return const LikesTabWidget();
//       case 1: // Chat
//         return const ChatTabWidget();
//       case 2: // Notification
//         return const NotificationTabWidget();
//       case 3: // Settings
//         return const SettingsTabWidget();
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_desktop_layout.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_mobile_tablet_layout.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  void _goToTab(int index) => setState(() => _selectedTabIndex = index);

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);

    return devType == DeviceType.desktop
        ? ProfileDesktopLayout(
      selectedTabIndex: _selectedTabIndex,
      onTabChanged: _goToTab,
    )
        : ProfileMobileTabletLayout(
      selectedTabIndex: _selectedTabIndex,
      onTabChanged: _goToTab,
    );
  }
}
