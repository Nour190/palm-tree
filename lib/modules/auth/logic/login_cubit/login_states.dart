abstract class LoginStates {}

class LoginInitialState extends LoginStates {}

class LoginLoadingState extends LoginStates {}
class LoginRedirectingState extends LoginStates {}
class LoginSuccessState extends LoginStates {
  final String token;
  LoginSuccessState(this.token);
}

class LoginErrorState extends LoginStates {
  final String errorMessage;

  LoginErrorState(this.errorMessage);
}