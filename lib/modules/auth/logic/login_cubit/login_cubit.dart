// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../../core/resourses/app_secure_storage.dart';
// import '../../../../core/resourses/constants_manager.dart';
// import '../../data/models/auth_request_model.dart';
// import '../../data/repos/auth_repo.dart';
// import 'login_states.dart';
//
// class LoginCubit extends Cubit<LoginStates> {
//   final AuthRepo authRepo;
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   StreamSubscription<AuthState>? _authStateSubscription;
//   bool _isListeningForCallback = false;
//   LoginCubit(this.authRepo) : super(LoginInitialState());
//
//   Future<void> login() async {
//     emit(LoginLoadingState());
//     final result = await authRepo.login(
//       AuthRequestModel(
//         email: emailController.text,
//         password: passwordController.text,
//       ),
//     );
//     result.fold((failure) => emit(LoginErrorState(failure.errorMessage)), (
//       token,
//     ) {
//       _saveToken(token);
//       emit(LoginSuccessState(token));
//     });
//   }
//
//   Future<void> signInWithGoogle() async {
//     emit(LoginLoadingState());
//     if (kIsWeb) {
//       emit(LoginRedirectingState());
//       final res = await authRepo.startWebGoogleSignIn();
//       res.fold((failure) {
//         emit(LoginErrorState(failure.errorMessage));
//       }, (_) {
//         // Keep the redirecting state active
//         // The OAuth callback will be handled by the auth state listener
//       //  emit(LoginRedirectingState());
//       });
//     } else {
//       emit(LoginLoadingState());
//       final res = await authRepo.mobileGoogleSignIn();
//       res.fold((failure) => emit(LoginErrorState(failure.errorMessage)), (session) {
//         _saveToken(session.refreshToken!);
//         emit(LoginSuccessState(session.refreshToken!));
//       });
//     }
//   }
//
//   // Public method to save token directly (for OAuth callback handling)
//   Future<void> saveTokenDirectly(String token) async {
//     await AppSecureStorage().setData(key: AppConstants.tokenKey, value: token);
//     emit(LoginSuccessState(token));
//   }
//
//   void _saveToken(String token) async {
//     print("Saving token: $token");
//     await AppSecureStorage().setData(key: AppConstants.tokenKey, value: token);
//   }
//
//   /// Start listening to auth state changes via the repo
//   void startAuthListener() {
//     if (_authStateSubscription != null) return;
//     _authStateSubscription = authRepo.onAuthStateChange().listen((data) {
//       final event = data.event;
//       final session = data.session;
//       if (_isListeningForCallback && event == AuthChangeEvent.signedIn && session != null) {
//         _handleOAuthSuccess(session);
//       }
//     });
//   }
//   Future<void> _handleOAuthSuccess(Session session) async {
//     await AppSecureStorage().setData(key: AppConstants.tokenKey, value: session.refreshToken ?? '');
//     emit(LoginSuccessState(session.refreshToken ?? ''));
//   }
//   /// Check if the app was opened via OAuth redirect
//   Future<void> checkInitialAuthState() async {
//     // Check redirect fragment / query
//     final uri = Uri.base;
//     if (uri.fragment.contains('access_token') || uri.queryParameters.containsKey('code')) {
//       _isListeningForCallback = true;
//       await Future.delayed(const Duration(milliseconds: 500));
//       final session = authRepo.currentSession();
//       if (session != null) {
//         await _handleOAuthSuccess(session);
//       }
//     }
//   }
//
//   // Method to reset state (useful when navigating back to login)
//   void resetState() {
//     emit(LoginInitialState());
//   }
//
//   // Future<void> handleOAuthCallback() async {
//   //
//   //   emit(LoginLoadingState());
//   //   final result = await authRepo.checkOAuthCallback();
//   //   result.fold(
//   //         (failure) => emit(LoginErrorState(failure.errorMessage)),
//   //         (Session) {
//   //       _saveToken(Session.refreshToken!);
//   //       emit(LoginSuccessState(Session.refreshToken!));
//   //     },
//   //   );
//   // }
//
//
//
//   @override
//   Future<void> close() {
//     emailController.dispose();
//     passwordController.dispose();
//     return super.close();
//   }
// }
// lib/modules/auth/login/presentation/logic/login_cubit.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/resourses/app_secure_storage.dart';
import '../../../../core/resourses/constants_manager.dart';
import '../../data/models/auth_request_model.dart';
import '../../data/repos/auth_repo.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginStates> {
  final AuthRepo authRepo;
  final _storage = AppSecureStorage();
 TextEditingController emailController = TextEditingController();
 TextEditingController passwordController = TextEditingController();
  StreamSubscription<AuthState>? _authStateSubscription;

  LoginCubit(this.authRepo) : super(LoginInitialState());

  // ------------ Email / Password login ------------
  Future<void> login() async {
    emit(LoginLoadingState());
    final result = await authRepo.login(
      AuthRequestModel(email: emailController.text, password: passwordController.text),
    );

    result.fold(
          (failure) => emit(LoginErrorState(failure.errorMessage)),
          (session) async {
        await _saveTokensIfAvailable(accessToken: session.accessToken, refreshToken: session.refreshToken);
        emit(LoginSuccessState(session.refreshToken!));
      },
    );
  }

  // ------------ Google Sign-In ------------
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        emit(LoginRedirectingState());
        final res = await authRepo.startWebGoogleSignIn();
        res.fold(
              (failure) => emit(LoginErrorState(failure.errorMessage)),
              (_) {
          },
        );
      } else {
        emit(LoginLoadingState());
        final res = await authRepo.mobileGoogleSignIn();
        res.fold(
              (failure) => emit(LoginErrorState(failure.errorMessage)),
              (session) async {
            await _saveTokensIfAvailable(
              accessToken: session.accessToken,
              refreshToken: session.refreshToken,
            );
            emit(LoginSuccessState(session.refreshToken ?? ''));
          },
        );
      }
    } catch (e) {
      emit(LoginErrorState(e.toString()));
    }
  }

  // ------------ Auth state listener (Supabase) ------------
  /// Start listening to Supabase auth state changes (idempotent)
  void startAuthListener() {
    if (_authStateSubscription != null) return;
    _authStateSubscription = authRepo.onAuthStateChange().listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _handleOAuthSuccess(session);
      } else if (event == AuthChangeEvent.signedOut) {
        await _clearTokens();
        emit(LoginInitialState());
      }
    });
  }

  Future<void> _handleOAuthSuccess(Session session) async {
    await _saveTokensIfAvailable(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    emit(LoginSuccessState(session.refreshToken ?? ''));
  }

  /// On web, check the URL fragment/query after a redirect callback
  Future<void> checkInitialAuthState() async {
    if (!kIsWeb) return;
    try {
      final uri = Uri.base;
      final hasTokenFragment = uri.fragment.contains('access_token') || uri.fragment.contains('refresh_token');
      final hasCode = uri.queryParameters.containsKey('code');
      if (hasTokenFragment || hasCode) {
        await Future.delayed(const Duration(milliseconds: 400));
        final session = authRepo.currentSession();
        if (session != null) {
          await _handleOAuthSuccess(session);
        } else {
          emit(LoginErrorState('OAuth callback received but no session found'));
        }
      }
    } catch (e) {
      emit(LoginErrorState('Error processing OAuth callback: ${e.toString()}'));
    }
  }

  // ------------ Token storage helpers ------------
  Future<void> _saveTokensIfAvailable({String? accessToken, String? refreshToken}) async {
    if (accessToken != null && accessToken.isNotEmpty) {
      await _storage.setData(key: AppConstants.accessTokenKey, value: accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.setData(key: AppConstants.tokenKey, value: refreshToken);
    }
  }

  Future<void> _clearTokens() async {
    await _storage.removeData(AppConstants.accessTokenKey);
    await _storage.removeData(AppConstants.tokenKey);
  }

  /// Public for manual saving (if needed)
  Future<void> saveTokenDirectly(String token) async {
    await _storage.setData(key: AppConstants.tokenKey, value: token);
    emit(LoginSuccessState(token));
  }

  void resetState() => emit(LoginInitialState());

  @override
  Future<void> close() async {
    await _authStateSubscription?.cancel();
    _authStateSubscription = null;
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
