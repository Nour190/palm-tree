import 'package:dartz/dartz.dart';
import 'package:baseqat/core/network/remote/errors/failure.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getProfile(String userId);
  Future<Either<Failure, ProfileModel>> updateProfile(ProfileModel profile);
  Future<Either<Failure, String>> uploadAvatar(String userId, XFile filePath);
}
