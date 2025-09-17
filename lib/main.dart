// import 'dart:async';
// import 'dart:ui';
// import 'package:baseqat/core/services_locator/dependency_injection.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:sizer/sizer.dart'; // Import Sizer package
// import 'core/resourses/app_secure_storage.dart';
// import 'core/resourses/theme_manager.dart';
// import 'core/network/remote/supabase_config.dart';
// import 'core/responsive/responsive.dart';
// import 'core/responsive/scale_config.dart';
// import 'core/responsive/size_utils.dart';
// import 'modules/auth/login/presentation/view/login_screen.dart';
// import 'modules/profile/presentation/view/profile_screen.dart';
//
// void main() async {
//   runZonedGuarded(() async {
//     WidgetsFlutterBinding.ensureInitialized();
//
//     // Set up global error handlers
//     FlutterError.onError = (FlutterErrorDetails details) {
//       FlutterError.presentError(details);
//       debugPrint('Flutter Error: ${details.exception}');
//     };
//
//     PlatformDispatcher.instance.onError = (error, stack) {
//       debugPrint('Platform Error: $error');
//       debugPrint('Stack trace: $stack');
//       return true;
//     };
//
//     try {
//       SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//
//       await SupabaseConfig.initialize();
//       debugPrint('Supabase initialized successfully');
//
//       await AppSecureStorage().init();
//       debugPrint('Secure storage initialized successfully');
//
//       await diInit();
//       debugPrint('Dependency injection initialized successfully');
//
//       await SystemChrome.setPreferredOrientations([
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ]);
//
//       runApp(const MyApp());
//     } catch (e, stackTrace) {
//       debugPrint('Initialization error: $e');
//       debugPrint('Stack trace: $stackTrace');
//       // You could show an error screen here instead of crashing
//       runApp(ErrorApp(error: e.toString()));
//     }
//   }, (error, stack) {
//     debugPrint('Unhandled error: $error');
//     debugPrint('Stack trace: $stack');
//   });
// }
//
// class ErrorApp extends StatelessWidget {
//   final String error;
//
//   const ErrorApp({super.key, required this.error});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               const Text('App Initialization Failed'),
//               const SizedBox(height: 8),
//               Text(error, textAlign: TextAlign.center),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812), // iPhone 11 Pro design size
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         Responsive.init(context);
//         ScaleConfig.setClamp(min: 0.75, max: 1.25);
//         return Sizer(
//           builder: (context, orientation, deviceType) {
//             return MaterialApp(
//               debugShowCheckedModeBanner: false,
//               title: 'Ithra',
//               theme: AppTheme.light,
//               builder: (context, child) {
//                 return MediaQuery(
//                   data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
//                   child: child!,
//                 );
//               },
//               home:
//               //ProfileScreen()
//               loginScreen(), // Corrected the case of the class name
//             );
//           },
//         );
//       },
//     );
//   }
// }
// main.dart
import 'dart:async';
import 'dart:ui';

import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/services_locator/dependency_injection.dart';
import 'package:baseqat/core/resourses/app_secure_storage.dart';
import 'package:baseqat/core/resourses/theme_manager.dart';
import 'package:baseqat/core/network/remote/supabase_config.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/scale_config.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
import 'package:baseqat/modules/tabs/presentation/view/tabs_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'modules/auth/auth/presentation/auth_gate.dart';
import 'modules/auth/logic/auth_gate_cubit/auth_cubit.dart';
import 'modules/auth/logic/login_cubit/login_cubit.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform Error: $error');
      debugPrint('Stack trace: $stack');
      return true;
    };

    try {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      await SupabaseConfig.initialize();
      debugPrint('Supabase initialized successfully');

      await AppSecureStorage().init();
      debugPrint('Secure storage initialized successfully');

      await diInit();
      debugPrint('Dependency injection initialized successfully');

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      runApp(const MyApp());
    } catch (e, stackTrace) {
      debugPrint('Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      runApp(ErrorApp(error: e.toString()));
    }
  }, (error, stack) {
    debugPrint('Unhandled error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('App Initialization Failed'),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        Responsive.init(context);
        ScaleConfig.setClamp(min: 0.75, max: 1.25);

        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<LoginCubit>()),
            BlocProvider(create: (_) => TabsCubit()),
            BlocProvider(create: (_) => AuthCubit()),
          ],
          child: Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Ithra',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: ThemeMode.light,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
                    child: child!,
                  );
                },
                home:
                //ProfileScreen(),
                const AuthGate(),
              );
            },
          ),
        );
      },
    );
  }
}


