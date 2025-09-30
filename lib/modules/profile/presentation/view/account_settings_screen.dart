import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/services_locator/dependency_injection.dart';
import 'package:baseqat/core/resourses/constants_manager.dart';
import 'package:baseqat/core/utils/global_storage_utils.dart';
import '../cubit/account_settings_cubit.dart';
import '../cubit/account_settings_state.dart';
import '../widgets/account_settings_mobile_layout.dart';
import '../widgets/account_settings_desktop_layout.dart';
import '../../data/repositories/profile_repository.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AppConstants.userIdValue;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found. Please login again.'),
        ),
      );
    }

    // Load profile data using the global cubit instance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountSettingsCubit>().loadProfile(userId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AccountSettingsCubit, AccountSettingsState>(
        listener: (context, state) {
          if (state is AccountSettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AccountSettingsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: const AccountSettingsResponsiveLayout(),
      ),
    );
  }
}

class AccountSettingsResponsiveLayout extends StatelessWidget {
  const AccountSettingsResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);

    return deviceType == DeviceType.desktop
        ? const AccountSettingsDesktopLayout()
        : const AccountSettingsMobileLayout();
  }
}
