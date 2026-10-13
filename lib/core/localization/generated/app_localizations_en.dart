// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'QO\'SHNI';

  @override
  String get homeHeadline => 'Foundation ready';

  @override
  String get homeSubtitle =>
      'Scalable architecture for local services and marketplace.';

  @override
  String environmentLabel(String env) {
    return 'Environment: $env';
  }

  @override
  String get homeMainHeading => 'What do you need right now?';

  @override
  String get homeSearchHint => 'Search for a service or store';

  @override
  String get homeNearbyTitle => 'Near you';

  @override
  String get mapPreviewTitle => 'Explore on the map';

  @override
  String get mapPreviewSubtitle => 'Services and stores around you';

  @override
  String get openMap => 'Open map';

  @override
  String get mapPlaceholderTitle => 'Map';

  @override
  String get mapPlaceholderBody =>
      'Interactive map will connect in a later release.';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryPharmacy => 'Pharmacy';

  @override
  String get categoryShops => 'Shops';

  @override
  String get categoryMasters => 'Masters';

  @override
  String get categoryRent => 'Rent';

  @override
  String get nearbyMock1Name => 'Baraka Market';

  @override
  String get nearbyMock1Distance => '0.8 km';

  @override
  String get nearbyMock1Description =>
      'Fictional neighborhood grocery with fresh produce and everyday essentials (demo listing).';

  @override
  String get nearbyMock1Address => 'Sample District, Demo Street 12';

  @override
  String get nearbyMock1Hours => 'Daily, 8:00–22:00';

  @override
  String get nearbyMock2Name => 'Samarkand Cafe';

  @override
  String get nearbyMock2Distance => '1.2 km';

  @override
  String get nearbyMock2Description =>
      'Fictional cafe serving local-style dishes and drinks for this MVP preview.';

  @override
  String get nearbyMock2Address => 'Sample District, Demo Avenue 5';

  @override
  String get nearbyMock2Hours => 'Mon–Sun, 9:00–23:00';

  @override
  String get nearbyMock3Name => 'Shifo Plus';

  @override
  String get nearbyMock3Distance => '1.5 km';

  @override
  String get nearbyMock3Description =>
      'Fictional pharmacy mock entry for over-the-counter items in the demo catalog.';

  @override
  String get nearbyMock3Address => 'Sample District, Health Lane 3';

  @override
  String get nearbyMock3Hours => 'Daily, 8:00–20:00';

  @override
  String get listingMockShop1Name => 'Sample — Tech Corner';

  @override
  String get listingMockShop1Distance => '1.0 km';

  @override
  String get listingMockShop1Description =>
      'Fictional electronics shop used to preview category listings.';

  @override
  String get listingMockShop1Address => 'Demo Mall, Level 1, Unit 7';

  @override
  String get listingMockShop1Hours => 'Daily, 10:00–21:00';

  @override
  String get listingMockShop2Name => 'Sample — Style Shop';

  @override
  String get listingMockShop2Distance => '1.8 km';

  @override
  String get listingMockShop2Description =>
      'Fictional clothing boutique mock for the shops category.';

  @override
  String get listingMockShop2Address => 'Demo Bazaar, Row B, Shop 14';

  @override
  String get listingMockShop2Hours => 'Tue–Sun, 10:00–19:00';

  @override
  String get listingMockMaster1Name => 'Sample — Pipe Fix';

  @override
  String get listingMockMaster1Distance => '2.1 km';

  @override
  String get listingMockMaster1Description =>
      'Fictional plumbing service mock for home repairs preview.';

  @override
  String get listingMockMaster1Address => 'On-call — demo service area only';

  @override
  String get listingMockMaster1Hours => 'Mon–Sat, 9:00–18:00';

  @override
  String get listingMockMaster2Name => 'Sample — Electric Help';

  @override
  String get listingMockMaster2Distance => '2.6 km';

  @override
  String get listingMockMaster2Description =>
      'Fictional electrician mock entry for the masters category.';

  @override
  String get listingMockMaster2Address => 'On-call — demo service area only';

  @override
  String get listingMockMaster2Hours => 'Mon–Fri, 8:00–17:00';

  @override
  String get listingMockRent1Name => 'Sample — Apartment Hub';

  @override
  String get listingMockRent1Distance => '3.0 km';

  @override
  String get listingMockRent1Description =>
      'Fictional short-term apartment rental mock for the rent category.';

  @override
  String get listingMockRent1Address => 'Sample District, Demo Residence Block';

  @override
  String get listingMockRent1Hours => 'Office hours: Mon–Fri, 9:00–18:00';

  @override
  String get listingMockRent2Name => 'Sample — Car Rent';

  @override
  String get listingMockRent2Distance => '3.4 km';

  @override
  String get listingMockRent2Description =>
      'Fictional car rental mock entry for local mobility preview.';

  @override
  String get listingMockRent2Address => 'Demo Airport Road, Parking Lot C';

  @override
  String get listingMockRent2Hours => 'Daily, 7:00–22:00';

  @override
  String get businessDetailSectionAbout => 'About';

  @override
  String get businessDetailSectionLocation => 'Location';

  @override
  String get businessDetailSectionHours => 'Hours';

  @override
  String get businessDetailInfoNotAvailable =>
      'Not provided in this demo listing.';

  @override
  String get businessDetailNotFoundTitle => 'Business not found';

  @override
  String get businessDetailNotFoundBody =>
      'Go back and choose another listing from search or categories.';

  @override
  String get categoryListingEmptyTitle => 'No listings yet';

  @override
  String get categoryListingEmptyBody =>
      'New partners in this category will appear here soon.';

  @override
  String get categoryListingUnknownTitle => 'Category not found';

  @override
  String get categoryListingUnknownBody =>
      'Go back and choose a category from the home screen.';

  @override
  String get toggleThemeTooltip => 'Toggle theme';

  @override
  String get languageTooltip => 'Language';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchClearQuery => 'Clear query';

  @override
  String get searchInitialTitle => 'What are you looking for?';

  @override
  String get searchInitialBody => 'Type a service, store, or category name.';

  @override
  String get searchEmptyTitle => 'No results found';

  @override
  String get searchEmptyBody => 'Try a different search term.';

  @override
  String get searchCategoryEntrySubtitle => 'Category';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesAddTooltip => 'Save to favorites';

  @override
  String get favoritesRemoveTooltip => 'Remove from favorites';

  @override
  String get favoritesEmptyTitle => 'No saved businesses yet';

  @override
  String get favoritesEmptyBody =>
      'Tap the heart on a business page to save it here for quick access.';

  @override
  String get favoritesGoHome => 'Back to Home';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileOpenTooltip => 'Profile';

  @override
  String get profileGuestTitle => 'Guest user';

  @override
  String get profileGuestBody =>
      'You are using QO‘SHNI without signing in. Account features will arrive in a later release.';

  @override
  String get profileSectionShortcuts => 'Shortcuts';

  @override
  String profileFavoritesSavedCount(int count) {
    return '$count saved';
  }

  @override
  String get profileSectionAppearance => 'Appearance';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileSectionLanguage => 'Language';

  @override
  String get profileLanguageSystem => 'System default';

  @override
  String get profileLanguageUz => 'O‘zbekcha';

  @override
  String get profileLanguageRu => 'Русский';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileAboutTitle => 'About';

  @override
  String get profileAboutGuestNote =>
      'Guest mode preview — no personal data is stored on this device beyond the current session.';
}
