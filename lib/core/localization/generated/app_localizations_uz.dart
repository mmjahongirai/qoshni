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

  @override
  String get homeMainHeading => 'Sizga hozir nima kerak?';

  @override
  String get homeSearchHint => 'Xizmat yoki do‘kon qidiring';

  @override
  String get homeNearbyTitle => 'Sizga yaqin';

  @override
  String get mapPreviewTitle => 'Xaritada qidiring';

  @override
  String get mapPreviewSubtitle => 'Yaqin atrofdagi xizmatlar va do‘konlar';

  @override
  String get openMap => 'Xaritani ochish';

  @override
  String get mapPlaceholderTitle => 'Xarita';

  @override
  String get mapPlaceholderBody =>
      'Interaktiv xarita keyingi bosqichda ulanadi.';

  @override
  String get categoryGroceries => 'Oziq-ovqat';

  @override
  String get categoryRestaurants => 'Restoranlar';

  @override
  String get categoryPharmacy => 'Dorixona';

  @override
  String get categoryShops => 'Do‘konlar';

  @override
  String get categoryMasters => 'Ustalar';

  @override
  String get categoryRent => 'Ijara';

  @override
  String get nearbyMock1Name => 'Baraka Market';

  @override
  String get nearbyMock1Subtitle => 'Oziq-ovqat • 0.8 km';

  @override
  String get nearbyMock2Name => 'Samarkand Cafe';

  @override
  String get nearbyMock2Subtitle => 'Restoran • 1.2 km';

  @override
  String get nearbyMock3Name => 'Shifo Plus';

  @override
  String get nearbyMock3Subtitle => 'Dorixona • 1.5 km';

  @override
  String get toggleThemeTooltip => 'Mavzuni almashtirish';

  @override
  String get languageTooltip => 'Til';
}
