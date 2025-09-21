import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_desktop_layout.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_mobile_tablet_layout.dart';
import 'package:baseqat/modules/profile/presentation/cubit/favorites_cubit.dart';
import 'package:baseqat/modules/profile/presentation/cubit/conversations_cubit.dart';
import 'package:baseqat/core/services_locator/dependency_injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  static const String userId = "031af91c-319d-4ef4-bec8-7d14a3d68dde";

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  void _goToTab(int index) => setState(() => _selectedTabIndex = index);

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<FavoritesCubit>()..init(userId: userId),
        ),
        BlocProvider(
          create: (context) => sl<ConversationsCubit>()..loadFirst(userId: userId),
        ),
      ],
      child: devType == DeviceType.desktop
          ? ProfileDesktopLayout(
        selectedTabIndex: _selectedTabIndex,
        onTabChanged: _goToTab,
        userId: userId, // Passing userId to desktop layout
      )
          : ProfileMobileTabletLayout(
        selectedTabIndex: _selectedTabIndex,
        onTabChanged: _goToTab,
        userId: userId, // Passing userId to mobile layout
      ),
    );
  }
}
