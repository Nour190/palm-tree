import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<ProfileModel> updateProfile(ProfileModel profile);
  Future<String> uploadAvatar(String userId, String filePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient client;

  ProfileRemoteDataSourceImpl(this.client);

  @override
  Future<ProfileModel> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return ProfileModel.fromJson(response);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
    
    final response = await client
        .from('profiles')
        .update(updatedProfile.toJson())
        .eq('id', profile.id)
        .select()
        .single();

    return ProfileModel.fromJson(response);
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    // Implementation depends on platform (mobile vs web)
    // This is a simplified version
    throw UnimplementedError('Platform-specific implementation required');
  }
}
