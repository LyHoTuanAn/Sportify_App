import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// A utility class to manage theme settings
class ThemeManager {
  static const String _themeKey = 'app_theme';
  static final GetStorage _storage = GetStorage();

  /// Theme mode options
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';

  /// Get the current theme mode
  static String getCurrentThemeMode() {
    return _storage.read<String>(_themeKey) ?? system; // Default to system
  }

  /// Save the theme mode
  static Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(_themeKey, themeMode);
    debugPrint('ThemeManager: Saved theme mode $themeMode to storage');
  }

  /// Change the app theme mode
  static Future<void> changeThemeMode(String themeMode) async {
    final currentThemeMode = getCurrentThemeMode();
    debugPrint(
        'ThemeManager: Changing theme mode from $currentThemeMode to $themeMode');

    // Save the new theme mode
    await saveThemeMode(themeMode);

    // Apply the theme mode
    switch (themeMode) {
      case light:
        Get.changeThemeMode(ThemeMode.light);
        break;
      case dark:
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case system:
      default:
        Get.changeThemeMode(ThemeMode.system);
        break;
    }

    // Verify the change
    final savedThemeMode = getCurrentThemeMode();
    debugPrint('ThemeManager: Theme mode saved as $savedThemeMode');
  }

  /// Apply the saved theme mode on app startup
  static void applyThemeModeOnStartup() {
    final savedThemeMode = getCurrentThemeMode();
    debugPrint(
        'ThemeManager: Applying saved theme mode $savedThemeMode on startup');

    // Apply the theme mode
    switch (savedThemeMode) {
      case light:
        Get.changeThemeMode(ThemeMode.light);
        break;
      case dark:
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case system:
      default:
        Get.changeThemeMode(ThemeMode.system);
        break;
    }
  }

  /// Check if the current theme mode is dark
  static bool isDarkMode() {
    final themeMode = getCurrentThemeMode();
    if (themeMode == dark) {
      return true;
    } else if (themeMode == light) {
      return false;
    } else {
      // For system mode, check the system brightness
      // Get.mediaQuery might be null during initialization
      try {
        final brightness = Get.mediaQuery.platformBrightness;
        return brightness == Brightness.dark;
      } catch (e) {
        debugPrint('ThemeManager: Error getting system brightness: $e');
        return false; // Default to light mode if we can't determine
      }
    }
  }
}
