// // lib/widgets/auth_gate.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/resourses/color_manager.dart';
// import '../../../tabs/presentation/view/tabs_view.dart';
// import '../../logic/auth_gate_cubit/auth_cubit.dart';
// import '../../logic/auth_gate_cubit/auth_state.dart';
// import '../../login/presentation/view/login_screen.dart';
//
//
// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, state) {
//         if (state is AuthLoading) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator(color:AppColor.primaryColor ,)),
//           );
//         } else if (state is AuthAuthenticated) {
//           return const TabsViewScreen();
//         } else if (state is AuthUnauthenticated) {
//
//           return const loginScreen();
//         } else if (state is AuthError) {
//           return Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('Error: ${state.message}'),
//                   const SizedBox(height: 12),
//                   ElevatedButton(
//                     onPressed: () => context.read<AuthCubit>().checkAuth(),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         } else {
//           return const loginScreen();
//         }
//       },
//     );
//   }
// }


// lib/widgets/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resourses/color_manager.dart';
import '../../../../core/resourses/constants_manager.dart';
import '../../../tabs/presentation/view/tabs_view.dart';
import '../../logic/auth_gate_cubit/auth_cubit.dart';
import '../../logic/auth_gate_cubit/auth_state.dart';
import '../../login/presentation/view/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColor.primaryColor,
              ),
            ),
          );
        }
        else if (state is AuthAuthenticated) {
          AppConstants.tokenValue=state.userData[AppConstants.tokenKey];
          AppConstants.userIdValue=state.userData[AppConstants.userId];
          debugPrint("✅ User Token: ${state.userData[AppConstants.tokenKey]}");
          debugPrint("✅ User Id: ${state.userData[AppConstants.userId]}");
          // print("");
          return const TabsViewScreen();
        }
        else if (state is AuthUnauthenticated) {
          return const loginScreen();
        }
        else if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<AuthCubit>().checkAuth(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        else {
          return const loginScreen();
        }
      },
    );
  }
}

