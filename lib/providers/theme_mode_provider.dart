import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Dark by default; a light choice is stored on this device.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme.dark';

  @override
  ThemeMode build() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool(_key) == false) state = ThemeMode.light;
    });
    return ThemeMode.dark;
  }

  Future<void> setDarkMode(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    await (await SharedPreferences.getInstance()).setBool(_key, isDark);
  }
}
