import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/resourses/app_secure_storage.dart';
import '../../../../core/resourses/constants_manager.dart';
import '../../data/models/auth_request_model.dart';
import '../../data/repos/auth_repo.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginStates> {
  final AuthRepo authRepo;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginCubit(this.authRepo) : super(LoginInitialState());

  Future<void> login() async {
    emit(LoginLoadingState());
    final result = await authRepo.login(
      AuthRequestModel(
        email: emailController.text,
        password: passwordController.text,
      ),
    );
    result.fold((failure) => emit(LoginErrorState(failure.errorMessage)), (
      token,
    ) {
      _saveToken(token);
      emit(LoginSuccessState(token));
    });
  }

  Future<void> signInWithGoogle() async {
    emit(LoginLoadingState());
    final result = await authRepo.signInWithGoogle();
    result.fold((failure) => emit(LoginErrorState(failure.errorMessage)), (
        Session,
        ) {
      _saveToken(Session.refreshToken!);
      emit(LoginSuccessState(Session.refreshToken!));
    });
  }

  Future<void> handleOAuthCallback() async {

    emit(LoginLoadingState());
    final result = await authRepo.checkOAuthCallback();
    result.fold(
          (failure) => emit(LoginErrorState(failure.errorMessage)),
          (Session) {
        _saveToken(Session.refreshToken!);
        emit(LoginSuccessState(Session.refreshToken!));
      },
    );
  }

  void _saveToken(String token) async {
    print("${token}");
    await AppSecureStorage().setData(key: AppConstants.tokenKey, value: token);
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
