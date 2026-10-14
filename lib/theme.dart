import 'package:flutter/material.dart';

/// Families bundled in pubspec.yaml: Inter for headings and controls, Space
/// Grotesk for body text.
const interFont = 'Inter';
const spaceGroteskFont = 'SpaceGrotesk';

const paleRed = Color(0xFFE57373);
const webBg = Color(0xFF0B1118);
const webBgSoft = Color(0xFF101A26);
const webBorder = Color(0xFF2B3F53);
const webAccent = Color(0xFF4FC3F7);
const webAccentStrong = Color(0xFF7CD6FF);
const _webPanel = Color(0xFF162333);
const _webPanelDeep = Color(0xFF0C131D);
const _webText = Color(0xFFECF2F8);
const _webMuted = Color(0xFF9EB1C5);
const _lightText = Color(0xFF0B1118);
const _lightMuted = Color(0xFF607486);
const _lightBorder = Color(0xFFD7E3EE);

TextStyle _inter(FontWeight weight, {double? fontSize, Color? color}) =>
    TextStyle(
      fontFamily: interFont,
      fontWeight: weight,
      fontSize: fontSize,
      color: color,
    );

TextTheme _textTheme(TextTheme base, {Color? text, required Color muted}) {
  final textTheme = base.apply(fontFamily: spaceGroteskFont);
  TextStyle? heading(TextStyle? style, FontWeight weight) =>
      style?.copyWith(fontFamily: interFont, fontWeight: weight, color: text);
  return textTheme.copyWith(
    headlineSmall: heading(textTheme.headlineSmall, FontWeight.w800),
    titleLarge: heading(textTheme.titleLarge, FontWeight.w700),
    titleMedium: heading(textTheme.titleMedium, FontWeight.w700),
    bodySmall: textTheme.bodySmall?.copyWith(color: muted),
  );
}

OutlineInputBorder _inputBorder(Color color, [double width = 1]) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

TabBarThemeData _tabBarTheme({
  required List<Color> indicatorColors,
  required Color divider,
  required Color label,
  required Color unselectedLabel,
}) => TabBarThemeData(
  indicator: BoxDecoration(
    gradient: LinearGradient(
      colors: indicatorColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  indicatorSize: TabBarIndicatorSize.tab,
  dividerColor: divider,
  labelColor: label,
  unselectedLabelColor: unselectedLabel,
  labelStyle: _inter(FontWeight.w700, fontSize: 13),
  unselectedLabelStyle: _inter(FontWeight.w600, fontSize: 13),
  splashBorderRadius: BorderRadius.circular(12),
);

ThemeData buildDarkTheme() {
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: spaceGroteskFont,
    colorScheme: const ColorScheme.dark(
      primary: webAccent,
      onPrimary: Color(0xFF00111C),
      secondary: webAccentStrong,
      onSecondary: Color(0xFF00111C),
      surface: _webPanel,
      onSurface: _webText,
      error: paleRed,
      onError: Colors.white,
      outline: webBorder,
      outlineVariant: Color(0xFF223447),
    ),
    scaffoldBackgroundColor: webBg,
    canvasColor: webBg,
    dividerColor: webBorder,
    textTheme: _textTheme(
      ThemeData.dark().textTheme,
      text: _webText,
      muted: _webMuted,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _webPanel.withValues(alpha: 0.95),
      foregroundColor: _webText,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: _inter(FontWeight.w700, fontSize: 20, color: _webText),
    ),
    cardTheme: CardThemeData(
      color: _webPanel.withValues(alpha: 0.94),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: webBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    tabBarTheme: _tabBarTheme(
      indicatorColors: const [webAccent, webAccentStrong],
      divider: webBorder,
      label: const Color(0xFF00111C),
      unselectedLabel: _webMuted,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: webAccent,
        foregroundColor: const Color(0xFF00111C),
        disabledBackgroundColor: _webPanelDeep,
        disabledForegroundColor: _webMuted,
        textStyle: _inter(FontWeight.w700),
        shape: buttonShape,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: webAccent,
        foregroundColor: const Color(0xFF00111C),
        disabledBackgroundColor: _webPanelDeep,
        disabledForegroundColor: _webMuted,
        elevation: 0,
        textStyle: _inter(FontWeight.w700),
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _webText,
        side: const BorderSide(color: webBorder),
        textStyle: _inter(FontWeight.w700),
        shape: buttonShape,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: webBgSoft.withValues(alpha: 0.95),
      labelStyle: const TextStyle(color: _webMuted),
      hintStyle: const TextStyle(color: _webMuted),
      border: _inputBorder(webBorder),
      enabledBorder: _inputBorder(webBorder),
      focusedBorder: _inputBorder(webAccentStrong, 1.4),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(webBgSoft.withValues(alpha: 0.8)),
      headingTextStyle: _inter(FontWeight.w700, fontSize: 12, color: _webText),
      dataTextStyle: const TextStyle(
        fontFamily: spaceGroteskFont,
        color: _webText,
        fontSize: 12,
      ),
      dividerThickness: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _webPanelDeep,
      contentTextStyle: const TextStyle(
        fontFamily: spaceGroteskFont,
        color: _webText,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: webBorder),
      ),
    ),
  );
}

ThemeData buildLightTheme() {
  final dark = buildDarkTheme();
  return dark.copyWith(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0A7FB3),
      onPrimary: Colors.white,
      secondary: Color(0xFF38BDF8),
      onSecondary: Color(0xFF031018),
      surface: Color(0xFFF6FAFD),
      onSurface: _lightText,
      error: Color(0xFFD64F4F),
      onError: Colors.white,
      outline: Color(0xFFC9D8E6),
      outlineVariant: Color(0xFFE1EAF2),
    ),
    scaffoldBackgroundColor: const Color(0xFFEFF5FB),
    canvasColor: const Color(0xFFEFF5FB),
    dividerColor: _lightBorder,
    textTheme: _textTheme(
      ThemeData.light().textTheme,
      muted: const Color(0xFF5C7187),
    ),
    appBarTheme: dark.appBarTheme.copyWith(
      backgroundColor: Colors.white.withValues(alpha: 0.92),
      foregroundColor: _lightText,
      titleTextStyle: _inter(FontWeight.w700, fontSize: 20, color: _lightText),
    ),
    cardTheme: dark.cardTheme.copyWith(
      color: Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _lightBorder),
      ),
    ),
    tabBarTheme: _tabBarTheme(
      indicatorColors: const [Color(0xFF0A7FB3), Color(0xFF38BDF8)],
      divider: _lightBorder,
      label: Colors.white,
      unselectedLabel: _lightMuted,
    ),
    inputDecorationTheme: dark.inputDecorationTheme.copyWith(
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: _lightMuted),
      hintStyle: const TextStyle(color: _lightMuted),
      border: _inputBorder(_lightBorder),
      enabledBorder: _inputBorder(_lightBorder),
      focusedBorder: _inputBorder(const Color(0xFF0A7FB3), 1.4),
    ),
    dataTableTheme: dark.dataTableTheme.copyWith(
      headingRowColor: const WidgetStatePropertyAll(Color(0xFFF3F8FC)),
      headingTextStyle: _inter(
        FontWeight.w700,
        fontSize: 12,
        color: _lightText,
      ),
      dataTextStyle: const TextStyle(
        fontFamily: spaceGroteskFont,
        color: _lightText,
        fontSize: 12,
      ),
    ),
    snackBarTheme: dark.snackBarTheme.copyWith(
      backgroundColor: Colors.white,
      contentTextStyle: const TextStyle(
        fontFamily: spaceGroteskFont,
        color: _lightText,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _lightBorder),
      ),
    ),
  );
}
