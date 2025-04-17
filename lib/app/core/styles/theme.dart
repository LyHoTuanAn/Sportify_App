part of 'style.dart';

class AppGradient {
  static const circleRed = LinearGradient(colors: [
    Color.fromRGBO(232, 100, 157, 1),
    Color.fromRGBO(255, 75, 64, 1),
  ], begin: Alignment.centerLeft, end: Alignment.centerRight);
  static const circleYellow = LinearGradient(colors: [
    Color(0xffF5B257),
    Color.fromRGBO(255, 147, 0, 0.5),
  ], begin: Alignment.centerLeft, end: Alignment.centerRight);
  static const circleGreen = LinearGradient(colors: [
    Color.fromRGBO(123, 194, 134, 1),
    Color.fromRGBO(11, 244, 47, 1),
  ], begin: Alignment.centerLeft, end: Alignment.centerRight);
  static const cardOrange = LinearGradient(colors: [
    Color.fromRGBO(245, 76, 101, 1),
    Color.fromRGBO(248, 130, 95, 1),
  ], begin: Alignment.centerLeft, end: Alignment.centerRight);
  static const buttonPrimary = LinearGradient(colors: [
    Color.fromRGBO(245, 76, 101, 1),
    Color.fromRGBO(248, 130, 95, 1),
  ], begin: Alignment.centerLeft, end: Alignment.centerRight);
  static const buttonSecondary = LinearGradient(colors: [
    Color.fromRGBO(86, 86, 86, 1),
    Color.fromRGBO(248, 130, 95, 1),
  ], begin: Alignment.centerLeft, end: Alignment.centerRight);
}

class AppTheme {
  // Light theme colors
  static const Color primary = Color(0xFF2B7A78);
  static const Color secondary = Color(0xFF3AAFA9);
  static const Color primaryVariant = Color(0xFF99F6E4);
  static const Color background = Colors.white;
  static const Color placeholder = Color(0xFFE0E0E0);
  static const Color labelColor = Color(0xff000000);
  static const Color titleColor = Color(0xff3B3B3B);
  static const Color subtitleColor = Color(0xff848484);
  static const Color hintColor = Color(0xff9B9B9B);
  static const Color appBar = Color(0xFF2B7A78);
  static const Color appBarTintColor = Colors.white;
  static const Color deactivate = Color(0xff8C8C8C);
  static const Color textColor = Colors.black;
  static const Color inputBoxColor = Color.fromRGBO(240, 240, 240, 1);
  static const Color inputBoxBorderColor = Color.fromRGBO(220, 220, 220, 1);
  static const Color shadowBoxColor = Color.fromRGBO(0, 0, 0, 0.1);

  // Dark theme colors
  static const Color primaryDark = Color(0xFF2B7A78);
  static const Color secondaryDark = Color(0xFF3AAFA9);
  static const Color primaryVariantDark = Color(0xFF99F6E4);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color placeholderDark = Color(0xFF424242);
  static const Color labelColorDark = Color(0xFFFFFFFF);
  static const Color titleColorDark = Color(0xFFE0E0E0);
  static const Color subtitleColorDark = Color(0xFFAAAAAA);
  static const Color hintColorDark = Color(0xFF9B9B9B);
  static const Color appBarDark = Color(0xFF1A1A1A);
  static const Color appBarTintColorDark = Colors.white;
  static const Color deactivateDark = Color(0xff8C8C8C);
  static const Color textColorDark = Colors.white;
  static const Color inputBoxColorDark = Color.fromRGBO(44, 47, 51, 0.5);
  static const Color inputBoxBorderColorDark = Color.fromRGBO(84, 84, 84, 1);
  static const Color shadowBoxColorDark = Color.fromRGBO(0, 0, 0, 0.5);

  static ThemeData getCollectionTheme({bool isDark = false}) {
    // Create the appropriate color scheme based on the theme mode
    ColorScheme colorScheme = isDark
        ? const ColorScheme.dark(
            primary: primaryDark,
            primaryContainer: primaryVariantDark,
            secondary: secondaryDark,
            secondaryContainer: Color(0xFF1E6E6B),
            surface: Color(0xFF1E1E1E),
            // ignore: deprecated_member_use
            background: backgroundDark,
            error: Colors.red,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            // ignore: deprecated_member_use
            onBackground: Colors.white,
            onError: Colors.white,
            brightness: Brightness.dark,
          )
        : const ColorScheme.light(
            primary: primary,
            primaryContainer: primaryVariant,
            secondary: secondary,
            secondaryContainer: Color(0xFF1E6E6B),
            surface: Color(0xFFF2F2F2),
            // ignore: deprecated_member_use
            background: background,
            error: Colors.red,
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Colors.black,
            // ignore: deprecated_member_use
            onBackground: Colors.black,
            onError: Colors.white,
            brightness: Brightness.light,
          );

    final bool dark = colorScheme.brightness == Brightness.dark;
    // ignore: deprecated_member_use
    final appBarColor = dark ? appBarDark : appBar;
    final appBarTintColorValue = dark ? appBarTintColorDark : appBarTintColor;
    final indicatorColor = dark ? colorScheme.onSurface : colorScheme.primary;

    return ThemeData(
      brightness: colorScheme.brightness,
      primaryColor: colorScheme.primary,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        color: appBarColor,
        foregroundColor: appBarTintColorValue,
        titleTextStyle: TextStyle(
          fontSize: 16,
          color: appBarTintColorValue,
          fontWeight: FontWeight.w500,
        ),
      ),
      // ignore: deprecated_member_use
      canvasColor: colorScheme.background,
      // ignore: deprecated_member_use
      scaffoldBackgroundColor: colorScheme.background,
      cardColor: dark ? const Color(0xFF2A2A2A) : Colors.white,
      // ignore: deprecated_member_use
      dividerColor: colorScheme.onSurface.withOpacity(dark ? 0.2 : 0.12),
      // ignore: deprecated_member_use
      dialogBackgroundColor: colorScheme.surface,
      indicatorColor: indicatorColor,
      applyElevationOverlayColor: dark,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      fontFamily: 'Inter',
      colorScheme: colorScheme
          .copyWith(error: colorScheme.error)
          // ignore: deprecated_member_use
          .copyWith(background: colorScheme.background),
      bottomAppBarTheme: BottomAppBarTheme(color: colorScheme.surface),
      // Add additional theme properties for dark mode
      iconTheme: IconThemeData(
        color: dark ? Colors.white : Colors.black87,
      ),
    );
  }
}
