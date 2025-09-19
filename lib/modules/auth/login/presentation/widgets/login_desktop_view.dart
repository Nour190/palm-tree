// // import 'package:baseqat/core/responsive/size_ext.dart';
// // import 'package:baseqat/modules/auth/login/presentation/widgets/login_form.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../../../../../core/resourses/assets_manager.dart';
// // import '../../../../../core/resourses/color_manager.dart';
// // import '../../../../../core/resourses/style_manager.dart';
// // import '../../../../home/presentation/view/home_tablet_view.dart';
// // import '../../../logic/login_cubit/login_cubit.dart';
// // import '../../../logic/login_cubit/login_states.dart';
// //
// // class loginDesktop extends StatelessWidget {
// //   const loginDesktop({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final maxFormWidth = 800.sW;
// //
// //     return BlocListener<LoginCubit, LoginStates>(
// //       listener: (context, state) {
// //         if (state is LoginSuccessState) {
// //           Navigator.of(context).pushReplacement(
// //             MaterialPageRoute(builder: (context) => const HomeTabletView()),
// //           );
// //           // ScaffoldMessenger.of(context).showSnackBar(
// //           //   const SnackBar(
// //           //     content: Text('Login successful!'),
// //           //     backgroundColor: AppColor.black,
// //           //   ),
// //           // );
// //         } else if (state is LoginErrorState) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: Text(state.errorMessage),
// //               backgroundColor: AppColor.red,
// //             ),
// //           );
// //         }
// //       },
// //       child: Scaffold(
// //         backgroundColor: AppColor.white,
// //         body: SafeArea(
// //           child: Row(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               Expanded(
// //                 flex: 5,
// //                 child: Container(
// //                   color: AppColor.backgroundWhite,
// //                   padding: EdgeInsets.all(32.sW),
// //                   child: Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Image.asset(AppAssetsManager.appLogo, width: 120.sW,height: 120.sH,),
// //                         Text("ithra",style: TextStyleHelper.instance.display48BlackBoldInter),
// //                         SizedBox(height: 10.sH),
// //                         Text('Welcome to Ithra',
// //                             style: TextStyleHelper.instance.headline32BoldInter),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               // Right side (form)
// //               Expanded(
// //                 flex: 7,
// //                 child: Container(
// //                   color: AppColor.white,
// //                   child: Center(
// //                     child: SingleChildScrollView(
// //                       child: loginForm(width: maxFormWidth),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:baseqat/core/responsive/size_ext.dart';
// import 'package:baseqat/modules/auth/login/presentation/widgets/login_form.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../../../core/resourses/assets_manager.dart';
// import '../../../../../core/resourses/color_manager.dart';
// import '../../../../../core/resourses/style_manager.dart';
// import '../../../../home/presentation/view/home_tablet_view.dart';
// import '../../../logic/login_cubit/login_cubit.dart';
// import '../../../logic/login_cubit/login_states.dart';
// import 'dart:async';
//
// class loginDesktop extends StatefulWidget {
//   const loginDesktop({super.key});
//
//   @override
//   State<loginDesktop> createState() => _loginDesktopState();
// }
//
// class _loginDesktopState extends State<loginDesktop> with SingleTickerProviderStateMixin {
//   late StreamSubscription<AuthState> _authStateSubscription;
//   bool _isListeningForCallback = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // // Initialize loading animation
//     // _loadingController = AnimationController(
//     //   duration: const Duration(seconds: 2),
//     //   vsync: this,
//     // );
//     //
//     // _loadingAnimation = Tween<double>(
//     //   begin: 0.0,
//     //   end: 1.0,
//     // ).animate(CurvedAnimation(
//     //   parent: _loadingController,
//     //   curve: Curves.easeInOut,
//     // ));
//
//     // Listen to auth state changes for OAuth callback
//     _setupAuthListener();
//
//     // Check if we're returning from OAuth redirect
//     _checkInitialAuthState();
//   }
//
//   void _setupAuthListener() {
//     final supabase = Supabase.instance.client;
//
//     _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
//       final event = data.event;
//       final session = data.session;
//
//       // Handle OAuth callback
//       if (_isListeningForCallback && event == AuthChangeEvent.signedIn && session != null) {
//         _handleOAuthSuccess(session);
//       }
//     });
//   }
//
//   void _checkInitialAuthState() async {
//     // Check if we're returning from OAuth redirect by looking at the URL
//     final uri = Uri.base;
//     if (uri.fragment.contains('access_token') || uri.queryParameters.containsKey('code')) {
//       setState(() {
//         _isListeningForCallback = true;
//       });
//       // _loadingController.repeat();
//
//       // Give Supabase time to process the OAuth callback
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       final session = Supabase.instance.client.auth.currentSession;
//       if (session != null) {
//         _handleOAuthSuccess(session);
//       }
//     }
//   }
//
//   void _handleOAuthSuccess(Session session) async {
//     // _loadingController.stop();
//
//     // Save token using your existing logic
//     final loginCubit = context.read<LoginCubit>();
//     await loginCubit.saveTokenDirectly(session.refreshToken!);
//
//     // Navigate to home
//     if (mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const HomeTabletView()),
//             (Route<dynamic> route) => false,
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _authStateSubscription.cancel();
//     // _loadingController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final maxFormWidth = 800.sW;
//
//     return BlocListener<LoginCubit, LoginStates>(
//       listener: (context, state) {
//         if (state is LoginSuccessState) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const HomeTabletView()),
//           );
//         } else if (state is LoginErrorState) {
//           setState(() {
//             _isListeningForCallback = false;
//           });
//           // _loadingController.stop();
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage),
//               backgroundColor: AppColor.red,
//             ),
//           );
//         } else if (state is LoginRedirectingState) {
//           setState(() {
//             _isListeningForCallback = true;
//           });
//           // _loadingController.repeat();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppColor.white,
//         body: SafeArea(
//           child: Stack(
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Expanded(
//                     flex: 5,
//                     child: Container(
//                       color: AppColor.backgroundWhite,
//                       padding: EdgeInsets.all(32.sW),
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(AppAssetsManager.appLogo, width: 120.sW, height: 120.sH),
//                             Text("ithra", style: TextStyleHelper.instance.display48BlackBoldInter),
//                             SizedBox(height: 10.sH),
//                             Text('Welcome to Ithra',
//                                 style: TextStyleHelper.instance.headline32BoldInter),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Right side (form)
//                   Expanded(
//                     flex: 7,
//                     child: Container(
//                       color: AppColor.white,
//                       child: Center(
//                         child: SingleChildScrollView(
//                           child: loginForm(width: maxFormWidth),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // OAuth Loading Overlay
//               // if (_isListeningForCallback)
//               //   Container(
//               //     color: Colors.black.withOpacity(0.7),
//               //     child: Center(
//               //       child: Column(
//               //         mainAxisAlignment: MainAxisAlignment.center,
//               //         children: [
//               //           Container(
//               //             padding: EdgeInsets.all(32.sW),
//               //             decoration: BoxDecoration(
//               //               color: AppColor.white,
//               //               borderRadius: BorderRadius.circular(16),
//               //             ),
//               //             child: Column(
//               //               children: [
//               //                 SizedBox(
//               //                   width: 80.sW,
//               //                   height: 80.sH,
//               //                   child: Stack(
//               //                     children: [
//               //                       Center(
//               //                         child: AnimatedBuilder(
//               //                           animation: _loadingAnimation,
//               //                           builder: (context, child) {
//               //                             return CircularProgressIndicator(
//               //                               value: _loadingAnimation.value,
//               //                               strokeWidth: 3,
//               //                               valueColor: AlwaysStoppedAnimation<Color>(
//               //                                 AppColor.primaryColor,
//               //                               ),
//               //                             );
//               //                           },
//               //                         ),
//               //                       ),
//               //                       Center(
//               //                         child: Icon(
//               //                           Icons.lock_outline,
//               //                           size: 32.sW,
//               //                           color: AppColor.primaryColor,
//               //                         ),
//               //                       ),
//               //                     ],
//               //                   ),
//               //                 ),
//               //                 SizedBox(height: 24.sH),
//               //                 Text(
//               //                   'Completing Google Sign In...',
//               //                   style: TextStyleHelper.instance.headline24BoldInter,
//               //                 ),
//               //                 SizedBox(height: 8.sH),
//               //                 Text(
//               //                   'Please wait while we authenticate',
//               //                   style: TextStyleHelper.instance.title16RegularInter.
//               //                       copyWith(color: AppColor.gray),
//               //                 ),
//               //               ],
//               //             ),
//               //
//               //         ],
//               //       ),
//               //     ),
//               //   ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/modules/auth/login/presentation/views/login_desktop.dart
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/auth/login/presentation/widgets/login_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/resourses/assets_manager.dart';
import '../../../../../core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
// import '../../../../home/presentation/view/home_tablet_view.dart';
import '../../../../tabs/presentation/view/tabs_view.dart';
import '../../../logic/auth_gate_cubit/auth_cubit.dart';
import '../../../logic/login_cubit/login_cubit.dart';
import '../../../logic/login_cubit/login_states.dart';

class loginDesktop extends StatefulWidget {
  const loginDesktop({super.key});

  @override
  State<loginDesktop> createState() => _loginDesktopState();
}

class _loginDesktopState extends State<loginDesktop> {
  //bool _isListeningForCallback = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LoginCubit>();
    cubit.startAuthListener();
    cubit.checkInitialAuthState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  //
  // @override
  // Widget build(BuildContext context) {
  //   final maxFormWidth = 800.sW;
  //
  //   return BlocListener<LoginCubit, LoginStates>(
  //     listener: (context, state) {
  //       if (state is LoginSuccessState) {
  //         Navigator.of(context).pushAndRemoveUntil(
  //           MaterialPageRoute(builder: (context) => const TabsViewScreen()),
  //               (Route<dynamic> route) => false,
  //         );
  //       } else if (state is LoginErrorState) {
  //         // setState(() {
  //         //   _isListeningForCallback = false;
  //         // });
  //
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(state.errorMessage),
  //             backgroundColor: AppColor.red,
  //           ),
  //         );
  //       } else if (state is LoginRedirectingState) {
  //         // setState(() {
  //         //   _isListeningForCallback = true;
  //         // });
  //       }
  //     },
  //     child: Scaffold(
  //       backgroundColor: AppColor.white,
  //       body: SafeArea(
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Expanded(
  //               flex: 5,
  //               child: Container(
  //                 color: AppColor.backgroundWhite,
  //                 padding: EdgeInsets.all(32.sW),
  //                 child: Center(
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Image.asset(AppAssetsManager.appLogo, width: 120.sW, height: 120.sH),
  //                       Text("ithra", style: TextStyleHelper.instance.display48BlackBoldInter),
  //                       SizedBox(height: 10.sH),
  //                       Text('Welcome to Ithra',
  //                           style: TextStyleHelper.instance.headline32BoldInter),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 7,
  //               child: Container(
  //                 color: AppColor.white,
  //                 child: Center(
  //                   child: SingleChildScrollView(
  //                     child: loginForm(width: maxFormWidth),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final maxFormWidth = 800.sW;

    return BlocListener<LoginCubit, LoginStates>(
      listener: (context, state) {
      if (state is LoginSuccessState) {

        context.read<AuthCubit>().notifyLoggedIn();
      }
        if (state is LoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColor.red,
            ),
          );
        } else if (state is LoginRedirectingState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Redirecting to Google for sign in...')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  color: AppColor.backgroundWhite,
                  padding: EdgeInsets.all(32.sW),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppAssetsManager.appLogo, width: 120.sW, height: 120.sH),
                        Text("ithra", style: TextStyleHelper.instance.display48BlackBoldInter),
                        SizedBox(height: 10.sH),
                        Text('Welcome to Ithra', style: TextStyleHelper.instance.headline32BoldInter),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  color: AppColor.white,
                  child: Center(
                    child: SingleChildScrollView(
                      child: loginForm(width: maxFormWidth),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
