// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'QO\'SHNI';

  @override
  String get homeHeadline => 'Asos tayyor';

  @override
  String get homeSubtitle =>
      'Mahalliy xizmatlar va marketplace uchun masshtablanadigan arxitektura.';

  @override
  String environmentLabel(String env) {
    return 'Muhit: $env';
  }
}
