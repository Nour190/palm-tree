
import '../../data/models/user_model.dart';

abstract class RegisterStates {}

class RegisterInitialState extends RegisterStates {}

class RegisterLoadingState extends RegisterStates {}

class RegisterSuccessState extends RegisterStates {
  final UserModel userModel;

  RegisterSuccessState(this.userModel);
}
class RegisterGoogleSuccessState extends RegisterStates {


  RegisterGoogleSuccessState(Session);
}
class RegisterErrorState extends RegisterStates {
  final String errorMessage;

  RegisterErrorState(this.errorMessage);
}
