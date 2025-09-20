import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/modules/profile/data/services/privacy_settings_service.dart';

class PrivacySettingsState {
  final bool profileVisibility;
  final bool showLikedArtworks;
  final bool activityTracking;
  final bool locationSharing;
  final bool showOnlineStatus;
  final bool allowMessagesFromStrangers;
  final bool allowTagging;
  final bool shareActivityStatus;
  final bool isLoading;

  const PrivacySettingsState({
    this.profileVisibility = true,
    this.showLikedArtworks = true,
    this.activityTracking = true,
    this.locationSharing = false,
    this.showOnlineStatus = true,
    this.allowMessagesFromStrangers = false,
    this.allowTagging = true,
    this.shareActivityStatus = false,
    this.isLoading = false,
  });

  PrivacySettingsState copyWith({
    bool? profileVisibility,
    bool? showLikedArtworks,
    bool? activityTracking,
    bool? locationSharing,
    bool? showOnlineStatus,
    bool? allowMessagesFromStrangers,
    bool? allowTagging,
    bool? shareActivityStatus,
    bool? isLoading,
  }) {
    return PrivacySettingsState(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      showLikedArtworks: showLikedArtworks ?? this.showLikedArtworks,
      activityTracking: activityTracking ?? this.activityTracking,
      locationSharing: locationSharing ?? this.locationSharing,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowMessagesFromStrangers: allowMessagesFromStrangers ?? this.allowMessagesFromStrangers,
      allowTagging: allowTagging ?? this.allowTagging,
      shareActivityStatus: shareActivityStatus ?? this.shareActivityStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PrivacySettingsCubit extends Cubit<PrivacySettingsState> {
  final PrivacySettingsService _privacyService;

  PrivacySettingsCubit(this._privacyService) : super(const PrivacySettingsState());

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));
    await _privacyService.init();
    
    emit(PrivacySettingsState(
      profileVisibility: _privacyService.getProfileVisibility(),
      showLikedArtworks: _privacyService.getShowLikedArtworks(),
      activityTracking: _privacyService.getActivityTracking(),
      locationSharing: _privacyService.getLocationSharing(),
      showOnlineStatus: _privacyService.getShowOnlineStatus(),
      allowMessagesFromStrangers: _privacyService.getAllowMessagesFromStrangers(),
      allowTagging: _privacyService.getAllowTagging(),
      shareActivityStatus: _privacyService.getShareActivityStatus(),
      isLoading: false,
    ));
  }

  Future<void> updateProfileVisibility(bool value) async {
    await _privacyService.setProfileVisibility(value);
    emit(state.copyWith(profileVisibility: value));
  }

  Future<void> updateShowLikedArtworks(bool value) async {
    await _privacyService.setShowLikedArtworks(value);
    emit(state.copyWith(showLikedArtworks: value));
  }

  Future<void> updateActivityTracking(bool value) async {
    await _privacyService.setActivityTracking(value);
    emit(state.copyWith(activityTracking: value));
  }

  Future<void> updateLocationSharing(bool value) async {
    await _privacyService.setLocationSharing(value);
    emit(state.copyWith(locationSharing: value));
  }

  Future<void> updateShowOnlineStatus(bool value) async {
    await _privacyService.setShowOnlineStatus(value);
    emit(state.copyWith(showOnlineStatus: value));
  }

  Future<void> updateAllowMessagesFromStrangers(bool value) async {
    await _privacyService.setAllowMessagesFromStrangers(value);
    emit(state.copyWith(allowMessagesFromStrangers: value));
  }

  Future<void> updateAllowTagging(bool value) async {
    await _privacyService.setAllowTagging(value);
    emit(state.copyWith(allowTagging: value));
  }

  Future<void> updateShareActivityStatus(bool value) async {
    await _privacyService.setShareActivityStatus(value);
    emit(state.copyWith(shareActivityStatus: value));
  }
}
