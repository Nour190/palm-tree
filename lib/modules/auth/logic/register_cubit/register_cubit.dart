import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/resourses/app_secure_storage.dart';
import '../../../../core/resourses/constants_manager.dart';
import '../../data/models/auth_request_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repos/auth_repo.dart';
import 'register_states.dart';

class RegisterCubit extends Cubit<RegisterStates> {
  final AuthRepo authRepo;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _storage = AppSecureStorage();
  StreamSubscription<AuthState>? _authStateSubscription;
  RegisterCubit(this.authRepo) : super(RegisterInitialState());

  Future register() async {
    emit(RegisterLoadingState());
    final result = await authRepo.register(
      AuthRequestModel(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
      ),
    );
    result.fold(
          (failure) => emit(RegisterErrorState(failure.errorMessage)),
          (userModel) async {
            print("************* Start create account model ${userModel.name} ");
        final createUserResult = await authRepo.createUser(userModel);
        createUserResult.fold(
              (failure) => emit(RegisterErrorState('Account created but profile setup failed: ${failure.errorMessage}')),
              (_) {
                emit(RegisterSuccessState(
                //    userModel
                ));
              }
        );
      },
    );
  }
  Future<void> _saveTokensIfAvailable({String? accessToken, String? refreshToken,  String? userId}) async {
    if (accessToken != null && accessToken.isNotEmpty) {
      await _storage.setData(key: AppConstants.accessTokenKey, value: accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.setData(key: AppConstants.tokenKey, value: refreshToken);
    }

    if (userId != null && userId.isNotEmpty) {
      await _storage.setData(key: AppConstants.userId, value: userId);
    }
  }
  // Future<void> signUpWithGoogle() async {
  //  // emit(RegisterWithGoogleLoadingState());
  //
  //   if (kIsWeb) {
  //     // For web, initiate OAuth flow
  //     emit(RegisterRedirectingState());
  //     final res = await authRepo.startWebGoogleSignIn();
  //     res.fold((failure) {
  //       emit(RegisterErrorState(failure.errorMessage));
  //     }, (_) {
  //       // Keep the redirecting state active
  //       // The OAuth callback will be handled by the auth state listener in the view
  //    //   emit(RegisterRedirectingState());
  //     });
  //   } else {
  //     // For mobile, use Google Sign-In package
  //     final res = await authRepo.mobileGoogleSignIn();
  //     res.fold(
  //           (failure) => emit(RegisterErrorState(failure.errorMessage)),
  //           (session) => emit(RegisterGoogleSuccessState(session)),
  //     );
  //   }
  // }
  // start listening to auth changes via repo
  Future<void> signUpWithGoogle() async {
    try {
      if (kIsWeb) {
        emit(RegisterRedirectingState());
        final res = await authRepo.startWebGoogleSignIn();
        res.fold(
              (failure) => emit(RegisterErrorState(failure.errorMessage)),
              (_) {
          },
        );
      } else {
        emit(RegisterWithGoogleLoadingState());
        final res = await authRepo.mobileGoogleSignIn();
        res.fold(
              (failure) => emit(RegisterErrorState(failure.errorMessage)),
              (session) async {
            await _saveTokensIfAvailable(
              accessToken: session.accessToken,
              refreshToken: session.refreshToken,
              userId: session.user.id,
            );
            emit(RegisterSuccessState(
            //    session.refreshToken ?? ''
            ));
          },
        );
      }
    } catch (e) {
      emit(RegisterErrorState(e.toString()));
    }
  }
  void startAuthListener() {
    // print("************* Start startAuthListener ");
    if (_authStateSubscription != null) return;
    _authStateSubscription = authRepo.onAuthStateChange().listen((data) async {
      final event = data.event;
      final session = data.session;
      // print("************* session model ${session??"null"} ");
      if (session != null) {
        // debugPrint("handleOAuthSuccess");
        await _handleOAuthSuccess(session);
      } else if (event == AuthChangeEvent.signedOut) {
        await _clearTokens();
        emit(RegisterInitialState());
      }
    });
  }
  Future<void> _clearTokens() async {
    await _storage.removeData(AppConstants.accessTokenKey);
    await _storage.removeData(AppConstants.tokenKey);
    await _storage.removeData(AppConstants.userId);
    await _storage.removeData(AppConstants.userName);

  }
  // Future<void> checkInitialAuthState() async {
  //   if (!kIsWeb) return;
  //   try {
  //     final uri = Uri.base;
  //     final hasTokenFragment = uri.fragment.contains('access_token') || uri.fragment.contains('refresh_token');
  //     final hasCode = uri.queryParameters.containsKey('code');
  //     if (hasTokenFragment || hasCode) {
  //       await Future.delayed(const Duration(milliseconds: 400));
  //       final session = authRepo.currentSession();
  //       if (session != null) {
  //         await _handleOAuthSuccess(session);
  //       } else {
  //         emit(RegisterErrorState('OAuth callback received but no session found'));
  //       }
  //     }
  //   } catch (e) {
  //     emit(RegisterErrorState('Error processing OAuth callback: ${e.toString()}'));
  //   }
  // }

  Future<void> _handleOAuthSuccess(Session session) async {
    emit(RegisterWithGoogleLoadingState());
    final user = session.user;
    final userModel = UserModel(
      id: user.id,
      name: user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
      email: user.email ?? '',
      avatarUrl: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? '',
    );
// print("save data in profiles");
    final res = await authRepo.createUser(userModel);
    res.fold(
          (failure) => emit(RegisterErrorState('Profile setup failed: ${failure.errorMessage}')),
          (_) async {
            // print("save data in profiles true");
            final refresh = session.refreshToken ?? '';
        if (refresh.isNotEmpty) {
          _saveTokensIfAvailable(accessToken:session.accessToken,
              refreshToken: session.refreshToken,
            userId: session.user.id,
          );
        }
        emit(RegisterSuccessState(
        //    userModel
        ));
      },
    );
  }


  // Method to reset state (useful when navigating back to register)
  void resetState() {
    emit(RegisterInitialState());
  }
  // Future<void> signUpWithGoogle() async {
  //   emit(RegisterLoadingState());
  //   final result = await authRepo.signInWithGoogle();
  //   result.fold(
  //         (failure) => emit(RegisterErrorState(failure.errorMessage)),
  //         (Session) => emit(RegisterGoogleSuccessState(Session)),
  //   );
  // }
  @override
  Future<void> close() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
