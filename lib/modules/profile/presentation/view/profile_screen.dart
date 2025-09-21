import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_desktop_layout.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_mobile_tablet_layout.dart';
import 'package:baseqat/modules/profile/presentation/cubit/favorites_cubit.dart';
import 'package:baseqat/modules/profile/presentation/cubit/conversations_cubit.dart';
import 'package:baseqat/core/services_locator/dependency_injection.dart';
import 'package:baseqat/core/utils/global_storage_utils.dart';
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
  String? userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userIdFromStorage = await GlobalStorageUtils.getUserId();
      if (userIdFromStorage != null) {
        setState(() {
          userId = userIdFromStorage;
          _isLoading = false;
        });
      } else {
        // Handle case where no user data is found
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error loading user data
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToTab(int index) => setState(() => _selectedTabIndex = index);

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('User data not found. Please login again.'),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<FavoritesCubit>()..init(userId: userId!),
        ),
        BlocProvider(
          create: (context) => sl<ConversationsCubit>()..loadFirst(userId: userId!),
        ),
      ],
      child: devType == DeviceType.desktop
          ? ProfileDesktopLayout(
        selectedTabIndex: _selectedTabIndex,
        onTabChanged: _goToTab,
        userId: userId!,
      )
          : ProfileMobileTabletLayout(
        selectedTabIndex: _selectedTabIndex,
        onTabChanged: _goToTab,
        userId: userId!,
      ),
    );
  }
}
