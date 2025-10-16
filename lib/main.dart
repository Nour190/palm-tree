import 'dart:async';
import 'dart:ui' as ui;

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; // for kReleaseMode
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/app_secure_storage.dart';
import 'package:baseqat/core/resourses/theme_manager.dart';
import 'package:baseqat/core/network/remote/supabase_config.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/scale_config.dart';
import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
import 'package:baseqat/modules/tabs/presentation/view/tabs_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:baseqat/core/database/hive_service.dart';
import 'package:baseqat/core/session/session_manager.dart';

import 'core/database/image_cache_service.dart';
import 'core/utils/deep_link_handler.dart'; // for InAppWebView
void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }
    await EasyLocalization.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
    };

    ui.PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform Error: $error');
      debugPrint('Stack trace: $stack');
      return true;
    };

    try {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      Gemini.init(apiKey: 'AIzaSyBibFQQgIWVf2rUBaQoZwP0064C5g_P4OY', enableDebugging: true);

      await SupabaseConfig.initialize();
      debugPrint('Supabase initialized successfully');

      await AppSecureStorage().init();
      debugPrint('Secure storage initialized successfully');

      await HiveService.initialize();
      debugPrint('Hive database initialized successfully');
      await ImageCacheService.initialize();
      debugPrint('Image cache service initialized successfully');

      final sessionManager = SessionManager();
      await sessionManager.restoreSession();
      if (!sessionManager.hasActiveSession) {
        await sessionManager.startSession();
      }
      debugPrint('Session manager initialized successfully');

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      runApp(
        DevicePreview(
          enabled: !kReleaseMode, // off in release
          builder: (context) => EasyLocalization(
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SA'),
              Locale('de', 'DE'),
            ],
            path: 'assets/translations',
            useOnlyLangCode: true,
            fallbackLocale: const Locale('en', 'US'),
            child: const MyApp(),
          ),
        ),
      );
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
              Text('app.initialization_failed'.tr()),
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
            BlocProvider(create: (_) => TabsCubit()),
          ],
          child: Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                key: ValueKey(context.locale.toString()), // Forces rebuild on locale change
                debugShowCheckedModeBanner: false,
                title: 'Palm tree',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: ThemeMode.light,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                // prefer DevicePreview locale (for preview) otherwise real locale
                locale: DevicePreview.locale(context) ?? context.locale,
                // important so DevicePreview's MediaQuery is used
                useInheritedMediaQuery: true,
                builder: (context, child) {
                  // keep your existing Directionality + MediaQuery wrapping
                  final isAr = context.locale.languageCode == 'ar';
                  final app = Directionality(
                    textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );

                  // wrap the app with DevicePreview.appBuilder so preview tools work
                  return DevicePreview.appBuilder(context, app);
                },
                home: const DeepLinkAwareHome(),
              );
            },
          ),
        );
      },
    );
  }
}

class DeepLinkAwareHome extends StatefulWidget {
  const DeepLinkAwareHome({super.key});

  @override
  State<DeepLinkAwareHome> createState() => _DeepLinkAwareHomeState();
}

class _DeepLinkAwareHomeState extends State<DeepLinkAwareHome> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkHandler.initialize(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkHandler.dispose();
    _endSession();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      _endSession();
    }
  }

  Future<void> _endSession() async {
    final sessionManager = SessionManager();
    await sessionManager.endSession();
  }

  @override
  Widget build(BuildContext context) {
    return TabsViewScreen();
  }
}


// main.dart
// import 'dart:async';
// import 'dart:ui' as ui;
// import 'package:baseqat/core/responsive/size_utils.dart';
// import 'package:baseqat/core/resourses/app_secure_storage.dart';
// import 'package:baseqat/core/resourses/theme_manager.dart';
// import 'package:baseqat/core/network/remote/supabase_config.dart';
// import 'package:baseqat/core/responsive/responsive.dart';
// import 'package:baseqat/core/responsive/scale_config.dart';
// import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
// import 'package:baseqat/modules/tabs/presentation/view/tabs_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:easy_localization/easy_localization.dart';
//
//
// void main() async {
//   runZonedGuarded(() async {
//     WidgetsFlutterBinding.ensureInitialized();
//
//     await EasyLocalization.ensureInitialized();
//
//     FlutterError.onError = (FlutterErrorDetails details) {
//       FlutterError.presentError(details);
//       debugPrint('Flutter Error: ${details.exception}');
//     };
//
//     ui.PlatformDispatcher.instance.onError = (error, stack) {
//       debugPrint('Platform Error: $error');
//       debugPrint('Stack trace: $stack');
//       return true;
//     };
//
//     try {
//       await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//       Gemini.init(apiKey: 'AIzaSyBibFQQgIWVf2rUBaQoZwP0064C5g_P4OY', enableDebugging: true);
//
//       await SupabaseConfig.initialize();
//       debugPrint('Supabase initialized successfully');
//
//       await AppSecureStorage().init();
//       debugPrint('Secure storage initialized successfully');
//
//       debugPrint('Dependency injection initialized successfully');
//
//       await SystemChrome.setPreferredOrientations([
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ]);
//
//       runApp(
//         EasyLocalization(
//           supportedLocales: const [
//             Locale('en', 'US'),
//             Locale('ar', 'SA'),
//             Locale('de', 'DE'),
//           ],
//           path: 'assets/translations', useOnlyLangCode: true,
//           fallbackLocale: const Locale('en', 'US'),
//           child: const MyApp(),
//         ),
//       );
//     } catch (e, stackTrace) {
//       debugPrint('Initialization error: $e');
//       debugPrint('Stack trace: $stackTrace');
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
//               Text('app.initialization_failed'.tr()),
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
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         Responsive.init(context);
//         ScaleConfig.setClamp(min: 0.75, max: 1.25);
//
//         return MultiBlocProvider(
//           providers: [
//
//             BlocProvider(create: (_) => TabsCubit()),
//
//           ],
//           child: Sizer(
//             builder: (context, orientation, deviceType) {
//               return MaterialApp(
//                 key: ValueKey(context.locale.toString()),
//                 debugShowCheckedModeBanner: false,
//                 title: 'Ithra',
//                 theme: AppTheme.light,
//                 darkTheme: AppTheme.dark,
//                 themeMode: ThemeMode.light,
//                 localizationsDelegates: context.localizationDelegates,
//                 supportedLocales: context.supportedLocales,
//                 locale: context.locale,
//                 builder: (context, child) {
//                   final isAr = context.locale.languageCode == 'ar';
//                   return Directionality(
//                     textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
//                     child: MediaQuery(
//                       data: MediaQuery.of(context).copyWith(
//                         textScaleFactor: 1.0,
//                       ),
//                       child: child ?? const SizedBox.shrink(),
//                     ),
//                   );
//                 },
//                 home: TabsViewScreen(),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }




// main.dart
// import 'dart:async';
// import 'dart:ui' as ui;
// import 'package:baseqat/core/responsive/size_utils.dart';
// import 'package:baseqat/core/resourses/app_secure_storage.dart';
// import 'package:baseqat/core/resourses/theme_manager.dart';
// import 'package:baseqat/core/network/remote/supabase_config.dart';
// import 'package:baseqat/core/responsive/responsive.dart';
// import 'package:baseqat/core/responsive/scale_config.dart';
// import 'package:baseqat/modules/tabs/presentation/manger/tabs_cubit.dart';
// import 'package:baseqat/modules/tabs/presentation/view/tabs_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:easy_localization/easy_localization.dart';
//
//
// void main() async {
//   runZonedGuarded(() async {
//     WidgetsFlutterBinding.ensureInitialized();
//
//     await EasyLocalization.ensureInitialized();
//
//     FlutterError.onError = (FlutterErrorDetails details) {
//       FlutterError.presentError(details);
//       debugPrint('Flutter Error: ${details.exception}');
//     };
//
//     ui.PlatformDispatcher.instance.onError = (error, stack) {
//       debugPrint('Platform Error: $error');
//       debugPrint('Stack trace: $stack');
//       return true;
//     };
//
//     try {
//       await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//       Gemini.init(apiKey: 'AIzaSyBibFQQgIWVf2rUBaQoZwP0064C5g_P4OY', enableDebugging: true);
//
//       await SupabaseConfig.initialize();
//       debugPrint('Supabase initialized successfully');
//
//       await AppSecureStorage().init();
//       debugPrint('Secure storage initialized successfully');
//
//       debugPrint('Dependency injection initialized successfully');
//
//       await SystemChrome.setPreferredOrientations([
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ]);
//
//       runApp(
//         EasyLocalization(
//           supportedLocales: const [
//             Locale('en', 'US'),
//             Locale('ar', 'SA'),
//             Locale('de', 'DE'),
//           ],
//           path: 'assets/translations', useOnlyLangCode: true,
//           fallbackLocale: const Locale('en', 'US'),
//           child: const MyApp(),
//         ),
//       );
//     } catch (e, stackTrace) {
//       debugPrint('Initialization error: $e');
//       debugPrint('Stack trace: $stackTrace');
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
//               Text('app.initialization_failed'.tr()),
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
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         Responsive.init(context);
//         ScaleConfig.setClamp(min: 0.75, max: 1.25);
//
//         return MultiBlocProvider(
//           providers: [
//
//             BlocProvider(create: (_) => TabsCubit()),
//
//           ],
//           child: Sizer(
//             builder: (context, orientation, deviceType) {
//               return MaterialApp(
//                 key: ValueKey(context.locale.toString()),
//                 debugShowCheckedModeBanner: false,
//                 title: 'Ithra',
//                 theme: AppTheme.light,
//                 darkTheme: AppTheme.dark,
//                 themeMode: ThemeMode.light,
//                 localizationsDelegates: context.localizationDelegates,
//                 supportedLocales: context.supportedLocales,
//                 locale: context.locale,
//                 builder: (context, child) {
//                   final isAr = context.locale.languageCode == 'ar';
//                   return Directionality(
//                     textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
//                     child: MediaQuery(
//                       data: MediaQuery.of(context).copyWith(
//                         textScaleFactor: 1.0,
//                       ),
//                       child: child ?? const SizedBox.shrink(),
//                     ),
//                   );
//                 },
//                 home: TabsViewScreen(),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
