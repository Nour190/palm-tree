import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsService {
  static const String _profileVisibilityKey = 'profile_visibility';
  static const String _showLikedArtworksKey = 'show_liked_artworks';
  static const String _activityTrackingKey = 'activity_tracking';
  static const String _locationSharingKey = 'location_sharing';
  static const String _showOnlineStatusKey = 'show_online_status';
  static const String _allowMessagesFromStrangersKey = 'allow_messages_from_strangers';
  static const String _allowTaggingKey = 'allow_tagging';
  static const String _shareActivityStatusKey = 'share_activity_status';

  static PrivacySettingsService? _instance;
  static PrivacySettingsService get instance => _instance ??= PrivacySettingsService._();
  
  PrivacySettingsService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Profile Visibility
  Future<void> setProfileVisibility(bool value) async {
    await init();
    await _prefs!.setBool(_profileVisibilityKey, value);
  }

  bool getProfileVisibility() {
    return _prefs?.getBool(_profileVisibilityKey) ?? true;
  }

  // Show Liked Artworks
  Future<void> setShowLikedArtworks(bool value) async {
    await init();
    await _prefs!.setBool(_showLikedArtworksKey, value);
  }

  bool getShowLikedArtworks() {
    return _prefs?.getBool(_showLikedArtworksKey) ?? true;
  }

  // Activity Tracking
  Future<void> setActivityTracking(bool value) async {
    await init();
    await _prefs!.setBool(_activityTrackingKey, value);
  }

  bool getActivityTracking() {
    return _prefs?.getBool(_activityTrackingKey) ?? true;
  }

  // Location Sharing
  Future<void> setLocationSharing(bool value) async {
    await init();
    await _prefs!.setBool(_locationSharingKey, value);
  }

  bool getLocationSharing() {
    return _prefs?.getBool(_locationSharingKey) ?? false;
  }

  // Show Online Status
  Future<void> setShowOnlineStatus(bool value) async {
    await init();
    await _prefs!.setBool(_showOnlineStatusKey, value);
  }

  bool getShowOnlineStatus() {
    return _prefs?.getBool(_showOnlineStatusKey) ?? true;
  }

  // Allow Messages From Strangers
  Future<void> setAllowMessagesFromStrangers(bool value) async {
    await init();
    await _prefs!.setBool(_allowMessagesFromStrangersKey, value);
  }

  bool getAllowMessagesFromStrangers() {
    return _prefs?.getBool(_allowMessagesFromStrangersKey) ?? false;
  }

  // Allow Tagging
  Future<void> setAllowTagging(bool value) async {
    await init();
    await _prefs!.setBool(_allowTaggingKey, value);
  }

  bool getAllowTagging() {
    return _prefs?.getBool(_allowTaggingKey) ?? true;
  }

  // Share Activity Status
  Future<void> setShareActivityStatus(bool value) async {
    await init();
    await _prefs!.setBool(_shareActivityStatusKey, value);
  }

  bool getShareActivityStatus() {
    return _prefs?.getBool(_shareActivityStatusKey) ?? false;
  }

  // Get all settings as a map
  Map<String, bool> getAllSettings() {
    return {
      'profileVisibility': getProfileVisibility(),
      'showLikedArtworks': getShowLikedArtworks(),
      'activityTracking': getActivityTracking(),
      'locationSharing': getLocationSharing(),
      'showOnlineStatus': getShowOnlineStatus(),
      'allowMessagesFromStrangers': getAllowMessagesFromStrangers(),
      'allowTagging': getAllowTagging(),
      'shareActivityStatus': getShareActivityStatus(),
    };
  }
}
