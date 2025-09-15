abstract class CreateUserStates {}

class CreateUserInitialState extends CreateUserStates {}

class CreateUserSuccessState extends CreateUserStates {}

class CreateUserErrorState extends CreateUserStates {
  final String errorMessage;

  CreateUserErrorState(this.errorMessage);
}
