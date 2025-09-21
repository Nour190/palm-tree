import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService {
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _smsNotificationsKey = 'sms_notifications';

  static NotificationSettingsService? _instance;
  static NotificationSettingsService get instance {
    _instance ??= NotificationSettingsService._internal();
    return _instance!;
  }

  NotificationSettingsService._internal();

  // Get notification settings
  Future<bool> getPushNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushNotificationsKey) ?? true;
  }

  Future<bool> getEmailNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_emailNotificationsKey) ?? false;
  }

  Future<bool> getSmsNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_smsNotificationsKey) ?? true;
  }

  // Set notification settings
  Future<void> setPushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsKey, value);
  }

  Future<void> setEmailNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emailNotificationsKey, value);
  }

  Future<void> setSmsNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_smsNotificationsKey, value);
  }

  // Check if any notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final push = await getPushNotifications();
    final email = await getEmailNotifications();
    final sms = await getSmsNotifications();
    return push || email || sms;
  }
}
