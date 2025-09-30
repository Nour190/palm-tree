// lib/core/auth/auth_cubit.dart
// lib/core/auth/auth_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/resourses/app_secure_storage.dart';
import '../../../../core/resourses/constants_manager.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/repos/auth_repo_impl.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {

  AuthCubit(this.authRepo) : super(const AuthLoading()) {
    checkAuth();
  }
  final AuthRepo authRepo;
  Future<void> notifyLoggedIn() async {
    await checkAuth();
  }
  Future<void> checkAuth() async {
    try {
      emit(const AuthLoading());
      //final token = await AppSecureStorage().getData('token');
      final userData=await AppSecureStorage().getAllData();
      if (userData[AppConstants.tokenKey] != null && userData[AppConstants.tokenKey]!.isNotEmpty) {
        emit(AuthAuthenticated(userData));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    try {
      emit(const AuthLoading());
      // Clear all tokens from secure storage
      await AppSecureStorage().removeData(AppConstants.tokenKey);
      await AppSecureStorage().removeData(AppConstants.accessTokenKey);
      // Clear all secure storage data
      await AppSecureStorage().clear();
      print(await AppSecureStorage().getAllData());
      //debugPrint(await AppSecureStorage().getAllData());
     await authRepo.signOut();
      debugPrint("✅ Log Out");
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}


  // Future<void> login(String token) async {
  //   try {
  //     emit(const AuthLoading());
  //     await AppSecureStorage().setData(key: 'token', value: token);
  //     emit(AuthAuthenticated(token));
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }

  // Future<void> logout() async {
  //   try {
  //     emit(const AuthLoading());
  //     await AppSecureStorage().removeData('token');
  //     emit(const AuthUnauthenticated());
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }

