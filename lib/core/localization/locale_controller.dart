import 'package:flutter/material.dart';

/// App-wide locale. Registered in DI and observed via [ListenableBuilder].
class LocaleController extends ChangeNotifier {
  Locale? _locale;

  /// `null` follows the platform locale (within supported list).
  Locale? get locale => _locale;

  void setLocale(Locale? locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}
