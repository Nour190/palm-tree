import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AccountSettingsService {
  static AccountSettingsService? _instance;
  static AccountSettingsService get instance => _instance ??= AccountSettingsService._();

  AccountSettingsService._();

  SharedPreferences? _prefs;
  final StreamController<AccountSettings> _settingsController = StreamController<AccountSettings>.broadcast();

  Stream<AccountSettings> get settingsStream => _settingsController.stream;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<AccountSettings> getSettings() async {
    await init();

    return AccountSettings(
      id: _prefs?.getString('profile_id') ?? '',
      name: _prefs?.getString('profile_name') ?? 'John Doe',
      email: _prefs?.getString('profile_email') ?? 'john.doe@example.com',
      avatarUrl: _prefs?.getString('profile_avatar_url') ?? '',
      emailNotifications: _prefs?.getBool('account_email_notifications') ?? true,
      twoFactorEnabled: _prefs?.getBool('account_two_factor') ?? false,
    );
  }

  Future<void> updateProfileFromSupabase(String id, String name, String email, String avatarUrl) async {
    await init();
    await _prefs?.setString('profile_id', id);
    await _prefs?.setString('profile_name', name);
    await _prefs?.setString('profile_email', email);
    await _prefs?.setString('profile_avatar_url', avatarUrl);
    _notifySettingsChanged();
  }

  Future<void> updateName(String name) async {
    await init();
    await _prefs?.setString('profile_name', name);
    _notifySettingsChanged();
    // TODO: Update Supabase profile table
  }

  Future<void> updateAvatarUrl(String avatarUrl) async {
    await init();
    await _prefs?.setString('profile_avatar_url', avatarUrl);
    _notifySettingsChanged();
    // TODO: Update Supabase profile table
  }

  // Email cannot be updated directly - must be done through Supabase auth

  Future<void> updateEmailNotifications(bool enabled) async {
    await init();
    await _prefs?.setBool('account_email_notifications', enabled);
    _notifySettingsChanged();
  }

  Future<void> updateTwoFactor(bool enabled) async {
    await init();
    await _prefs?.setBool('account_two_factor', enabled);
    _notifySettingsChanged();
  }

  void _notifySettingsChanged() async {
    final settings = await getSettings();
    _settingsController.add(settings);
  }

  void dispose() {
    _settingsController.close();
  }
}

class AccountSettings {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final bool emailNotifications;
  final bool twoFactorEnabled;

  AccountSettings({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.emailNotifications,
    required this.twoFactorEnabled,
  });

  AccountSettings copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? emailNotifications,
    bool? twoFactorEnabled,
  }) {
    return AccountSettings(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}
