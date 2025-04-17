import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import '../core/utilities/theme_manager.dart';

class ThemeSwitcher extends StatelessWidget {
  final bool showTitle;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const ThemeSwitcher({
    super.key,
    this.showTitle = true,
    this.iconSize = 24.0,
    this.iconColor,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode;
    try {
      isDarkMode = ThemeManager.isDarkMode();
    } catch (e) {
      debugPrint('ThemeSwitcher: Error getting dark mode: $e');
      isDarkMode = false; // Default to light mode
    }

    return InkWell(
      onTap: () => _showThemeDialog(context),
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
            Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: iconSize,
              color: iconColor ?? Theme.of(context).primaryColor,
            ),
            if (showTitle) ...[
              const SizedBox(width: 8),
              Text(
                isDarkMode
                    ? context.tr('menu.dark_mode')
                    : context.tr('menu.light_mode'),
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

  void _showThemeDialog(BuildContext context) {
    String currentThemeMode;
    try {
      currentThemeMode = ThemeManager.getCurrentThemeMode();
    } catch (e) {
      debugPrint('ThemeSwitcher: Error getting current theme mode: $e');
      currentThemeMode = ThemeManager.system; // Default to system
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('menu.theme')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              context.tr('menu.light_mode'),
              ThemeManager.light,
              Icons.light_mode,
              currentThemeMode == ThemeManager.light,
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              context,
              context.tr('menu.dark_mode'),
              ThemeManager.dark,
              Icons.dark_mode,
              currentThemeMode == ThemeManager.dark,
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              context,
              context.tr('menu.system_mode'),
              ThemeManager.system,
              Icons.settings_suggest,
              currentThemeMode == ThemeManager.system,
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

  Widget _buildThemeOption(
    BuildContext context,
    String themeName,
    String themeMode,
    IconData icon,
    bool isSelected,
  ) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () async {
        // Save current context before async gap
        final currentContext = context;

        // Change the theme mode
        await ThemeManager.changeThemeMode(themeMode);

        // Close the dialog
        if (currentContext.mounted) {
          Navigator.pop(currentContext);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                themeName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // Static method to show theme dialog from anywhere
  static void showThemeDialogStatic(BuildContext context) {
    String currentThemeMode;
    try {
      currentThemeMode = ThemeManager.getCurrentThemeMode();
    } catch (e) {
      debugPrint('ThemeSwitcher: Error getting current theme mode: $e');
      currentThemeMode = ThemeManager.system; // Default to system
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('menu.theme')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOptionStatic(
              context,
              context.tr('menu.light_mode'),
              ThemeManager.light,
              Icons.light_mode,
              currentThemeMode == ThemeManager.light,
            ),
            const SizedBox(height: 16),
            _buildThemeOptionStatic(
              context,
              context.tr('menu.dark_mode'),
              ThemeManager.dark,
              Icons.dark_mode,
              currentThemeMode == ThemeManager.dark,
            ),
            const SizedBox(height: 16),
            _buildThemeOptionStatic(
              context,
              context.tr('menu.system_mode'),
              ThemeManager.system,
              Icons.settings_suggest,
              currentThemeMode == ThemeManager.system,
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

  // Static version of _buildThemeOption
  static Widget _buildThemeOptionStatic(
    BuildContext context,
    String themeName,
    String themeMode,
    IconData icon,
    bool isSelected,
  ) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () async {
        // Save current context before async gap
        final currentContext = context;

        // Change the theme mode
        await ThemeManager.changeThemeMode(themeMode);

        // Close the dialog
        if (currentContext.mounted) {
          Navigator.pop(currentContext);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                themeName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
