import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import '../../root.dart';
import 'restart_widget.dart';
import '../core/utilities/locale_manager.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showTitle;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool usePopupMenu;

  const LanguageSwitcher({
    super.key,
    this.showTitle = true,
    this.iconSize = 24.0,
    this.iconColor,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.usePopupMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale.languageCode;

    // Flag widget that shows the current language
    Widget flagWidget = Image.asset(
      'assets/flags/${currentLocale == 'en' ? 'us' : 'vn'}.png',
      width: iconSize,
      height: iconSize,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading flag image: $error');
        return Icon(
          Icons.language,
          size: iconSize,
          color: iconColor ?? Theme.of(context).primaryColor,
        );
      },
    );

    // If using popup menu, return a PopupMenuButton
    if (usePopupMenu) {
      return PopupMenuButton<String>(
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.grey[200],
        icon: flagWidget,
        tooltip: context.tr('settings.language'),
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'en',
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildLanguageMenuItem(
                context, 'English', 'en', 'assets/flags/us.png'),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: 'vi',
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildLanguageMenuItem(
                context, 'Tiếng Việt', 'vi', 'assets/flags/vn.png'),
          ),
        ],
        onSelected: (value) async {
          // Log the current locale before changing
          final oldLocale = context.locale.languageCode;
          debugPrint('Current locale before change: $oldLocale');

          // Use LocaleManager to change and save the locale
          await LocaleManager.changeLocale(context, value);

          // Wait a bit to ensure the locale change is processed
          await Future.delayed(const Duration(milliseconds: 300));

          // Restart the app to ensure the locale change is applied
          _restartApp();
        },
      );
    }

    // Otherwise, return the original InkWell implementation
    return InkWell(
      onTap: () => _showLanguageDialog(context),
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            flagWidget,
            if (showTitle) ...[
              const SizedBox(width: 8),
              Text(
                currentLocale == 'en' ? 'English' : 'Tiếng Việt',
                style: TextStyle(
                  color: iconColor ?? Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              'English',
              'en',
              'assets/flags/us.png',
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              context,
              'Tiếng Việt',
              'vi',
              'assets/flags/vn.png',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
          ),
        ],
      ),
    );
  }

  // Static method to show language dialog from anywhere
  static void showLanguageDialogStatic(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.language')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOptionStatic(
              context,
              'English',
              'en',
              'assets/flags/us.png',
            ),
            const SizedBox(height: 16),
            _buildLanguageOptionStatic(
              context,
              'Tiếng Việt',
              'vi',
              'assets/flags/vn.png',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
          ),
        ],
      ),
    );
  }

  // Helper method to restart the app
  static void _restartApp() {
    // Get the saved locale from our LocaleManager
    final savedLocale = LocaleManager.getCurrentLocale();
    final currentLocale = Get.context?.locale.languageCode;

    debugPrint('Restarting app with locale: $currentLocale');
    debugPrint('Saved locale in LocaleManager: $savedLocale');

    // Ensure the locale is properly saved before restarting
    if (savedLocale != currentLocale) {
      debugPrint('Warning: Saved locale does not match current locale!');
      // Force update the saved locale to match current locale
      if (currentLocale != null) {
        LocaleManager.saveLocale(currentLocale);
        debugPrint('Fixed: Saved locale updated to $currentLocale');
      }
    }

    // Approach 1: Use RestartWidget to restart the app
    if (Get.context != null) {
      try {
        RestartWidget.restartApp(Get.context!);
        debugPrint('App restarted using RestartWidget');
        return;
      } catch (e) {
        debugPrint('Failed to restart using RestartWidget: $e');
      }
    }

    // Approach 2: Use Get navigation system to restart
    try {
      // Use Get.reset() to clear all controllers and routes
      Get.reset();

      // Restart the app by recreating the main app widget
      Get.offAll(() => const RootApp(), transition: Transition.fade);
      debugPrint('App restarted using Get.offAll');
    } catch (e) {
      debugPrint('Failed to restart using Get.offAll: $e');

      // Approach 3: Force rebuild all widgets that use the locale
      Get.forceAppUpdate();
      debugPrint('App updated using Get.forceAppUpdate');
    }

    // Log after restart
    Future.delayed(const Duration(milliseconds: 500), () {
      final newLocale = Get.context?.locale.languageCode;
      debugPrint('App restarted with locale: $newLocale');
    });
  }

  // Static version of _buildLanguageOption
  static Widget _buildLanguageOptionStatic(
    BuildContext context,
    String languageName,
    String languageCode,
    String flagAsset,
  ) {
    final isSelected = context.locale.languageCode == languageCode;

    return InkWell(
      onTap: () async {
        // Save current context before async gap
        final currentContext = context;

        // Log the current locale before changing
        final oldLocale = context.locale.languageCode;
        debugPrint('Current locale before change: $oldLocale');

        // Use LocaleManager to change and save the locale
        await LocaleManager.changeLocale(context, languageCode);

        // Close the dialog
        if (currentContext.mounted) {
          Navigator.pop(currentContext);

          // Wait a bit to ensure the locale change is processed
          await Future.delayed(const Duration(milliseconds: 300));

          // Restart the app to ensure the locale change is applied
          _restartApp();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2B7A78).withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2B7A78) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              flagAsset,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.language,
                  size: 24,
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF2B7A78) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2B7A78),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageName,
    String languageCode,
    String flagAsset,
  ) {
    final isSelected = context.locale.languageCode == languageCode;

    return InkWell(
      onTap: () async {
        // Save current context before async gap
        final currentContext = context;

        // Log the current locale before changing
        final oldLocale = context.locale.languageCode;
        debugPrint('Current locale before change: $oldLocale');

        // Use LocaleManager to change and save the locale
        await LocaleManager.changeLocale(context, languageCode);

        // Close the dialog
        if (currentContext.mounted) {
          Navigator.pop(currentContext);

          // Wait a bit to ensure the locale change is processed
          await Future.delayed(const Duration(milliseconds: 300));

          // Restart the app to ensure the locale change is applied
          _restartApp();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2B7A78).withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2B7A78) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              flagAsset,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.language,
                  size: 24,
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF2B7A78) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2B7A78),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageMenuItem(
    BuildContext context,
    String languageName,
    String languageCode,
    String flagAsset,
  ) {
    final isSelected = context.locale.languageCode == languageCode;

    return Row(
      children: [
        Image.asset(
          flagAsset,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.language,
              size: 24,
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            languageName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2B7A78) : Colors.black87,
            ),
          ),
        ),
        if (isSelected)
          const Icon(
            Icons.check_circle,
            color: Color(0xFF2B7A78),
            size: 20,
          ),
      ],
    );
  }
}
