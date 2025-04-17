import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app/core/styles/style.dart';
import 'app/core/utilities/preferences.dart';
import 'app/core/utilities/locale_manager.dart';
import 'app/core/utilities/theme_manager.dart';
import 'app/data/services/firebase_analytics_service.dart';
import 'app/routes/app_pages.dart';
import 'app/widgets/zoom_transition.dart';

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    // Get the current locale from LocaleManager
    final savedLocale = LocaleManager.getCurrentLocale();
    final currentLocale = context.locale;

    debugPrint('Current locale in RootApp: ${currentLocale.languageCode}');
    debugPrint('Saved locale in LocaleManager: $savedLocale');

    // If the current locale doesn't match the saved locale, apply the saved locale
    if (currentLocale.languageCode != savedLocale) {
      debugPrint(
          'Locale mismatch detected, applying saved locale: $savedLocale');
      // Use a post-frame callback to ensure the context is still valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.setLocale(Locale(savedLocale));
        }
      });
    }

    // Get the current theme mode
    String themeMode;
    bool isDarkMode;

    try {
      themeMode = ThemeManager.getCurrentThemeMode();
      isDarkMode = ThemeManager.isDarkMode();
      debugPrint('Current theme mode: $themeMode, isDarkMode: $isDarkMode');

      // Apply the theme mode
      ThemeManager.applyThemeModeOnStartup();
    } catch (e) {
      // Handle any errors during theme initialization
      debugPrint('Error initializing theme: $e');
      themeMode = ThemeManager.system; // Default to system
      isDarkMode = false; // Default to light mode
    }

    return GestureDetector(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getCollectionTheme(isDark: false),
        darkTheme: AppTheme.getCollectionTheme(isDark: true),
        themeMode: themeMode == ThemeManager.light
            ? ThemeMode.light
            : themeMode == ThemeManager.dark
                ? ThemeMode.dark
                : ThemeMode.system,
        title: 'Sportify',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: currentLocale, // Use the explicitly retrieved locale
        initialRoute: Preferences.isAuth() ? Routes.dashboard : Routes.login,
        getPages: AppPages.routes,
        customTransition: ZoomTransitions(),
        navigatorObservers: [FirebaseAnalyticService.observer],
        routingCallback: (_) {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
      ),
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
    );
  }
}
