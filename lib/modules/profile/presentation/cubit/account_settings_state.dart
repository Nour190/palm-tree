import 'package:equatable/equatable.dart';
import '../../data/models/profile_model.dart';

abstract class AccountSettingsState extends Equatable {
  const AccountSettingsState();

  @override
  List<Object?> get props => [];
}

class AccountSettingsInitial extends AccountSettingsState {}

class AccountSettingsLoading extends AccountSettingsState {}

class AccountSettingsLoaded extends AccountSettingsState {
  final ProfileModel profile;

  const AccountSettingsLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class AccountSettingsSaving extends AccountSettingsState {
  final ProfileModel profile;

  const AccountSettingsSaving(this.profile);

  @override
  List<Object?> get props => [profile];
}

class AccountSettingsSuccess extends AccountSettingsState {
  final ProfileModel profile;
  final String message;

  const AccountSettingsSuccess(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

class AccountSettingsError extends AccountSettingsState {
  final String message;
  final ProfileModel? profile;

  const AccountSettingsError(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}

class AccountSettingsAvatarUploading extends AccountSettingsState {
  final ProfileModel profile;

  const AccountSettingsAvatarUploading(this.profile);

  @override
  List<Object?> get props => [profile];
}
