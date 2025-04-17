import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// A helper class to assist with translating text in the app
class TranslateHelper {
  /// Translates a string using the easy_localization package
  static String tr(BuildContext context, String key, {Map<String, String>? namedArgs}) {
    return context.tr(key, namedArgs: namedArgs);
  }

  /// Updates a view file to use translations instead of hardcoded text
  static void updateViewFile(String filePath, Map<String, String> translations) {
    // This would be implemented to automatically update view files
    // For now, we'll do this manually
  }
}

/// Extension method to make it easier to translate text
extension TranslateExtension on BuildContext {
  /// Translates a string using the easy_localization package
  String translate(String key, {Map<String, String>? namedArgs}) {
    return tr(key, namedArgs: namedArgs);
  }
}
