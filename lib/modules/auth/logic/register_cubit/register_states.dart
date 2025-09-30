import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_model.dart';

abstract class RegisterStates {}

class RegisterInitialState extends RegisterStates {}

class RegisterLoadingState extends RegisterStates {}
class RegisterWithGoogleLoadingState extends RegisterStates {}

class RegisterRedirectingState extends RegisterStates {}

class RegisterSuccessState extends RegisterStates {
  // final String token;

  RegisterSuccessState(
      //this.token
      );
}

class RegisterGoogleSuccessState extends RegisterStates {
  final Session session;

  RegisterGoogleSuccessState(this.session);
}

class RegisterErrorState extends RegisterStates {
  final String errorMessage;

  RegisterErrorState(this.errorMessage);
}