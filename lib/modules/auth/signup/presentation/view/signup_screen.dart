import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/services_locator/dependency_injection.dart';
import '../../../logic/register_cubit/register_cubit.dart';
import '../widgets/signup_desktop_view.dart';
import '../widgets/signup_mobile_tablet_view.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);
    return BlocProvider(
      create: (context) => sl<RegisterCubit>(),
      child: devType == DeviceType.desktop
          ? const SignUpDesktop()
          : const SignUpMobileTablet(),
    );
  }
}
