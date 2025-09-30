import 'package:baseqat/core/resourses/constants_manager.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_desktop_layout.dart';
import 'package:baseqat/modules/profile/presentation/widgets/profile_mobile_tablet_layout.dart';
import 'package:baseqat/modules/profile/presentation/cubit/favorites_cubit.dart';
import 'package:baseqat/modules/profile/presentation/cubit/conversations_cubit.dart';
import 'package:baseqat/modules/profile/presentation/cubit/privacy_settings_cubit.dart';
import 'package:baseqat/modules/profile/presentation/cubit/account_settings_cubit.dart';
import 'package:baseqat/modules/profile/data/services/privacy_settings_service.dart';
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
  String? userId = AppConstants.userIdValue;
  // bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;

    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AccountSettingsCubit>().loadProfile(userId!);
      });
    }
  }

  void _goToTab(int index) => setState(() => _selectedTabIndex = index);

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);

    // if (_isLoading) {
    //   return const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

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
        BlocProvider(
          create: (context) => PrivacySettingsCubit(PrivacySettingsService.instance)..loadSettings(),
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
