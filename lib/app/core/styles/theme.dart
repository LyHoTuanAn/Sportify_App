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
  static const Color primary = Color(0xffFF4F4F);
  static const Color secondary = Color(0xFF7BC286);
  static const Color primaryVariant = Color(0xFF99F6E4);
  static const Color background = Colors.white;
  static const Color placeholder = Color(0xFFE0E0E0);
  static const Color labelColor = Color(0xff000000);
  static const Color titleColor = Color(0xff3B3B3B);
  static const Color subtitleColor = Color(0xff848484);
  static const Color hintColor = Color(0xff9B9B9B);
  static const Color appBar = Color(0xFF1e1818);
  static const Color appBarTintColor = Colors.white;
  static const Color deactivate = Color(0xff8C8C8C);
  static const Color textColor = Colors.white;
  static const Color inputBoxColor = Color.fromRGBO(44, 47, 51, 0.5);
  static const Color inputBoxBorderColor = Color.fromRGBO(84, 84, 84, 1);
  static const Color shadowBoxColor = Color.fromRGBO(0, 0, 0, 0.5);

  static ThemeData getCollectionTheme() {
    ColorScheme colorScheme = const ColorScheme.light(
      primary: primary,
      primaryContainer: primaryVariant,
      secondary: secondary,
      secondaryContainer: Color(0xffc75b39),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    );

    final bool dark = colorScheme.brightness == Brightness.dark;
    final appBarColor = colorScheme.surface;
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
        foregroundColor: appBarTintColor,
        titleTextStyle: const TextStyle(
          fontSize: 16,
          color: appBarTintColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: colorScheme.surface,
      dividerColor: colorScheme.onSurface.withValues(alpha: (0.12 * 255).round() / 255),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
      ),
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
      textTheme: GoogleFonts.interTextTheme(),
      fontFamily: 'Inter',
      colorScheme: colorScheme
          .copyWith(error: colorScheme.error)
          .copyWith(surface: colorScheme.surface),
      bottomAppBarTheme: BottomAppBarTheme(color: colorScheme.surface),
    );
  }
}
