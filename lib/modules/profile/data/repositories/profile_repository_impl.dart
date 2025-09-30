import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baseqat/core/network/remote/errors/failure.dart';
import 'package:baseqat/core/network/remote/errors/supabase_database_failure.dart';
import '../models/profile_model.dart';
import 'profile_repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient client;

  ProfileRepositoryImpl(this.client);

  @override
  Future<Either<Failure, ProfileModel>> getProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = ProfileModel.fromJson(response);
      return Right(profile);
    } catch (error) {
      return Left(SupabaseDatabaseFailure('Failed to fetch profile: ${error.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> updateProfile(ProfileModel profile) async {
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      
      final response = await client
          .from('profiles')
          .update(updatedProfile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      final result = ProfileModel.fromJson(response);
      return Right(result);
    } catch (error) {
      return Left(SupabaseDatabaseFailure('Failed to update profile: ${error.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String userId, XFile file) async {
    try {
       //final Uint8List  file=;
      //late final File  test;
    //   if(kIsWeb){
    //     test= File(filePath);
    //     file=test.readAsBytes()
    //   }else{
    // file=Image.file(File(filePath));
    //   }
     // final file = File(filePath);

      final fileExt = file.path.split('.').last.toLowerCase();
      final fileName = '/$userId/avatar';

      print("upload **************");
      // Upload file to Supabase Storage
      final imageBytes=await file.readAsBytes();
      await client.storage
          .from('avatars')
          .updateBinary(fileName, imageBytes,
        fileOptions: FileOptions(contentType: file.mimeType),
      );
      // Get public URL
      String publicUrl = client.storage
          .from('avatars')
          .getPublicUrl(fileName);
      publicUrl=Uri.parse(publicUrl).replace(queryParameters: {'t':DateTime.now().millisecondsSinceEpoch.toString()}).toString();
      return Right(publicUrl);
    } catch (error) {
      return Left(SupabaseDatabaseFailure('Failed to upload avatar: ${error.toString()}'));
    }
  }
}
