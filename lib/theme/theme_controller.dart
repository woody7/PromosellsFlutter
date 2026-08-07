import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lean replacement for AdroitERP's ThemeCustomizer: that class also drags
/// in a full localization/language system and multi-tenant "AdminTheme"
/// machinery that PromosellsFlutter doesn't need. This keeps just the part
/// that matters here — persisted light/dark mode — via GetX's reactive
/// ChangeNotifier-free style (a plain ValueNotifier is enough for a single
/// setting like this).
class ThemeController {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const _prefsKey = 'themeMode';

  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    mode.value = stored == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    mode.value = mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.value == ThemeMode.dark ? 'dark' : 'light');
  }
}
