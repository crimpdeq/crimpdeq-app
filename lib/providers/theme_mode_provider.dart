import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden at the start with the stored choice, so the first frame has it.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Dark by default, or the choice stored on this device.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  ThemeModeNotifier([this._initial = ThemeMode.dark]);

  static const _key = 'theme.mode';

  final ThemeMode _initial;

  /// The stored choice, read before the app starts.
  static Future<ThemeMode> load() async =>
      switch ((await SharedPreferences.getInstance()).getString(_key)) {
        final name? => ThemeMode.values.byName(name),
        null => ThemeMode.dark,
      };

  @override
  ThemeMode build() => _initial;

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await (await SharedPreferences.getInstance()).setString(_key, mode.name);
  }
}
