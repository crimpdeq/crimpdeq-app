import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_mode_provider.dart';
import 'screens/crimpdeq_screen.dart';
import 'theme.dart';

class CrimpdeqApp extends ConsumerWidget {
  const CrimpdeqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Crimpdeq',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ref.watch(themeModeProvider),
      home: const CrimpdeqScreen(),
    );
  }
}
