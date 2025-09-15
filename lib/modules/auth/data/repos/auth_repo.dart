import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/remote/errors/failure.dart';
import '../models/auth_request_model.dart';
import '../models/user_model.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserModel>> register(
    AuthRequestModel authRequestModel,
  );
  Future<Either<Failure, String>> login(AuthRequestModel authRequestModel);
  Future<Either<Failure, Unit>> createUser(UserModel userModel);
  Future<Either<Failure, Session>> signInWithGoogle();
  Future<Either<Failure, Session>> checkOAuthCallback();
  Future<Either<Failure, Unit>> signOut();
  // logout();
}
