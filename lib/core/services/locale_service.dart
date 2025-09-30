import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'selected_locale';
  
  /// Save selected locale to persistent storage
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
  }
  
  /// Load saved locale from persistent storage
  static Future<Locale?> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString(_localeKey);
    
    if (localeString != null) {
      final parts = localeString.split('_');
      if (parts.length == 2) {
        return Locale(parts[0], parts[1]);
      }
    }
    return null;
  }
  
  /// Change locale and save to storage
  static Future<void> changeLocale(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
    await saveLocale(locale);
  }
  
  /// Get supported locales
  static List<Locale> getSupportedLocales() {
    return const [
      Locale('en', 'US'),
      Locale('ar', 'SA'),
      Locale('de', 'DE'),
    ];
  }
  
  /// Get locale display name
  static String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'de':
        return 'Deutsch';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
  
  /// Check if locale is RTL
  static bool isRTL(Locale locale) {
    return locale.languageCode == 'ar';
  }
}
