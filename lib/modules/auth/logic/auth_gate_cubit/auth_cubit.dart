// lib/core/auth/auth_cubit.dart
// lib/core/auth/auth_cubit.dart
import 'package:bloc/bloc.dart';
import '../../../../core/resourses/app_secure_storage.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthLoading()) {
    checkAuth();
  }
  Future<void> notifyLoggedIn() async {
    await checkAuth(); // ببساطة نعيد الفحص (أو يمكن قراءة التوكن مباشرة)
  }
  Future<void> checkAuth() async {
    try {
      emit(const AuthLoading());
      final token = await AppSecureStorage().getData('token');
      if (token != null && token.isNotEmpty) {
        emit(AuthAuthenticated(token));
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
      await AppSecureStorage().removeData('token');
      await AppSecureStorage().removeData('access_token');
      // Clear all secure storage data
      await AppSecureStorage().clear();
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

