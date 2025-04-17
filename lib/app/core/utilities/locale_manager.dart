import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

/// A utility class to manage locale settings
class LocaleManager {
  static const String _localeKey = 'app_locale';
  static final GetStorage _storage = GetStorage();

  /// Get the current locale code (e.g., 'en', 'vi')
  static String getCurrentLocale() {
    return _storage.read<String>(_localeKey) ?? 'vi'; // Default to Vietnamese
  }

  /// Save the locale code
  static Future<void> saveLocale(String localeCode) async {
    await _storage.write(_localeKey, localeCode);
    debugPrint('LocaleManager: Saved locale $localeCode to storage');
  }

  /// Change the app locale and ensure it's properly saved
  static Future<void> changeLocale(BuildContext context, String localeCode) async {
    final currentLocale = context.locale.languageCode;
    debugPrint('LocaleManager: Changing locale from $currentLocale to $localeCode');
    
    // Change the locale in EasyLocalization
    await context.setLocale(Locale(localeCode));
    
    // Also save it in our own storage
    await saveLocale(localeCode);
    
    // Verify the change
    final savedLocale = getCurrentLocale();
    debugPrint('LocaleManager: Locale saved as $savedLocale');
    
    // Force the app to rebuild with the new locale
    Future.delayed(const Duration(milliseconds: 100), () {
      debugPrint('LocaleManager: Forcing app rebuild with locale $localeCode');
      Get.forceAppUpdate();
    });
  }
  
  /// Apply the saved locale on app startup
  static Future<void> applyLocaleOnStartup(BuildContext context) async {
    final savedLocale = getCurrentLocale();
    debugPrint('LocaleManager: Applying saved locale $savedLocale on startup');
    
    // Set the locale in EasyLocalization
    await context.setLocale(Locale(savedLocale));
    
    // Force the app to rebuild with the saved locale
    Future.delayed(const Duration(milliseconds: 100), () {
      debugPrint('LocaleManager: Forcing app rebuild with locale $savedLocale');
      Get.forceAppUpdate();
    });
  }
}
