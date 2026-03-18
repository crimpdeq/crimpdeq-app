import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────── Brand accent ─────────────────────────────
const brandAccent = Color(0xFFFF6B35);

// ──────────────────────────── Cached text styles ────────────────────────
// Pre-built GoogleFonts styles to avoid repeated instantiation in hot build paths.
// Use .copyWith(color: ...) when color varies per-widget.

// Inter
final tsInterW700S20 = GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20);
final tsInterW700S16 = GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16);
final tsInterW700S14 = GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14);
final tsInterW700S18 = GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18);
final tsInterW600 = GoogleFonts.inter(fontWeight: FontWeight.w600);
final tsInterW600S16 = GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16);
final tsInterW600S14 = GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14);
final tsInterW600S13 = GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13);
final tsInterW600S12 = GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12);
final tsInterW800S24 = GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 24);
final tsInterS14 = GoogleFonts.inter(fontSize: 14);
final tsInterS12 = GoogleFonts.inter(fontSize: 12);
final tsInterS11 = GoogleFonts.inter(fontSize: 11);
final tsInterS9 = GoogleFonts.inter(fontSize: 9);
final tsInterW700S11 = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8);
final tsInterW500S12 = GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12);
final tsInterW600S16Spaced = GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 1.2);

// Space Grotesk
final tsGrotesk800S72 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, fontSize: 72, height: 1);
final tsGrotesk800S96 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, fontSize: 96, height: 1);
final tsGrotesk700S18 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 18);
final tsGrotesk700S16 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 16);
final tsGrotesk700S14 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 14);
final tsGrotesk600S28 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 28);
final tsGrotesk600S24 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 24);
final tsGrotesk600S14 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 14);
final tsGrotesk800S24 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, fontSize: 24);
final tsGrotesk500S10 = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, fontSize: 10);

// ──────────────────────────── Dark palette ────────────────────────────
const paleRed = Color(0xFFE57373);
const webBg = Color(0xFF0A0A0A);
const webBgSoft = Color(0xFF141414);
const webPanel = Color(0xFF1A1A1A);
const webPanelDeep = Color(0xFF0F0F0F);
const webText = Color(0xFFF0F0F0);
const webMuted = Color(0xFF8B8B8B);
const dataAccent = Color(0xFFE0E0E0);
const webAccent = Color(0xFFE0E0E0);
const webAccentStrong = Color(0xFFFFFFFF);
const webBorder = Color(0xFF2A2A2A);

// ──────────────────────────── Theme notifier ──────────────────────────
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void setDarkMode(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

// ──────────────────────────── Dark theme ──────────────────────────────
ThemeData buildDarkTheme() {
  final colorScheme = const ColorScheme.dark(
    primary: brandAccent,
    onPrimary: Colors.white,
    secondary: webAccentStrong,
    onSecondary: Color(0xFF0A0A0A),
    surface: webPanel,
    onSurface: webText,
    error: paleRed,
    onError: Colors.white,
    outline: webBorder,
    outlineVariant: Color(0xFF333333),
  );
  final baseText = GoogleFonts.interTextTheme(
    ThemeData.dark().textTheme,
  );
  final textTheme = baseText.copyWith(
    headlineSmall: GoogleFonts.inter(
      textStyle: baseText.headlineSmall,
      fontWeight: FontWeight.w800,
      color: webText,
    ),
    titleLarge: GoogleFonts.inter(
      textStyle: baseText.titleLarge,
      fontWeight: FontWeight.w700,
      color: webText,
    ),
    titleMedium: GoogleFonts.inter(
      textStyle: baseText.titleMedium,
      fontWeight: FontWeight.w700,
      color: webText,
    ),
    bodyLarge: GoogleFonts.inter(
      textStyle: baseText.bodyLarge,
      color: webText,
    ),
    bodyMedium: GoogleFonts.inter(
      textStyle: baseText.bodyMedium,
      color: webText,
    ),
    bodySmall: GoogleFonts.inter(
      textStyle: baseText.bodySmall,
      color: webMuted,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: webBg,
    canvasColor: webBg,
    dividerColor: webBorder,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: webBg,
      foregroundColor: webText,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: webText,
      ),
    ),
    cardTheme: CardThemeData(
      color: webPanel,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: webBorder.withValues(alpha: 0.6)),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: webBg,
      indicatorColor: brandAccent.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: webAccent, size: 22);
        }
        return const IconThemeData(color: webMuted, size: 22);
      }),
      height: 52,
    ),
    tabBarTheme: TabBarThemeData(
      indicator: BoxDecoration(
        color: webAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: webBorder,
      labelColor: const Color(0xFF0A0A0A),
      unselectedLabelColor: webMuted,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      splashBorderRadius: BorderRadius.circular(10),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brandAccent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: webPanelDeep,
        disabledForegroundColor: webMuted,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandAccent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: webPanelDeep,
        disabledForegroundColor: webMuted,
        elevation: 0,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: webText,
        side: BorderSide(color: webBorder.withValues(alpha: 0.8)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: webBgSoft,
      labelStyle: const TextStyle(color: webMuted),
      hintStyle: const TextStyle(color: webMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: webBorder.withValues(alpha: 0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: webBorder.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: webAccent, width: 1.5),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minLeadingWidth: 24,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return webAccent;
        return webMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return webAccent.withValues(alpha: 0.3);
        }
        return webBorder;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(
        webBgSoft.withValues(alpha: 0.8),
      ),
      headingTextStyle: GoogleFonts.inter(
        color: webText,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      dataTextStyle: GoogleFonts.spaceGrotesk(color: webText, fontSize: 12),
      dividerThickness: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: webPanel,
      contentTextStyle: GoogleFonts.spaceGrotesk(color: webText),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: webBorder.withValues(alpha: 0.6)),
      ),
    ),
  );
}

// ──────────────────────────── Light palette ────────────────────────────
const lightBg = Color(0xFFF5F5F5);
const lightPanel = Colors.white;
const lightText = Color(0xFF1A1A1A);
const lightMuted = Color(0xFF6E6E6E);
const lightAccent = Color(0xFF2C2C2C);
const lightDataAccent = Color(0xFF2C2C2C);
const lightBorder = Color(0xFFDDDDDD);

// ──────────────────────────── Light theme ─────────────────────────────
ThemeData buildLightTheme() {
  final dark = buildDarkTheme();
  final baseText = GoogleFonts.interTextTheme(
    ThemeData.light().textTheme,
  );
  return dark.copyWith(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: brandAccent,
      onPrimary: Colors.white,
      secondary: Color(0xFF444444),
      onSecondary: Colors.white,
      surface: lightPanel,
      onSurface: lightText,
      error: Color(0xFFCF222E),
      onError: Colors.white,
      outline: lightBorder,
      outlineVariant: Color(0xFFE8E8E8),
    ),
    scaffoldBackgroundColor: lightBg,
    canvasColor: lightBg,
    dividerColor: lightBorder,
    textTheme: baseText.copyWith(
      headlineSmall: GoogleFonts.inter(
        textStyle: baseText.headlineSmall,
        fontWeight: FontWeight.w700,
        color: lightText,
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: baseText.titleLarge,
        fontWeight: FontWeight.w600,
        color: lightText,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: baseText.titleMedium,
        fontWeight: FontWeight.w600,
        color: lightText,
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: baseText.bodyLarge,
        color: lightText,
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: baseText.bodyMedium,
        color: lightText,
      ),
      bodySmall: GoogleFonts.inter(
        textStyle: baseText.bodySmall,
        color: lightMuted,
      ),
    ),
    appBarTheme: dark.appBarTheme.copyWith(
      backgroundColor: lightBg,
      foregroundColor: lightText,
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: lightText,
      ),
    ),
    cardTheme: CardThemeData(
      color: lightPanel,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: lightBorder.withValues(alpha: 0.7)),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightBg,
      indicatorColor: brandAccent.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: lightAccent, size: 22);
        }
        return const IconThemeData(color: lightMuted, size: 22);
      }),
      height: 52,
    ),
    tabBarTheme: TabBarThemeData(
      indicator: BoxDecoration(
        color: lightAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: lightBorder,
      labelColor: Colors.white,
      unselectedLabelColor: lightMuted,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      splashBorderRadius: BorderRadius.circular(10),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return lightAccent;
        return lightMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return lightAccent.withValues(alpha: 0.25);
        }
        return lightBorder;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    inputDecorationTheme: dark.inputDecorationTheme.copyWith(
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: lightMuted),
      hintStyle: const TextStyle(color: lightMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBorder.withValues(alpha: 0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBorder.withValues(alpha: 0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightAccent, width: 1.5),
      ),
    ),
    dataTableTheme: dark.dataTableTheme.copyWith(
      headingRowColor: const WidgetStatePropertyAll(Color(0xFFF6F8FA)),
      headingTextStyle: GoogleFonts.inter(
        color: lightText,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      dataTextStyle: GoogleFonts.spaceGrotesk(
        color: lightText,
        fontSize: 12,
      ),
    ),
    snackBarTheme: dark.snackBarTheme.copyWith(
      backgroundColor: Colors.white,
      contentTextStyle: GoogleFonts.spaceGrotesk(color: lightText),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: lightBorder.withValues(alpha: 0.7)),
      ),
    ),
  );
}
