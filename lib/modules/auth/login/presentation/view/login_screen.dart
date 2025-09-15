import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/services_locator/dependency_injection.dart';
import '../../../logic/login_cubit/login_cubit.dart';
import '../widgets/login_desktop_view.dart';
import '../widgets/login_mobile_tablet_view.dart';

class loginScreen extends StatelessWidget {
  const loginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);
    return BlocProvider(
      create: (context) => sl<LoginCubit>(),
      child: devType == DeviceType.desktop
          ? const loginDesktop()
          : const loginMobileTablet(),
    );
  }
}
