import 'package:flutter/material.dart';

/// App-wide theme mode. Registered in DI and observed via [ListenableBuilder].
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  /// Sets light or dark to the opposite of the currently visible [effectiveBrightness].
  ///
  /// When [themeMode] is [ThemeMode.system], pass [Brightness] from [Theme.of].
  void toggleLightDark(Brightness effectiveBrightness) {
    setThemeMode(
      effectiveBrightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }
}
