import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:baseqat/core/network/remote/errors/failure.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import 'account_settings_state.dart';

class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  final ProfileRepository _profileRepository;

  AccountSettingsCubit(this._profileRepository) : super(AccountSettingsInitial());

  ProfileModel? get currentProfile {
    final currentState = state;
    if (currentState is AccountSettingsLoaded) return currentState.profile;
    if (currentState is AccountSettingsSaving) return currentState.profile;
    if (currentState is AccountSettingsSuccess) return currentState.profile;
    if (currentState is AccountSettingsError) return currentState.profile;
    if (currentState is AccountSettingsAvatarUploading) return currentState.profile;
    return null;
  }

  Future<void> loadProfile(String userId) async {
    emit(AccountSettingsLoading());

    final result = await _profileRepository.getProfile(userId);
    
    result.fold(
      (failure) => emit(AccountSettingsError(_mapFailureToMessage(failure))),
      (profile) => emit(AccountSettingsLoaded(profile)),
    );
  }

  Future<void> updateName(String newName) async {
    final profile = currentProfile;
    if (profile == null) {
      emit(const AccountSettingsError('No profile loaded'));
      return;
    }

    // Validate name
    if (newName.trim().isEmpty) {
      emit(AccountSettingsError('Name cannot be empty', profile: profile));
      return;
    }

    if (newName.trim().length > 50) {
      emit(AccountSettingsError('Name cannot exceed 50 characters', profile: profile));
      return;
    }

    // Show optimistic UI
    final updatedProfile = profile.copyWith(name: newName.trim());
    emit(AccountSettingsSaving(updatedProfile));

    final result = await _profileRepository.updateProfile(updatedProfile);
    
    result.fold(
      (failure) {
        // Revert to original profile on failure
        emit(AccountSettingsError(_mapFailureToMessage(failure), profile: profile));
      },
      (savedProfile) {
        emit(AccountSettingsSuccess(savedProfile, 'Name updated successfully'));
        // Return to loaded state after showing success
        Future.delayed(const Duration(seconds: 2), () {
          if (state is AccountSettingsSuccess) {
            emit(AccountSettingsLoaded(savedProfile));
          }
        });
      },
    );
  }

  Future<void> updateAvatar(XFile file) async {
    print("upload **************3");
    final profile = currentProfile;
    if (profile == null) {

      emit(const AccountSettingsError('No profile loaded'));
      return;
    }

    emit(AccountSettingsAvatarUploading(profile));

    // Upload avatar first
    final uploadResult = await _profileRepository.uploadAvatar(profile.id, file);
    print("upload ************** ${uploadResult} ");

    await uploadResult.fold(
      (failure) async {
        emit(AccountSettingsError(_mapFailureToMessage(failure), profile: profile));
      },
      (avatarUrl) async {
        // Update profile with new avatar URL
        final updatedProfile = profile.copyWith(avatarUrl: avatarUrl);
        final updateResult = await _profileRepository.updateProfile(updatedProfile);
        
        updateResult.fold(
          (failure) {
            emit(AccountSettingsError(_mapFailureToMessage(failure), profile: profile));
          },
          (savedProfile) {
            emit(AccountSettingsSuccess(savedProfile, 'Avatar updated successfully'));
            // Return to loaded state after showing success
            Future.delayed(const Duration(seconds: 2), () {
              if (state is AccountSettingsSuccess) {
                emit(AccountSettingsLoaded(savedProfile));
              }
            });
          },
        );
      },
    );
  }

  void clearError() {
    final profile = currentProfile;
    if (profile != null) {
      emit(AccountSettingsLoaded(profile));
    } else {
      emit(AccountSettingsInitial());
    }
  }

  void clearSuccess() {
    final currentState = state;
    if (currentState is AccountSettingsSuccess) {
      emit(AccountSettingsLoaded(currentState.profile));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    // Map different failure types to user-friendly messages
    return failure.errorMessage ?? 'An unexpected error occurred';
  }
}
