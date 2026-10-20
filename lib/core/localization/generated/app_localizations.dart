import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// Application display name
  ///
  /// In en, this message translates to:
  /// **'QO\'SHNI'**
  String get appTitle;

  /// Temporary home headline while features are not implemented
  ///
  /// In en, this message translates to:
  /// **'Foundation ready'**
  String get homeHeadline;

  /// Temporary home subtitle
  ///
  /// In en, this message translates to:
  /// **'Scalable architecture for local services and marketplace.'**
  String get homeSubtitle;

  /// Shows the active build environment
  ///
  /// In en, this message translates to:
  /// **'Environment: {env}'**
  String environmentLabel(String env);

  /// No description provided for @homeMainHeading.
  ///
  /// In en, this message translates to:
  /// **'What do you need right now?'**
  String get homeMainHeading;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a service or store'**
  String get homeSearchHint;

  /// No description provided for @homeNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get homeNearbyTitle;

  /// No description provided for @mapPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore on the map'**
  String get mapPreviewTitle;

  /// No description provided for @mapPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Services and stores around you'**
  String get mapPreviewSubtitle;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get openMap;

  /// No description provided for @homeMapPreviewStatus.
  ///
  /// In en, this message translates to:
  /// **'Demo map preview — live location and places will connect later.'**
  String get homeMapPreviewStatus;

  /// No description provided for @homeNearbyChainsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby chains & essentials'**
  String get homeNearbyChainsTitle;

  /// No description provided for @homeNearbyChainsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find branches and everyday places quickly.'**
  String get homeNearbyChainsSubtitle;

  /// No description provided for @homeEssentialSupermarkets.
  ///
  /// In en, this message translates to:
  /// **'Supermarkets'**
  String get homeEssentialSupermarkets;

  /// No description provided for @homeEssentialPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get homeEssentialPharmacies;

  /// No description provided for @homeEssentialHospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals & clinics'**
  String get homeEssentialHospitals;

  /// No description provided for @homeEssentialRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Cafes & restaurants'**
  String get homeEssentialRestaurants;

  /// No description provided for @homeEssentialPlaceTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Demo category shortcut'**
  String get homeEssentialPlaceTypeHint;

  /// No description provided for @homeMapLegendMarkets.
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get homeMapLegendMarkets;

  /// No description provided for @homeMapLegendPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get homeMapLegendPharmacy;

  /// No description provided for @homeMapLegendHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get homeMapLegendHealth;

  /// No description provided for @homeMapLegendFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get homeMapLegendFood;

  /// No description provided for @mapPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapPlaceholderTitle;

  /// No description provided for @mapPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Interactive map will connect in a later release.'**
  String get mapPlaceholderBody;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get categoryRestaurants;

  /// No description provided for @categoryPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get categoryPharmacy;

  /// No description provided for @categoryShops.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get categoryShops;

  /// No description provided for @categoryMasters.
  ///
  /// In en, this message translates to:
  /// **'Masters'**
  String get categoryMasters;

  /// No description provided for @categoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// No description provided for @nearbyMock1Name.
  ///
  /// In en, this message translates to:
  /// **'Baraka Market'**
  String get nearbyMock1Name;

  /// No description provided for @nearbyMock1Distance.
  ///
  /// In en, this message translates to:
  /// **'0.8 km'**
  String get nearbyMock1Distance;

  /// No description provided for @nearbyMock1Description.
  ///
  /// In en, this message translates to:
  /// **'Fictional neighborhood grocery with fresh produce and everyday essentials (demo listing).'**
  String get nearbyMock1Description;

  /// No description provided for @nearbyMock1Address.
  ///
  /// In en, this message translates to:
  /// **'Sample District, Demo Street 12'**
  String get nearbyMock1Address;

  /// No description provided for @nearbyMock1Hours.
  ///
  /// In en, this message translates to:
  /// **'Daily, 8:00–22:00'**
  String get nearbyMock1Hours;

  /// No description provided for @nearbyMock2Name.
  ///
  /// In en, this message translates to:
  /// **'Samarkand Cafe'**
  String get nearbyMock2Name;

  /// No description provided for @nearbyMock2Distance.
  ///
  /// In en, this message translates to:
  /// **'1.2 km'**
  String get nearbyMock2Distance;

  /// No description provided for @nearbyMock2Description.
  ///
  /// In en, this message translates to:
  /// **'Fictional cafe serving local-style dishes and drinks for this MVP preview.'**
  String get nearbyMock2Description;

  /// No description provided for @nearbyMock2Address.
  ///
  /// In en, this message translates to:
  /// **'Sample District, Demo Avenue 5'**
  String get nearbyMock2Address;

  /// No description provided for @nearbyMock2Hours.
  ///
  /// In en, this message translates to:
  /// **'Mon–Sun, 9:00–23:00'**
  String get nearbyMock2Hours;

  /// No description provided for @nearbyMock3Name.
  ///
  /// In en, this message translates to:
  /// **'Shifo Plus'**
  String get nearbyMock3Name;

  /// No description provided for @nearbyMock3Distance.
  ///
  /// In en, this message translates to:
  /// **'1.5 km'**
  String get nearbyMock3Distance;

  /// No description provided for @nearbyMock3Description.
  ///
  /// In en, this message translates to:
  /// **'Fictional pharmacy mock entry for over-the-counter items in the demo catalog.'**
  String get nearbyMock3Description;

  /// No description provided for @nearbyMock3Address.
  ///
  /// In en, this message translates to:
  /// **'Sample District, Health Lane 3'**
  String get nearbyMock3Address;

  /// No description provided for @nearbyMock3Hours.
  ///
  /// In en, this message translates to:
  /// **'Daily, 8:00–20:00'**
  String get nearbyMock3Hours;

  /// No description provided for @listingMockShop1Name.
  ///
  /// In en, this message translates to:
  /// **'Sample — Tech Corner'**
  String get listingMockShop1Name;

  /// No description provided for @listingMockShop1Distance.
  ///
  /// In en, this message translates to:
  /// **'1.0 km'**
  String get listingMockShop1Distance;

  /// No description provided for @listingMockShop1Description.
  ///
  /// In en, this message translates to:
  /// **'Fictional electronics shop used to preview category listings.'**
  String get listingMockShop1Description;

  /// No description provided for @listingMockShop1Address.
  ///
  /// In en, this message translates to:
  /// **'Demo Mall, Level 1, Unit 7'**
  String get listingMockShop1Address;

  /// No description provided for @listingMockShop1Hours.
  ///
  /// In en, this message translates to:
  /// **'Daily, 10:00–21:00'**
  String get listingMockShop1Hours;

  /// No description provided for @listingMockShop2Name.
  ///
  /// In en, this message translates to:
  /// **'Sample — Style Shop'**
  String get listingMockShop2Name;

  /// No description provided for @listingMockShop2Distance.
  ///
  /// In en, this message translates to:
  /// **'1.8 km'**
  String get listingMockShop2Distance;

  /// No description provided for @listingMockShop2Description.
  ///
  /// In en, this message translates to:
  /// **'Fictional clothing boutique mock for the shops category.'**
  String get listingMockShop2Description;

  /// No description provided for @listingMockShop2Address.
  ///
  /// In en, this message translates to:
  /// **'Demo Bazaar, Row B, Shop 14'**
  String get listingMockShop2Address;

  /// No description provided for @listingMockShop2Hours.
  ///
  /// In en, this message translates to:
  /// **'Tue–Sun, 10:00–19:00'**
  String get listingMockShop2Hours;

  /// No description provided for @listingMockMaster1Name.
  ///
  /// In en, this message translates to:
  /// **'Sample — Pipe Fix'**
  String get listingMockMaster1Name;

  /// No description provided for @listingMockMaster1Distance.
  ///
  /// In en, this message translates to:
  /// **'2.1 km'**
  String get listingMockMaster1Distance;

  /// No description provided for @listingMockMaster1Description.
  ///
  /// In en, this message translates to:
  /// **'Fictional plumbing service mock for home repairs preview.'**
  String get listingMockMaster1Description;

  /// No description provided for @listingMockMaster1Address.
  ///
  /// In en, this message translates to:
  /// **'On-call — demo service area only'**
  String get listingMockMaster1Address;

  /// No description provided for @listingMockMaster1Hours.
  ///
  /// In en, this message translates to:
  /// **'Mon–Sat, 9:00–18:00'**
  String get listingMockMaster1Hours;

  /// No description provided for @listingMockMaster2Name.
  ///
  /// In en, this message translates to:
  /// **'Sample — Electric Help'**
  String get listingMockMaster2Name;

  /// No description provided for @listingMockMaster2Distance.
  ///
  /// In en, this message translates to:
  /// **'2.6 km'**
  String get listingMockMaster2Distance;

  /// No description provided for @listingMockMaster2Description.
  ///
  /// In en, this message translates to:
  /// **'Fictional electrician mock entry for the masters category.'**
  String get listingMockMaster2Description;

  /// No description provided for @listingMockMaster2Address.
  ///
  /// In en, this message translates to:
  /// **'On-call — demo service area only'**
  String get listingMockMaster2Address;

  /// No description provided for @listingMockMaster2Hours.
  ///
  /// In en, this message translates to:
  /// **'Mon–Fri, 8:00–17:00'**
  String get listingMockMaster2Hours;

  /// No description provided for @listingMockRent1Name.
  ///
  /// In en, this message translates to:
  /// **'Sample — Apartment Hub'**
  String get listingMockRent1Name;

  /// No description provided for @listingMockRent1Distance.
  ///
  /// In en, this message translates to:
  /// **'3.0 km'**
  String get listingMockRent1Distance;

  /// No description provided for @listingMockRent1Description.
  ///
  /// In en, this message translates to:
  /// **'Fictional short-term apartment rental mock for the rent category.'**
  String get listingMockRent1Description;

  /// No description provided for @listingMockRent1Address.
  ///
  /// In en, this message translates to:
  /// **'Sample District, Demo Residence Block'**
  String get listingMockRent1Address;

  /// No description provided for @listingMockRent1Hours.
  ///
  /// In en, this message translates to:
  /// **'Office hours: Mon–Fri, 9:00–18:00'**
  String get listingMockRent1Hours;

  /// No description provided for @listingMockRent2Name.
  ///
  /// In en, this message translates to:
  /// **'Sample — Car Rent'**
  String get listingMockRent2Name;

  /// No description provided for @listingMockRent2Distance.
  ///
  /// In en, this message translates to:
  /// **'3.4 km'**
  String get listingMockRent2Distance;

  /// No description provided for @listingMockRent2Description.
  ///
  /// In en, this message translates to:
  /// **'Fictional car rental mock entry for local mobility preview.'**
  String get listingMockRent2Description;

  /// No description provided for @listingMockRent2Address.
  ///
  /// In en, this message translates to:
  /// **'Demo Airport Road, Parking Lot C'**
  String get listingMockRent2Address;

  /// No description provided for @listingMockRent2Hours.
  ///
  /// In en, this message translates to:
  /// **'Daily, 7:00–22:00'**
  String get listingMockRent2Hours;

  /// No description provided for @businessDetailSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get businessDetailSectionAbout;

  /// No description provided for @businessDetailSectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get businessDetailSectionLocation;

  /// No description provided for @businessDetailSectionHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get businessDetailSectionHours;

  /// No description provided for @businessDetailInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not provided in this demo listing.'**
  String get businessDetailInfoNotAvailable;

  /// No description provided for @businessDetailNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Business not found'**
  String get businessDetailNotFoundTitle;

  /// No description provided for @businessDetailNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'Go back and choose another listing from search or categories.'**
  String get businessDetailNotFoundBody;

  /// No description provided for @categoryListingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get categoryListingEmptyTitle;

  /// No description provided for @categoryListingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New partners in this category will appear here soon.'**
  String get categoryListingEmptyBody;

  /// No description provided for @categoryListingUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get categoryListingUnknownTitle;

  /// No description provided for @categoryListingUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'Go back and choose a category from the home screen.'**
  String get categoryListingUnknownBody;

  /// No description provided for @toggleThemeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleThemeTooltip;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTooltip;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @demoContentBadge.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demoContentBadge;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchClearQuery.
  ///
  /// In en, this message translates to:
  /// **'Clear query'**
  String get searchClearQuery;

  /// No description provided for @searchInitialTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get searchInitialTitle;

  /// No description provided for @searchInitialBody.
  ///
  /// In en, this message translates to:
  /// **'Type a service, store, or category name.'**
  String get searchInitialBody;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get searchEmptyBody;

  /// No description provided for @searchCategoryEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get searchCategoryEntrySubtitle;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save to favorites'**
  String get favoritesAddTooltip;

  /// No description provided for @favoritesRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoritesRemoveTooltip;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved businesses yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a business page to save it here for quick access.'**
  String get favoritesEmptyBody;

  /// No description provided for @favoritesGoHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get favoritesGoHome;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileOpenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileOpenTooltip;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest user'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestBody.
  ///
  /// In en, this message translates to:
  /// **'You are using QO‘SHNI without signing in. Account features will arrive in a later release.'**
  String get profileGuestBody;

  /// No description provided for @profileSectionShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get profileSectionShortcuts;

  /// No description provided for @profileFavoritesSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String profileFavoritesSavedCount(int count);

  /// No description provided for @profileSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileSectionAppearance;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileSectionLanguage;

  /// No description provided for @profileLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get profileLanguageSystem;

  /// No description provided for @profileLanguageUz.
  ///
  /// In en, this message translates to:
  /// **'O‘zbekcha'**
  String get profileLanguageUz;

  /// No description provided for @profileLanguageRu.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get profileLanguageRu;

  /// No description provided for @profileLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEn;

  /// No description provided for @profileAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAboutTitle;

  /// No description provided for @profileAboutGuestNote.
  ///
  /// In en, this message translates to:
  /// **'Guest mode preview — no personal data is stored on this device beyond the current session.'**
  String get profileAboutGuestNote;

  /// No description provided for @businessDetailSectionCatalog.
  ///
  /// In en, this message translates to:
  /// **'Products & services'**
  String get businessDetailSectionCatalog;

  /// No description provided for @businessDetailCatalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No demo offerings yet'**
  String get businessDetailCatalogEmptyTitle;

  /// No description provided for @businessDetailCatalogEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Sample products and services for this business will appear here in future updates.'**
  String get businessDetailCatalogEmptyBody;

  /// No description provided for @catalogItemTypeProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get catalogItemTypeProduct;

  /// No description provided for @catalogItemTypeService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get catalogItemTypeService;

  /// No description provided for @catalogSamplePriceDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo price: {amount} so\'m'**
  String catalogSamplePriceDemo(int amount);

  /// No description provided for @catalogItemDetailSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get catalogItemDetailSectionDescription;

  /// No description provided for @catalogItemDetailParentBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get catalogItemDetailParentBusiness;

  /// No description provided for @catalogItemDetailNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Offering not found'**
  String get catalogItemDetailNotFoundTitle;

  /// No description provided for @catalogItemDetailNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This demo item does not exist or does not belong to the selected business.'**
  String get catalogItemDetailNotFoundBody;

  /// No description provided for @catalogBarakaFreshBreadName.
  ///
  /// In en, this message translates to:
  /// **'Sample — village bread'**
  String get catalogBarakaFreshBreadName;

  /// No description provided for @catalogBarakaFreshBreadDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional daily bread listing for the demo grocery.'**
  String get catalogBarakaFreshBreadDesc;

  /// No description provided for @catalogBarakaDailyBasketName.
  ///
  /// In en, this message translates to:
  /// **'Sample — essentials basket'**
  String get catalogBarakaDailyBasketName;

  /// No description provided for @catalogBarakaDailyBasketDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional bundle of pantry staples (demo only).'**
  String get catalogBarakaDailyBasketDesc;

  /// No description provided for @catalogSamarkandPlovName.
  ///
  /// In en, this message translates to:
  /// **'Sample — house plov'**
  String get catalogSamarkandPlovName;

  /// No description provided for @catalogSamarkandPlovDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional single-portion plov for menu preview.'**
  String get catalogSamarkandPlovDesc;

  /// No description provided for @catalogSamarkandGreenTeaName.
  ///
  /// In en, this message translates to:
  /// **'Sample — green tea'**
  String get catalogSamarkandGreenTeaName;

  /// No description provided for @catalogSamarkandGreenTeaDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional teapot serving for the demo cafe.'**
  String get catalogSamarkandGreenTeaDesc;

  /// No description provided for @catalogShifoVitaminCName.
  ///
  /// In en, this message translates to:
  /// **'Sample — vitamin C tablets'**
  String get catalogShifoVitaminCName;

  /// No description provided for @catalogShifoVitaminCDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional OTC item; not a real pharmacy product.'**
  String get catalogShifoVitaminCDesc;

  /// No description provided for @catalogShifoFirstAidKitName.
  ///
  /// In en, this message translates to:
  /// **'Sample — first aid kit'**
  String get catalogShifoFirstAidKitName;

  /// No description provided for @catalogShifoFirstAidKitDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional basic kit for demonstration.'**
  String get catalogShifoFirstAidKitDesc;

  /// No description provided for @catalogTechUsbHubName.
  ///
  /// In en, this message translates to:
  /// **'Sample — USB hub'**
  String get catalogTechUsbHubName;

  /// No description provided for @catalogTechUsbHubDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional accessory for the demo electronics shop.'**
  String get catalogTechUsbHubDesc;

  /// No description provided for @catalogTechPhoneCaseName.
  ///
  /// In en, this message translates to:
  /// **'Sample — phone case'**
  String get catalogTechPhoneCaseName;

  /// No description provided for @catalogTechPhoneCaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional universal case listing.'**
  String get catalogTechPhoneCaseDesc;

  /// No description provided for @catalogStyleCottonTeeName.
  ///
  /// In en, this message translates to:
  /// **'Sample — cotton T-shirt'**
  String get catalogStyleCottonTeeName;

  /// No description provided for @catalogStyleCottonTeeDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional apparel item for the demo boutique.'**
  String get catalogStyleCottonTeeDesc;

  /// No description provided for @catalogPipeLeakVisitName.
  ///
  /// In en, this message translates to:
  /// **'Sample — leak inspection'**
  String get catalogPipeLeakVisitName;

  /// No description provided for @catalogPipeLeakVisitDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional call-out plumbing service (demo).'**
  String get catalogPipeLeakVisitDesc;

  /// No description provided for @catalogPipeTapInstallName.
  ///
  /// In en, this message translates to:
  /// **'Sample — tap installation'**
  String get catalogPipeTapInstallName;

  /// No description provided for @catalogPipeTapInstallDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional installation service with demo pricing.'**
  String get catalogPipeTapInstallDesc;

  /// No description provided for @catalogElectricSocketCheckName.
  ///
  /// In en, this message translates to:
  /// **'Sample — socket safety check'**
  String get catalogElectricSocketCheckName;

  /// No description provided for @catalogElectricSocketCheckDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional electrician visit for the demo catalog.'**
  String get catalogElectricSocketCheckDesc;

  /// No description provided for @catalogRentStudioNightName.
  ///
  /// In en, this message translates to:
  /// **'Sample — studio (1 night)'**
  String get catalogRentStudioNightName;

  /// No description provided for @catalogRentStudioNightDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional short-stay listing; not a real rental.'**
  String get catalogRentStudioNightDesc;

  /// No description provided for @catalogRentSedanDayName.
  ///
  /// In en, this message translates to:
  /// **'Sample — sedan (1 day)'**
  String get catalogRentSedanDayName;

  /// No description provided for @catalogRentSedanDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional car hire listing for demo purposes.'**
  String get catalogRentSedanDayDesc;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartOpenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartOpenTooltip;

  /// No description provided for @cartAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get cartAddToCart;

  /// No description provided for @cartAddedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'{itemName} added to cart (demo)'**
  String cartAddedSnackBar(String itemName);

  /// No description provided for @cartCannotAddNoPrice.
  ///
  /// In en, this message translates to:
  /// **'This demo item has no sample price and cannot be added to the cart total.'**
  String get cartCannotAddNoPrice;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Browse businesses and add demo products or services from an offering page.'**
  String get cartEmptyBody;

  /// No description provided for @cartBrowseHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get cartBrowseHome;

  /// No description provided for @cartQuantityIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get cartQuantityIncrease;

  /// No description provided for @cartQuantityDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get cartQuantityDecrease;

  /// No description provided for @cartRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove from cart'**
  String get cartRemoveItem;

  /// No description provided for @cartClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get cartClearAction;

  /// No description provided for @cartClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cart?'**
  String get cartClearConfirmTitle;

  /// No description provided for @cartClearConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Remove all demo items from your cart?'**
  String get cartClearConfirmBody;

  /// No description provided for @cartClearConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get cartClearConfirmYes;

  /// No description provided for @cartClearConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cartClearConfirmCancel;

  /// No description provided for @cartDemoAmountUzs.
  ///
  /// In en, this message translates to:
  /// **'{amount} so\'m (demo sample price)'**
  String cartDemoAmountUzs(String amount);

  /// No description provided for @cartLineSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Line subtotal (demo): {amount}'**
  String cartLineSubtotal(String amount);

  /// No description provided for @cartEstimatedTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated demo total: {amount}'**
  String cartEstimatedTotalLabel(String amount);

  /// No description provided for @cartDemoEstimateDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is a local demo estimate only — not a quote, invoice, or payment.'**
  String get cartDemoEstimateDisclaimer;

  /// No description provided for @cartProceedCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to checkout'**
  String get cartProceedCheckout;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutReviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Review your demo cart. No payment or personal details are collected in this preview.'**
  String get checkoutReviewNotice;

  /// No description provided for @checkoutConfirmDemoOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm demo order'**
  String get checkoutConfirmDemoOrder;

  /// No description provided for @checkoutQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity}'**
  String checkoutQuantityLabel(int quantity);

  /// No description provided for @checkoutEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to check out'**
  String get checkoutEmptyTitle;

  /// No description provided for @checkoutEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty. Add demo items before checkout.'**
  String get checkoutEmptyBody;

  /// No description provided for @demoOrderConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo confirmation'**
  String get demoOrderConfirmationTitle;

  /// No description provided for @demoOrderPreparedHeading.
  ///
  /// In en, this message translates to:
  /// **'Demo order prepared'**
  String get demoOrderPreparedHeading;

  /// No description provided for @demoOrderReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Demo reference: {referenceId}'**
  String demoOrderReferenceLabel(String referenceId);

  /// No description provided for @demoOrderNoRealSubmissionNotice.
  ///
  /// In en, this message translates to:
  /// **'No real order was sent to any business. No payment was taken and no delivery or booking was scheduled.'**
  String get demoOrderNoRealSubmissionNotice;

  /// No description provided for @demoOrderReturnHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get demoOrderReturnHome;

  /// No description provided for @demoOrderInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation unavailable'**
  String get demoOrderInvalidTitle;

  /// No description provided for @demoOrderInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'This demo confirmation is missing or expired. Start again from the cart.'**
  String get demoOrderInvalidBody;

  /// No description provided for @demoOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get demoOrdersTitle;

  /// No description provided for @demoOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No demo orders yet'**
  String get demoOrdersEmptyTitle;

  /// No description provided for @demoOrdersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm a demo checkout to see a local order preview here. Nothing is sent to businesses.'**
  String get demoOrdersEmptyBody;

  /// No description provided for @demoOrdersListSummary.
  ///
  /// In en, this message translates to:
  /// **'{lineCount, plural, =1{1 line · {unitCount} unit} other{{lineCount} lines · {unitCount} units}}'**
  String demoOrdersListSummary(int lineCount, int unitCount);

  /// No description provided for @demoOrderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo order'**
  String get demoOrderDetailTitle;

  /// No description provided for @demoOrderDetailNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get demoOrderDetailNotFoundTitle;

  /// No description provided for @demoOrderDetailNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This demo order is not in your current session history. Confirm a new demo order or return home.'**
  String get demoOrderDetailNotFoundBody;

  /// No description provided for @demoOrderStatusPreparedNotSent.
  ///
  /// In en, this message translates to:
  /// **'Demo prepared — not sent'**
  String get demoOrderStatusPreparedNotSent;

  /// No description provided for @demoOrderStatusLocalOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Status is stored only on this device for the demo. There is no business acceptance, payment, delivery, or booking progress.'**
  String get demoOrderStatusLocalOnlyNote;

  /// No description provided for @demoOrderViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View order history'**
  String get demoOrderViewHistory;

  /// No description provided for @profileDemoOrdersSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No demo orders this session} =1{1 demo order this session} other{{count} demo orders this session}}'**
  String profileDemoOrdersSavedCount(int count);

  /// No description provided for @businessCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Center'**
  String get businessCenterTitle;

  /// No description provided for @profileBusinessCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Business registration and application tracking'**
  String get profileBusinessCenterSubtitle;

  /// No description provided for @businessCenterIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your business (preview)'**
  String get businessCenterIntroTitle;

  /// No description provided for @businessCenterIntroBody.
  ///
  /// In en, this message translates to:
  /// **'This MVP demonstrates how a business owner might prepare a profile. Nothing here is published publicly or saved to a server.'**
  String get businessCenterIntroBody;

  /// No description provided for @businessCenterSessionNotice.
  ///
  /// In en, this message translates to:
  /// **'Drafts exist only in this browser session and disappear after a refresh or restart.'**
  String get businessCenterSessionNotice;

  /// No description provided for @businessCenterYourProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your session drafts'**
  String get businessCenterYourProfilesTitle;

  /// No description provided for @businessCenterEmptyDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'No drafts yet'**
  String get businessCenterEmptyDraftsTitle;

  /// No description provided for @businessCenterEmptyDraftsBody.
  ///
  /// In en, this message translates to:
  /// **'Create a business profile to preview how your listing could look. It stays on this device only.'**
  String get businessCenterEmptyDraftsBody;

  /// No description provided for @businessCenterCreateProfile.
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get businessCenterCreateProfile;

  /// No description provided for @businessCenterSampleSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Example profile'**
  String get businessCenterSampleSectionTitle;

  /// No description provided for @businessCenterSampleSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Read-only fictional demo — not a verified business and not shown to customers in Search or Home.'**
  String get businessCenterSampleSectionBody;

  /// No description provided for @businessProfileSampleBadge.
  ///
  /// In en, this message translates to:
  /// **'Sample demo'**
  String get businessProfileSampleBadge;

  /// No description provided for @businessPlannedSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming in later phases'**
  String get businessPlannedSectionTitle;

  /// No description provided for @businessPlannedSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Planned business capabilities (not available in this MVP):'**
  String get businessPlannedSectionBody;

  /// No description provided for @businessPlannedProducts.
  ///
  /// In en, this message translates to:
  /// **'Products and services management'**
  String get businessPlannedProducts;

  /// No description provided for @businessPlannedAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability and inventory'**
  String get businessPlannedAvailability;

  /// No description provided for @businessPlannedOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders and bookings'**
  String get businessPlannedOrders;

  /// No description provided for @businessPlannedRental.
  ///
  /// In en, this message translates to:
  /// **'Rental scheduling and deposits'**
  String get businessPlannedRental;

  /// No description provided for @businessPlannedStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff and permissions'**
  String get businessPlannedStaff;

  /// No description provided for @businessPlannedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Business analytics'**
  String get businessPlannedAnalytics;

  /// No description provided for @businessSampleRentalName.
  ///
  /// In en, this message translates to:
  /// **'Sample — Perforator and tool rental'**
  String get businessSampleRentalName;

  /// No description provided for @businessSampleRentalDescription.
  ///
  /// In en, this message translates to:
  /// **'Fictional rental shop example for the Business Center demo. No real inventory, prices, or bookings.'**
  String get businessSampleRentalDescription;

  /// No description provided for @businessSampleRentalAddress.
  ///
  /// In en, this message translates to:
  /// **'Demo District, Sample Workshop Lane 3 (not a real address)'**
  String get businessSampleRentalAddress;

  /// No description provided for @businessSampleRentalHours.
  ///
  /// In en, this message translates to:
  /// **'Mon–Sat, 9:00–18:00 (demo hours)'**
  String get businessSampleRentalHours;

  /// No description provided for @businessSampleRentalPhone.
  ///
  /// In en, this message translates to:
  /// **'+998 00 000 00 00 (example)'**
  String get businessSampleRentalPhone;

  /// No description provided for @businessProfileDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get businessProfileDetailTitle;

  /// No description provided for @businessProfileEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get businessProfileEditAction;

  /// No description provided for @businessProfileSampleReadOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a read-only sample profile for demonstration. It is not published and cannot be edited directly.'**
  String get businessProfileSampleReadOnlyNotice;

  /// No description provided for @businessProfileDraftLocalNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a local draft only. Saving does not publish your business or contact customers.'**
  String get businessProfileDraftLocalNotice;

  /// No description provided for @businessProfileCopySampleToDraft.
  ///
  /// In en, this message translates to:
  /// **'Copy example into new draft'**
  String get businessProfileCopySampleToDraft;

  /// No description provided for @businessProfileNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get businessProfileNotFoundTitle;

  /// No description provided for @businessProfileNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This profile is not available in the current session. Return to Business Center and try again.'**
  String get businessProfileNotFoundBody;

  /// No description provided for @businessProfileFormCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New business profile'**
  String get businessProfileFormCreateTitle;

  /// No description provided for @businessProfileFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit business profile'**
  String get businessProfileFormEditTitle;

  /// No description provided for @businessProfileFormLocalSaveNotice.
  ///
  /// In en, this message translates to:
  /// **'Changes are stored locally for this session only — not published online.'**
  String get businessProfileFormLocalSaveNotice;

  /// No description provided for @businessProfileFieldName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessProfileFieldName;

  /// No description provided for @businessProfileFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get businessProfileFieldCategory;

  /// No description provided for @businessProfileFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get businessProfileFieldDescription;

  /// No description provided for @businessProfileFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address or location'**
  String get businessProfileFieldAddress;

  /// No description provided for @businessProfileFieldHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get businessProfileFieldHours;

  /// No description provided for @businessProfileFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get businessProfileFieldPhone;

  /// No description provided for @businessProfileFieldPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Contact phone (optional)'**
  String get businessProfileFieldPhoneOptional;

  /// No description provided for @businessProfileValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a business name'**
  String get businessProfileValidationNameRequired;

  /// No description provided for @businessProfileValidationDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a description'**
  String get businessProfileValidationDescriptionRequired;

  /// No description provided for @businessProfileValidationAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an address or location'**
  String get businessProfileValidationAddressRequired;

  /// No description provided for @businessProfileValidationHoursRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter working hours'**
  String get businessProfileValidationHoursRequired;

  /// No description provided for @businessProfileSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get businessProfileSaveAction;

  /// No description provided for @businessProfileCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get businessProfileCancelAction;

  /// No description provided for @businessOfferingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Products & services'**
  String get businessOfferingsSectionTitle;

  /// No description provided for @businessOfferingAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get businessOfferingAddAction;

  /// No description provided for @businessOfferingsOwnerNotice.
  ///
  /// In en, this message translates to:
  /// **'Local demo catalog for your draft only — not visible to customers in Search or Home.'**
  String get businessOfferingsOwnerNotice;

  /// No description provided for @businessOfferingsSampleNotice.
  ///
  /// In en, this message translates to:
  /// **'Demonstration listings only — not editable and not published.'**
  String get businessOfferingsSampleNotice;

  /// No description provided for @businessOfferingsEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'No offerings yet. Add a product, service, or rental item to preview your catalog.'**
  String get businessOfferingsEmptyOwner;

  /// No description provided for @businessOfferingsEmptySample.
  ///
  /// In en, this message translates to:
  /// **'This sample profile has no demonstration items while samples are disabled.'**
  String get businessOfferingsEmptySample;

  /// No description provided for @businessOfferingKindProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get businessOfferingKindProduct;

  /// No description provided for @businessOfferingKindService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get businessOfferingKindService;

  /// No description provided for @businessOfferingKindRental.
  ///
  /// In en, this message translates to:
  /// **'Rental item'**
  String get businessOfferingKindRental;

  /// No description provided for @businessPricingUnitPerItem.
  ///
  /// In en, this message translates to:
  /// **'per item'**
  String get businessPricingUnitPerItem;

  /// No description provided for @businessPricingUnitPerHour.
  ///
  /// In en, this message translates to:
  /// **'per hour'**
  String get businessPricingUnitPerHour;

  /// No description provided for @businessPricingUnitPerDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get businessPricingUnitPerDay;

  /// No description provided for @businessOfferingNoDemoPrice.
  ///
  /// In en, this message translates to:
  /// **'No demo sample price'**
  String get businessOfferingNoDemoPrice;

  /// No description provided for @businessOfferingDemoPriceLine.
  ///
  /// In en, this message translates to:
  /// **'Demo sample: {amount} ({unit})'**
  String businessOfferingDemoPriceLine(String amount, String unit);

  /// No description provided for @businessOfferingDemoDepositLine.
  ///
  /// In en, this message translates to:
  /// **'Demo deposit (not charged): {amount}'**
  String businessOfferingDemoDepositLine(String amount);

  /// No description provided for @businessOfferingEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit offering'**
  String get businessOfferingEditAction;

  /// No description provided for @businessOfferingDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Remove offering'**
  String get businessOfferingDeleteAction;

  /// No description provided for @businessOfferingDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove offering?'**
  String get businessOfferingDeleteConfirmTitle;

  /// No description provided for @businessOfferingDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Remove this offering from your local draft? This cannot be undone after refresh.'**
  String get businessOfferingDeleteConfirmBody;

  /// No description provided for @businessOfferingDeleteConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get businessOfferingDeleteConfirmYes;

  /// No description provided for @businessOfferingFormCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New offering'**
  String get businessOfferingFormCreateTitle;

  /// No description provided for @businessOfferingFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit offering'**
  String get businessOfferingFormEditTitle;

  /// No description provided for @businessOfferingFormLocalNotice.
  ///
  /// In en, this message translates to:
  /// **'Offerings stay on this device for the session only — not published to customers.'**
  String get businessOfferingFormLocalNotice;

  /// No description provided for @businessOfferingFieldName.
  ///
  /// In en, this message translates to:
  /// **'Offering name'**
  String get businessOfferingFieldName;

  /// No description provided for @businessOfferingFieldKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get businessOfferingFieldKind;

  /// No description provided for @businessOfferingFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get businessOfferingFieldDescription;

  /// No description provided for @businessOfferingFieldPricingUnit.
  ///
  /// In en, this message translates to:
  /// **'Pricing unit'**
  String get businessOfferingFieldPricingUnit;

  /// No description provided for @businessOfferingFieldDemoPriceOptional.
  ///
  /// In en, this message translates to:
  /// **'Demo sample price (UZS, optional)'**
  String get businessOfferingFieldDemoPriceOptional;

  /// No description provided for @businessOfferingFieldDemoDepositOptional.
  ///
  /// In en, this message translates to:
  /// **'Demo deposit (UZS, optional)'**
  String get businessOfferingFieldDemoDepositOptional;

  /// No description provided for @businessOfferingValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an offering name'**
  String get businessOfferingValidationNameRequired;

  /// No description provided for @businessOfferingValidationDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a description'**
  String get businessOfferingValidationDescriptionRequired;

  /// No description provided for @businessOfferingValidationUzsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative whole number in soums'**
  String get businessOfferingValidationUzsInvalid;

  /// No description provided for @businessOfferingSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save offering'**
  String get businessOfferingSaveAction;

  /// No description provided for @businessOfferingProfileNotEditable.
  ///
  /// In en, this message translates to:
  /// **'Offerings can only be managed for your own session drafts.'**
  String get businessOfferingProfileNotEditable;

  /// No description provided for @businessOfferingNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This offering was not found or does not belong to this profile.'**
  String get businessOfferingNotFoundBody;

  /// No description provided for @businessSampleOfferingPerforatorName.
  ///
  /// In en, this message translates to:
  /// **'Sample — perforator (rental demo)'**
  String get businessSampleOfferingPerforatorName;

  /// No description provided for @businessSampleOfferingPerforatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Fictional tool rental listing for demonstration. No calendar, availability, or real deposit.'**
  String get businessSampleOfferingPerforatorDesc;

  /// No description provided for @businessInventorySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory & availability'**
  String get businessInventorySummaryTitle;

  /// No description provided for @businessInventorySummaryCounts.
  ///
  /// In en, this message translates to:
  /// **'Configured {configured} of {total} offerings · Active {active} · Paused {paused}'**
  String businessInventorySummaryCounts(
    int configured,
    int total,
    int active,
    int paused,
  );

  /// No description provided for @businessInventorySummaryNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo quantities and pause flags are manual and local — not synced to customers or reservations.'**
  String get businessInventorySummaryNotice;

  /// No description provided for @businessInventoryManageAction.
  ///
  /// In en, this message translates to:
  /// **'Manage inventory & availability'**
  String get businessInventoryManageAction;

  /// No description provided for @businessInventoryPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory & availability'**
  String get businessInventoryPageTitle;

  /// No description provided for @businessInventoryPageIntro.
  ///
  /// In en, this message translates to:
  /// **'Set demo stock or pause flags for your session offerings. This is not a live reservation system.'**
  String get businessInventoryPageIntro;

  /// No description provided for @businessInventoryProfileNotEditable.
  ///
  /// In en, this message translates to:
  /// **'Inventory can only be managed for your own session drafts.'**
  String get businessInventoryProfileNotEditable;

  /// No description provided for @businessInventoryNoOfferingsTitle.
  ///
  /// In en, this message translates to:
  /// **'No offerings yet'**
  String get businessInventoryNoOfferingsTitle;

  /// No description provided for @businessInventoryNoOfferingsBody.
  ///
  /// In en, this message translates to:
  /// **'Add products, services, or rental items on the profile page before configuring inventory.'**
  String get businessInventoryNoOfferingsBody;

  /// No description provided for @businessInventoryBackToProfile.
  ///
  /// In en, this message translates to:
  /// **'Back to profile'**
  String get businessInventoryBackToProfile;

  /// No description provided for @businessInventoryNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get businessInventoryNotConfigured;

  /// No description provided for @businessInventoryStateActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get businessInventoryStateActive;

  /// No description provided for @businessInventoryStatePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get businessInventoryStatePaused;

  /// No description provided for @businessInventoryServiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {state} (demo — no appointment schedule)'**
  String businessInventoryServiceStatus(String state);

  /// No description provided for @businessInventoryProductStock.
  ///
  /// In en, this message translates to:
  /// **'{available} available of {total} · {state}'**
  String businessInventoryProductStock(int available, int total, String state);

  /// No description provided for @businessInventoryRentalUnits.
  ///
  /// In en, this message translates to:
  /// **'{available} available of {total} units · {state} (manual demo count)'**
  String businessInventoryRentalUnits(int available, int total, String state);

  /// No description provided for @businessInventoryConfigureAction.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get businessInventoryConfigureAction;

  /// No description provided for @businessInventoryEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit inventory'**
  String get businessInventoryEditAction;

  /// No description provided for @businessInventoryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit inventory'**
  String get businessInventoryEditTitle;

  /// No description provided for @businessInventoryLocalNotice.
  ///
  /// In en, this message translates to:
  /// **'Local demo settings only — not published to the consumer app.'**
  String get businessInventoryLocalNotice;

  /// No description provided for @businessInventoryRentalManualNotice.
  ///
  /// In en, this message translates to:
  /// **'Available units are entered manually for demo. Reservations and returns do not update this count automatically.'**
  String get businessInventoryRentalManualNotice;

  /// No description provided for @businessInventoryAvailabilityToggle.
  ///
  /// In en, this message translates to:
  /// **'Offering active'**
  String get businessInventoryAvailabilityToggle;

  /// No description provided for @businessInventoryFieldStockTotal.
  ///
  /// In en, this message translates to:
  /// **'Total stock (units)'**
  String get businessInventoryFieldStockTotal;

  /// No description provided for @businessInventoryFieldStockAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available stock (units)'**
  String get businessInventoryFieldStockAvailable;

  /// No description provided for @businessInventoryFieldTotalUnits.
  ///
  /// In en, this message translates to:
  /// **'Total equipment units'**
  String get businessInventoryFieldTotalUnits;

  /// No description provided for @businessInventoryFieldAvailableUnits.
  ///
  /// In en, this message translates to:
  /// **'Available units now'**
  String get businessInventoryFieldAvailableUnits;

  /// No description provided for @businessInventoryValidationQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity'**
  String get businessInventoryValidationQuantityRequired;

  /// No description provided for @businessInventoryValidationQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative whole number'**
  String get businessInventoryValidationQuantityInvalid;

  /// No description provided for @businessInventoryValidationAvailableExceedsTotal.
  ///
  /// In en, this message translates to:
  /// **'Available quantity cannot exceed total'**
  String get businessInventoryValidationAvailableExceedsTotal;

  /// No description provided for @businessInventorySaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save inventory'**
  String get businessInventorySaveAction;

  /// No description provided for @authSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInAction;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTitle;

  /// No description provided for @authSignOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOutAction;

  /// No description provided for @authPhonePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number in international format. We will send a one-time code when sign-in is available.'**
  String get authPhonePrompt;

  /// No description provided for @authPhoneFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhoneFieldLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+998901234567'**
  String get authPhoneHint;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid international phone number, for example +998901234567.'**
  String get authPhoneInvalid;

  /// No description provided for @authRequestOtpAction.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authRequestOtpAction;

  /// No description provided for @authOtpPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your phone when delivery is configured.'**
  String get authOtpPrompt;

  /// No description provided for @authOtpFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authOtpFieldLabel;

  /// No description provided for @authVerifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerifyAction;

  /// No description provided for @authChangePhoneAction.
  ///
  /// In en, this message translates to:
  /// **'Use a different number'**
  String get authChangePhoneAction;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @authApiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Sign-in server is not configured for this build. Set QOSHNI_API_BASE_URL at compile time.'**
  String get authApiNotConfigured;

  /// No description provided for @authErrorServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is temporarily unavailable. SMS delivery may not be configured yet.'**
  String get authErrorServiceUnavailable;

  /// No description provided for @authErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and try again.'**
  String get authErrorRateLimited;

  /// No description provided for @authErrorCodeIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect verification code.'**
  String get authErrorCodeIncorrect;

  /// No description provided for @authErrorChallengeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Request a new one.'**
  String get authErrorChallengeExpired;

  /// No description provided for @authErrorChallengeLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts. Request a new code.'**
  String get authErrorChallengeLocked;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed. Check your connection and try again.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @authSignedInTitle.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get authSignedInTitle;

  /// No description provided for @authSignedInBody.
  ///
  /// In en, this message translates to:
  /// **'Your phone identity is verified for this session.'**
  String get authSignedInBody;

  /// No description provided for @authSessionsAction.
  ///
  /// In en, this message translates to:
  /// **'Manage sessions'**
  String get authSessionsAction;

  /// No description provided for @authSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your sessions'**
  String get authSessionsTitle;

  /// No description provided for @authSessionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions to show.'**
  String get authSessionsEmpty;

  /// No description provided for @authSessionUnknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get authSessionUnknownDevice;

  /// No description provided for @authSessionStateActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get authSessionStateActive;

  /// No description provided for @authSessionStateExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get authSessionStateExpired;

  /// No description provided for @authSessionStateRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get authSessionStateRevoked;

  /// No description provided for @authSessionCurrentBadge.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get authSessionCurrentBadge;

  /// No description provided for @authSessionExpiredNotice.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. You can sign in again when the service is available.'**
  String get authSessionExpiredNotice;

  /// No description provided for @userProfileDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get userProfileDisplayNameHint;

  /// No description provided for @userProfileDisplayNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'No display name yet'**
  String get userProfileDisplayNameEmpty;

  /// No description provided for @userProfileEditDisplayNameAction.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get userProfileEditDisplayNameAction;

  /// No description provided for @userProfileClearDisplayNameAction.
  ///
  /// In en, this message translates to:
  /// **'Clear display name'**
  String get userProfileClearDisplayNameAction;

  /// No description provided for @userProfileSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get userProfileSaveAction;

  /// No description provided for @userProfileCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get userProfileCancelAction;

  /// No description provided for @userProfileRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get userProfileRetryAction;

  /// No description provided for @userProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.'**
  String get userProfileLoadError;

  /// No description provided for @userProfileSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get userProfileSaveSuccess;

  /// No description provided for @userProfilePreferencesSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved.'**
  String get userProfilePreferencesSaveSuccess;

  /// No description provided for @userProfileApiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Account server is not configured for this build. Set QOSHNI_API_BASE_URL at compile time.'**
  String get userProfileApiNotConfigured;

  /// No description provided for @userProfileErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed. Check your connection and try again.'**
  String get userProfileErrorNetwork;

  /// No description provided for @userProfileErrorServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile service is temporarily unavailable.'**
  String get userProfileErrorServiceUnavailable;

  /// No description provided for @userProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Your profile is not available yet. Try again or sign in again.'**
  String get userProfileNotFound;

  /// No description provided for @userProfilePreferencesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Your preferences are not available yet. Try again or sign in again.'**
  String get userProfilePreferencesNotFound;

  /// No description provided for @userProfileErrorValidation.
  ///
  /// In en, this message translates to:
  /// **'That value is not allowed. Check the display name or language and try again.'**
  String get userProfileErrorValidation;

  /// No description provided for @userProfileErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get userProfileErrorGeneric;

  /// No description provided for @userProfileSectionPersonalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get userProfileSectionPersonalization;

  /// No description provided for @userProfilePersonalizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized suggestions'**
  String get userProfilePersonalizationTitle;

  /// No description provided for @userProfilePersonalizationBody.
  ///
  /// In en, this message translates to:
  /// **'When enabled, QO‘SHNI may use your explicit preferences to tailor suggestions. This stays off until you turn it on.'**
  String get userProfilePersonalizationBody;

  /// No description provided for @userProfileSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get userProfileSaving;

  /// No description provided for @businessCenterOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Business registration'**
  String get businessCenterOnboardingTitle;

  /// No description provided for @businessCenterOnboardingBody.
  ///
  /// In en, this message translates to:
  /// **'Submit a verification application, upload documents, and track review status with your signed-in account.'**
  String get businessCenterOnboardingBody;

  /// No description provided for @businessCenterOnboardingAction.
  ///
  /// In en, this message translates to:
  /// **'Open registration'**
  String get businessCenterOnboardingAction;

  /// No description provided for @onboardingHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Business registration'**
  String get onboardingHubTitle;

  /// No description provided for @onboardingHubIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Register your business'**
  String get onboardingHubIntroTitle;

  /// No description provided for @onboardingHubIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Create an application, complete the form, upload required documents, and submit for review. Status updates come from the server.'**
  String get onboardingHubIntroBody;

  /// No description provided for @onboardingHubEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get onboardingHubEmptyTitle;

  /// No description provided for @onboardingHubEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start a new application to register your business for verification.'**
  String get onboardingHubEmptyBody;

  /// No description provided for @onboardingCreateApplication.
  ///
  /// In en, this message translates to:
  /// **'New application'**
  String get onboardingCreateApplication;

  /// No description provided for @onboardingUntitledApplication.
  ///
  /// In en, this message translates to:
  /// **'Untitled application'**
  String get onboardingUntitledApplication;

  /// No description provided for @onboardingSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view and manage your business registration applications.'**
  String get onboardingSignInPrompt;

  /// No description provided for @onboardingApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get onboardingApplicationTitle;

  /// No description provided for @onboardingTabForm.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get onboardingTabForm;

  /// No description provided for @onboardingTabDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get onboardingTabDocuments;

  /// No description provided for @onboardingTabStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get onboardingTabStatus;

  /// No description provided for @onboardingFormReadOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'This application is no longer a draft. Details are read-only while review is in progress or complete.'**
  String get onboardingFormReadOnlyNotice;

  /// No description provided for @onboardingFieldLegalName.
  ///
  /// In en, this message translates to:
  /// **'Legal business name'**
  String get onboardingFieldLegalName;

  /// No description provided for @onboardingFieldTradeName.
  ///
  /// In en, this message translates to:
  /// **'Trade / display name (optional)'**
  String get onboardingFieldTradeName;

  /// No description provided for @onboardingFieldServiceCategory.
  ///
  /// In en, this message translates to:
  /// **'Service category'**
  String get onboardingFieldServiceCategory;

  /// No description provided for @onboardingFieldJurisdiction.
  ///
  /// In en, this message translates to:
  /// **'Registration jurisdiction (ISO code)'**
  String get onboardingFieldJurisdiction;

  /// No description provided for @onboardingFieldRegistrationId.
  ///
  /// In en, this message translates to:
  /// **'Registration identifier (optional)'**
  String get onboardingFieldRegistrationId;

  /// No description provided for @onboardingFieldTaxIdOptional.
  ///
  /// In en, this message translates to:
  /// **'Tax identifier (optional)'**
  String get onboardingFieldTaxIdOptional;

  /// No description provided for @onboardingFieldContactEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Business contact email (optional)'**
  String get onboardingFieldContactEmailOptional;

  /// No description provided for @onboardingValidationLegalNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the legal business name'**
  String get onboardingValidationLegalNameRequired;

  /// No description provided for @onboardingValidationCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a service category'**
  String get onboardingValidationCategoryRequired;

  /// No description provided for @onboardingValidationJurisdictionInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a two-letter jurisdiction code (e.g. UZ)'**
  String get onboardingValidationJurisdictionInvalid;

  /// No description provided for @onboardingValidationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get onboardingValidationEmailInvalid;

  /// No description provided for @onboardingSaveDraftAction.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get onboardingSaveDraftAction;

  /// No description provided for @onboardingSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get onboardingSubmitAction;

  /// No description provided for @onboardingDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get onboardingDraftSaved;

  /// No description provided for @onboardingSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Application submitted for review.'**
  String get onboardingSubmitSuccess;

  /// No description provided for @onboardingCategoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get onboardingCategoryGroceries;

  /// No description provided for @onboardingCategoryRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get onboardingCategoryRestaurants;

  /// No description provided for @onboardingCategoryPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get onboardingCategoryPharmacy;

  /// No description provided for @onboardingCategoryShops.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get onboardingCategoryShops;

  /// No description provided for @onboardingCategoryMasters.
  ///
  /// In en, this message translates to:
  /// **'Masters & services'**
  String get onboardingCategoryMasters;

  /// No description provided for @onboardingCategoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get onboardingCategoryRent;

  /// No description provided for @onboardingDocumentsIntro.
  ///
  /// In en, this message translates to:
  /// **'Register each document type, then upload PDF, JPEG, or PNG files up to 10 MiB.'**
  String get onboardingDocumentsIntro;

  /// No description provided for @onboardingDocumentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No documents registered yet. Add a document type below.'**
  String get onboardingDocumentsEmpty;

  /// No description provided for @onboardingRegisterDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get onboardingRegisterDocumentTitle;

  /// No description provided for @onboardingUploadAction.
  ///
  /// In en, this message translates to:
  /// **'Choose file & upload'**
  String get onboardingUploadAction;

  /// No description provided for @onboardingUploadTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is larger than 10 MiB. Choose a smaller file.'**
  String get onboardingUploadTooLarge;

  /// No description provided for @onboardingUploadReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get onboardingUploadReadFailed;

  /// No description provided for @onboardingUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Upload completed.'**
  String get onboardingUploadSuccess;

  /// No description provided for @onboardingDocTypeRegistrationCertificate.
  ///
  /// In en, this message translates to:
  /// **'Registration certificate'**
  String get onboardingDocTypeRegistrationCertificate;

  /// No description provided for @onboardingDocTypeTaxRegistration.
  ///
  /// In en, this message translates to:
  /// **'Tax registration'**
  String get onboardingDocTypeTaxRegistration;

  /// No description provided for @onboardingDocTypeRepresentativeId.
  ///
  /// In en, this message translates to:
  /// **'Authorized representative ID'**
  String get onboardingDocTypeRepresentativeId;

  /// No description provided for @onboardingDocTypeOtherSupporting.
  ///
  /// In en, this message translates to:
  /// **'Other supporting document'**
  String get onboardingDocTypeOtherSupporting;

  /// No description provided for @onboardingVerificationCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get onboardingVerificationCurrentStatus;

  /// No description provided for @onboardingVerificationSubmittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get onboardingVerificationSubmittedAt;

  /// No description provided for @onboardingVerificationReviewedAt.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get onboardingVerificationReviewedAt;

  /// No description provided for @onboardingVerificationRejectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get onboardingVerificationRejectionTitle;

  /// No description provided for @onboardingNextStepsDraft.
  ///
  /// In en, this message translates to:
  /// **'Complete the form, upload documents, then submit when ready.'**
  String get onboardingNextStepsDraft;

  /// No description provided for @onboardingNextStepsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your application was submitted. You will be notified when review starts.'**
  String get onboardingNextStepsSubmitted;

  /// No description provided for @onboardingNextStepsUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Our team is reviewing your application. You may be asked for additional documents.'**
  String get onboardingNextStepsUnderReview;

  /// No description provided for @onboardingNextStepsVerified.
  ///
  /// In en, this message translates to:
  /// **'Your business is verified. Further product features will arrive in later phases.'**
  String get onboardingNextStepsVerified;

  /// No description provided for @onboardingNextStepsRejected.
  ///
  /// In en, this message translates to:
  /// **'Your application was rejected. Review the reason, update your draft if allowed, or contact support.'**
  String get onboardingNextStepsRejected;

  /// No description provided for @onboardingNextStepsSuspended.
  ///
  /// In en, this message translates to:
  /// **'Your application is suspended. Contact support for next steps.'**
  String get onboardingNextStepsSuspended;

  /// No description provided for @onboardingNextStepsGeneric.
  ///
  /// In en, this message translates to:
  /// **'Check back later for updates.'**
  String get onboardingNextStepsGeneric;

  /// No description provided for @onboardingErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Application not found.'**
  String get onboardingErrorNotFound;

  /// No description provided for @onboardingErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this application.'**
  String get onboardingErrorForbidden;

  /// No description provided for @onboardingErrorInvalidTransition.
  ///
  /// In en, this message translates to:
  /// **'This action is not allowed for the current status.'**
  String get onboardingErrorInvalidTransition;

  /// No description provided for @onboardingErrorValidation.
  ///
  /// In en, this message translates to:
  /// **'Some fields are invalid. Check the form and try again.'**
  String get onboardingErrorValidation;

  /// No description provided for @onboardingErrorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service temporarily unavailable. Try again later.'**
  String get onboardingErrorUnavailable;

  /// No description provided for @onboardingErrorScanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Document scanning is temporarily unavailable.'**
  String get onboardingErrorScanUnavailable;

  /// No description provided for @onboardingErrorDocumentRejected.
  ///
  /// In en, this message translates to:
  /// **'The document was rejected. Register a new document and upload again.'**
  String get onboardingErrorDocumentRejected;

  /// No description provided for @onboardingErrorSuspended.
  ///
  /// In en, this message translates to:
  /// **'This application is suspended.'**
  String get onboardingErrorSuspended;

  /// No description provided for @onboardingErrorSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get onboardingErrorSignInRequired;

  /// No description provided for @onboardingErrorApiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Registration server is not configured for this build. Set QOSHNI_API_BASE_URL at compile time.'**
  String get onboardingErrorApiNotConfigured;

  /// No description provided for @onboardingErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed. Check your connection and try again.'**
  String get onboardingErrorNetwork;

  /// No description provided for @onboardingErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get onboardingErrorUnexpected;

  /// No description provided for @onboardingStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get onboardingStatusDraft;

  /// No description provided for @onboardingStatusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get onboardingStatusSubmitted;

  /// No description provided for @onboardingStatusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get onboardingStatusUnderReview;

  /// No description provided for @onboardingStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get onboardingStatusVerified;

  /// No description provided for @onboardingStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get onboardingStatusRejected;

  /// No description provided for @onboardingStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get onboardingStatusSuspended;

  /// No description provided for @onboardingDocAwaitingUpload.
  ///
  /// In en, this message translates to:
  /// **'Awaiting upload'**
  String get onboardingDocAwaitingUpload;

  /// No description provided for @onboardingDocUploadedPending.
  ///
  /// In en, this message translates to:
  /// **'Uploaded — pending validation'**
  String get onboardingDocUploadedPending;

  /// No description provided for @onboardingDocQuarantined.
  ///
  /// In en, this message translates to:
  /// **'Quarantined'**
  String get onboardingDocQuarantined;

  /// No description provided for @onboardingDocRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get onboardingDocRejected;

  /// No description provided for @onboardingDocAcceptedForReview.
  ///
  /// In en, this message translates to:
  /// **'Accepted for review'**
  String get onboardingDocAcceptedForReview;

  /// No description provided for @onboardingDocDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get onboardingDocDeleted;

  /// No description provided for @onboardingRejectionIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete information'**
  String get onboardingRejectionIncomplete;

  /// No description provided for @onboardingRejectionMismatch.
  ///
  /// In en, this message translates to:
  /// **'Registration mismatch'**
  String get onboardingRejectionMismatch;

  /// No description provided for @onboardingRejectionJurisdiction.
  ///
  /// In en, this message translates to:
  /// **'Unsupported jurisdiction'**
  String get onboardingRejectionJurisdiction;

  /// No description provided for @onboardingRejectionPolicy.
  ///
  /// In en, this message translates to:
  /// **'Policy violation'**
  String get onboardingRejectionPolicy;

  /// No description provided for @onboardingRejectionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get onboardingRejectionOther;

  /// No description provided for @businessCenterOwnerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get businessCenterOwnerProfileTitle;

  /// No description provided for @businessCenterOwnerProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Preview your business-level profile. Saved only in this session until backend sync arrives.'**
  String get businessCenterOwnerProfileBody;

  /// No description provided for @ownerProfileOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get ownerProfileOverviewTitle;

  /// No description provided for @ownerProfilePreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview — saved only in this session. Not published or verified.'**
  String get ownerProfilePreviewNotice;

  /// No description provided for @ownerProfileStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile status'**
  String get ownerProfileStatusLabel;

  /// No description provided for @ownerProfileStatusPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview draft'**
  String get ownerProfileStatusPreview;

  /// No description provided for @ownerProfileCompletenessLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile completeness'**
  String get ownerProfileCompletenessLabel;

  /// No description provided for @ownerProfileEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get ownerProfileEditAction;

  /// No description provided for @ownerProfileViewAction.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get ownerProfileViewAction;

  /// No description provided for @ownerProfileSectionBasics.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get ownerProfileSectionBasics;

  /// No description provided for @ownerProfileSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get ownerProfileSectionContact;

  /// No description provided for @ownerProfileSectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Preview settings'**
  String get ownerProfileSectionSettings;

  /// No description provided for @ownerProfileLegalName.
  ///
  /// In en, this message translates to:
  /// **'Legal business name'**
  String get ownerProfileLegalName;

  /// No description provided for @ownerProfileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get ownerProfileDisplayName;

  /// No description provided for @ownerProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Business description'**
  String get ownerProfileDescription;

  /// No description provided for @ownerProfileCategory.
  ///
  /// In en, this message translates to:
  /// **'Service category'**
  String get ownerProfileCategory;

  /// No description provided for @ownerProfileContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get ownerProfileContactPhone;

  /// No description provided for @ownerProfileContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact email'**
  String get ownerProfileContactEmail;

  /// No description provided for @ownerProfileWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website (preview)'**
  String get ownerProfileWebsite;

  /// No description provided for @ownerProfileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile visibility (preview)'**
  String get ownerProfileVisibility;

  /// No description provided for @ownerProfileVisibilityHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden in preview'**
  String get ownerProfileVisibilityHidden;

  /// No description provided for @ownerProfileVisibilityVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible in preview UI only'**
  String get ownerProfileVisibilityVisible;

  /// No description provided for @ownerProfileEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit business profile'**
  String get ownerProfileEditorTitle;

  /// No description provided for @ownerProfileSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get ownerProfileSaveAction;

  /// No description provided for @ownerProfileCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ownerProfileCancelAction;

  /// No description provided for @ownerProfileSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved for this session.'**
  String get ownerProfileSaveSuccess;

  /// No description provided for @ownerProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your edits are still in the form.'**
  String get ownerProfileSaveFailed;

  /// No description provided for @ownerProfileDiscardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get ownerProfileDiscardConfirmTitle;

  /// No description provided for @ownerProfileDiscardConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Unsaved edits will be lost.'**
  String get ownerProfileDiscardConfirmBody;

  /// No description provided for @ownerProfileDiscardConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get ownerProfileDiscardConfirmAction;

  /// No description provided for @ownerProfileValidationLegalName.
  ///
  /// In en, this message translates to:
  /// **'Enter the legal business name'**
  String get ownerProfileValidationLegalName;

  /// No description provided for @ownerProfileValidationDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter a display name'**
  String get ownerProfileValidationDisplayName;

  /// No description provided for @ownerProfileValidationDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a business description'**
  String get ownerProfileValidationDescription;

  /// No description provided for @ownerProfileValidationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get ownerProfileValidationEmail;

  /// No description provided for @ownerProfileValidationWebsite.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid website URL'**
  String get ownerProfileValidationWebsite;

  /// No description provided for @businessCenterBranchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get businessCenterBranchesTitle;

  /// No description provided for @businessCenterBranchesBody.
  ///
  /// In en, this message translates to:
  /// **'Manage branch locations, hours, and contacts in preview mode.'**
  String get businessCenterBranchesBody;

  /// No description provided for @branchListTitle.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branchListTitle;

  /// No description provided for @branchPreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview — branches are saved only in this session. Not published to search or maps.'**
  String get branchPreviewNotice;

  /// No description provided for @branchProfileIncompleteNotice.
  ///
  /// In en, this message translates to:
  /// **'Complete your business profile preview before branches can sync to a real business later.'**
  String get branchProfileIncompleteNotice;

  /// No description provided for @branchOpenBusinessProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Open business profile'**
  String get branchOpenBusinessProfileAction;

  /// No description provided for @branchAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add branch'**
  String get branchAddAction;

  /// No description provided for @branchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No branches yet'**
  String get branchEmptyTitle;

  /// No description provided for @branchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a preview branch to plan locations and opening hours.'**
  String get branchEmptyBody;

  /// No description provided for @branchStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get branchStatusActive;

  /// No description provided for @branchStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get branchStatusInactive;

  /// No description provided for @branchScheduleClosedAllWeek.
  ///
  /// In en, this message translates to:
  /// **'Closed all week'**
  String get branchScheduleClosedAllWeek;

  /// No description provided for @branchDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch details'**
  String get branchDetailTitle;

  /// No description provided for @branchEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit branch'**
  String get branchEditAction;

  /// No description provided for @branchNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch not found'**
  String get branchNotFoundTitle;

  /// No description provided for @branchNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This branch is not in your session preview.'**
  String get branchNotFoundBody;

  /// No description provided for @branchBackToListAction.
  ///
  /// In en, this message translates to:
  /// **'Back to branches'**
  String get branchBackToListAction;

  /// No description provided for @branchSectionBasics.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get branchSectionBasics;

  /// No description provided for @branchSectionHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get branchSectionHours;

  /// No description provided for @branchSectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location (preview)'**
  String get branchSectionLocation;

  /// No description provided for @branchFieldName.
  ///
  /// In en, this message translates to:
  /// **'Branch name'**
  String get branchFieldName;

  /// No description provided for @branchFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get branchFieldCity;

  /// No description provided for @branchFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get branchFieldAddress;

  /// No description provided for @branchFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get branchFieldPhone;

  /// No description provided for @branchFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Branch status'**
  String get branchFieldStatus;

  /// No description provided for @branchFieldOpenTime.
  ///
  /// In en, this message translates to:
  /// **'Opens'**
  String get branchFieldOpenTime;

  /// No description provided for @branchFieldCloseTime.
  ///
  /// In en, this message translates to:
  /// **'Closes'**
  String get branchFieldCloseTime;

  /// No description provided for @branchFieldLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude (demo)'**
  String get branchFieldLatitude;

  /// No description provided for @branchFieldLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude (demo)'**
  String get branchFieldLongitude;

  /// No description provided for @branchDayClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get branchDayClosed;

  /// No description provided for @branchLocationDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Demo coordinates only — no map or geocoding in this phase.'**
  String get branchLocationDemoHint;

  /// No description provided for @branchEditorCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New branch'**
  String get branchEditorCreateTitle;

  /// No description provided for @branchEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit branch'**
  String get branchEditorEditTitle;

  /// No description provided for @branchSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save branch'**
  String get branchSaveAction;

  /// No description provided for @branchCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get branchCancelAction;

  /// No description provided for @branchSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Branch saved for this session.'**
  String get branchSaveSuccess;

  /// No description provided for @branchSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your edits are still in the form.'**
  String get branchSaveFailed;

  /// No description provided for @branchDiscardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get branchDiscardConfirmTitle;

  /// No description provided for @branchDiscardConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Unsaved branch edits will be lost.'**
  String get branchDiscardConfirmBody;

  /// No description provided for @branchDiscardConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get branchDiscardConfirmAction;

  /// No description provided for @branchValidationName.
  ///
  /// In en, this message translates to:
  /// **'Enter a branch name'**
  String get branchValidationName;

  /// No description provided for @branchValidationCity.
  ///
  /// In en, this message translates to:
  /// **'Enter a city'**
  String get branchValidationCity;

  /// No description provided for @branchValidationAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter an address'**
  String get branchValidationAddress;

  /// No description provided for @branchValidationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get branchValidationPhone;

  /// No description provided for @branchValidationTime.
  ///
  /// In en, this message translates to:
  /// **'Use HH:MM format for opening hours'**
  String get branchValidationTime;

  /// No description provided for @branchValidationTimeOrder.
  ///
  /// In en, this message translates to:
  /// **'Closing time must be after opening time'**
  String get branchValidationTimeOrder;

  /// No description provided for @branchValidationCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Enter valid coordinates'**
  String get branchValidationCoordinates;

  /// No description provided for @branchWeekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get branchWeekdayMonday;

  /// No description provided for @branchWeekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get branchWeekdayTuesday;

  /// No description provided for @branchWeekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get branchWeekdayWednesday;

  /// No description provided for @branchWeekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get branchWeekdayThursday;

  /// No description provided for @branchWeekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get branchWeekdayFriday;

  /// No description provided for @branchWeekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get branchWeekdaySaturday;

  /// No description provided for @branchWeekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get branchWeekdaySunday;

  /// No description provided for @businessCenterStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff & roles'**
  String get businessCenterStaffTitle;

  /// No description provided for @businessCenterStaffBody.
  ///
  /// In en, this message translates to:
  /// **'Preview team members, roles, and branch access for this session only.'**
  String get businessCenterStaffBody;

  /// No description provided for @staffListTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff & roles'**
  String get staffListTitle;

  /// No description provided for @staffPreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview — no SMS, email, or real invites. Saved only in this session.'**
  String get staffPreviewNotice;

  /// No description provided for @staffAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add staff member'**
  String get staffAddAction;

  /// No description provided for @staffEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No staff yet'**
  String get staffEmptyTitle;

  /// No description provided for @staffEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a preview team member and assign branches.'**
  String get staffEmptyBody;

  /// No description provided for @staffEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get staffEditAction;

  /// No description provided for @staffDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff member'**
  String get staffDetailTitle;

  /// No description provided for @staffNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff member not found'**
  String get staffNotFoundTitle;

  /// No description provided for @staffNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This preview staff member is not in your session.'**
  String get staffNotFoundBody;

  /// No description provided for @staffBackToListAction.
  ///
  /// In en, this message translates to:
  /// **'Back to staff list'**
  String get staffBackToListAction;

  /// No description provided for @staffSectionBasics.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get staffSectionBasics;

  /// No description provided for @staffSectionRole.
  ///
  /// In en, this message translates to:
  /// **'Business role'**
  String get staffSectionRole;

  /// No description provided for @staffSectionBranches.
  ///
  /// In en, this message translates to:
  /// **'Assigned branches'**
  String get staffSectionBranches;

  /// No description provided for @staffFieldFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get staffFieldFirstName;

  /// No description provided for @staffFieldLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get staffFieldLastName;

  /// No description provided for @staffFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get staffFieldPhone;

  /// No description provided for @staffFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get staffFieldEmail;

  /// No description provided for @staffFieldEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get staffFieldEmailOptional;

  /// No description provided for @staffFieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffFieldRole;

  /// No description provided for @staffFieldActive.
  ///
  /// In en, this message translates to:
  /// **'Active in preview'**
  String get staffFieldActive;

  /// No description provided for @staffFieldActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Inactive marks the member as removed in preview only.'**
  String get staffFieldActiveHint;

  /// No description provided for @staffBranchSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Select at least one branch. Permissions apply only to assigned branches.'**
  String get staffBranchSelectionHint;

  /// No description provided for @staffNoBranchesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Add a preview branch before assigning staff.'**
  String get staffNoBranchesAvailable;

  /// No description provided for @staffEditorCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New staff member'**
  String get staffEditorCreateTitle;

  /// No description provided for @staffEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit staff member'**
  String get staffEditorEditTitle;

  /// No description provided for @staffSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save staff member'**
  String get staffSaveAction;

  /// No description provided for @staffCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get staffCancelAction;

  /// No description provided for @staffSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Staff member saved for this session.'**
  String get staffSaveSuccess;

  /// No description provided for @staffSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your edits are still in the form.'**
  String get staffSaveFailed;

  /// No description provided for @staffDiscardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get staffDiscardConfirmTitle;

  /// No description provided for @staffDiscardConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Unsaved staff edits will be lost.'**
  String get staffDiscardConfirmBody;

  /// No description provided for @staffDiscardConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get staffDiscardConfirmAction;

  /// No description provided for @staffValidationFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter a first name'**
  String get staffValidationFirstName;

  /// No description provided for @staffValidationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get staffValidationPhone;

  /// No description provided for @staffValidationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get staffValidationEmail;

  /// No description provided for @staffValidationRoleNotAssignable.
  ///
  /// In en, this message translates to:
  /// **'This role cannot be assigned here.'**
  String get staffValidationRoleNotAssignable;

  /// No description provided for @staffValidationBranchRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one branch.'**
  String get staffValidationBranchRequired;

  /// No description provided for @staffInvalidScopeMessage.
  ///
  /// In en, this message translates to:
  /// **'One or more branches are not available in this preview scope.'**
  String get staffInvalidScopeMessage;

  /// No description provided for @staffOwnerNotEditableMessage.
  ///
  /// In en, this message translates to:
  /// **'The preview business owner cannot be edited from this form.'**
  String get staffOwnerNotEditableMessage;

  /// No description provided for @staffRoleBusinessOwner.
  ///
  /// In en, this message translates to:
  /// **'Business owner'**
  String get staffRoleBusinessOwner;

  /// No description provided for @staffRoleBusinessAdmin.
  ///
  /// In en, this message translates to:
  /// **'Business admin'**
  String get staffRoleBusinessAdmin;

  /// No description provided for @staffRoleBranchManager.
  ///
  /// In en, this message translates to:
  /// **'Branch manager'**
  String get staffRoleBranchManager;

  /// No description provided for @staffRoleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffRoleStaff;

  /// No description provided for @staffRoleReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get staffRoleReadOnly;

  /// No description provided for @staffStatusActivePreview.
  ///
  /// In en, this message translates to:
  /// **'Active (preview)'**
  String get staffStatusActivePreview;

  /// No description provided for @staffStatusInvitePendingPreview.
  ///
  /// In en, this message translates to:
  /// **'Invite pending (preview only)'**
  String get staffStatusInvitePendingPreview;

  /// No description provided for @staffStatusRemovedPreview.
  ///
  /// In en, this message translates to:
  /// **'Removed (preview)'**
  String get staffStatusRemovedPreview;

  /// No description provided for @staffBranchesLabel.
  ///
  /// In en, this message translates to:
  /// **'Branches: {names}'**
  String staffBranchesLabel(String names);

  /// No description provided for @staffPermissionPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission preview'**
  String get staffPermissionPreviewTitle;

  /// No description provided for @staffPermissionPreviewDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Demo UI only — backend authorization is not connected yet.'**
  String get staffPermissionPreviewDisclaimer;

  /// No description provided for @staffPermSummaryOwner.
  ///
  /// In en, this message translates to:
  /// **'Full business control in preview (not assignable to new staff).'**
  String get staffPermSummaryOwner;

  /// No description provided for @staffPermSummaryAdmin.
  ///
  /// In en, this message translates to:
  /// **'Manage branches and staff across the business preview.'**
  String get staffPermSummaryAdmin;

  /// No description provided for @staffPermSummaryBranchManager.
  ///
  /// In en, this message translates to:
  /// **'Operate within assigned branches only.'**
  String get staffPermSummaryBranchManager;

  /// No description provided for @staffPermSummaryStaff.
  ///
  /// In en, this message translates to:
  /// **'Day-to-day tasks within assigned branches.'**
  String get staffPermSummaryStaff;

  /// No description provided for @staffPermSummaryReadOnly.
  ///
  /// In en, this message translates to:
  /// **'View preview data without editing.'**
  String get staffPermSummaryReadOnly;

  /// No description provided for @staffPermManageBusiness.
  ///
  /// In en, this message translates to:
  /// **'Manage business preview settings'**
  String get staffPermManageBusiness;

  /// No description provided for @staffPermManageBranches.
  ///
  /// In en, this message translates to:
  /// **'Manage branch preview records'**
  String get staffPermManageBranches;

  /// No description provided for @staffPermManageStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage staff preview records'**
  String get staffPermManageStaff;

  /// No description provided for @staffPermViewReports.
  ///
  /// In en, this message translates to:
  /// **'View preview reports'**
  String get staffPermViewReports;

  /// No description provided for @staffPermManageAssignedBranches.
  ///
  /// In en, this message translates to:
  /// **'Manage assigned branch preview data'**
  String get staffPermManageAssignedBranches;

  /// No description provided for @staffPermViewBranchReports.
  ///
  /// In en, this message translates to:
  /// **'View assigned branch preview reports'**
  String get staffPermViewBranchReports;

  /// No description provided for @staffPermExecuteAssignedTasks.
  ///
  /// In en, this message translates to:
  /// **'Execute tasks in assigned branches'**
  String get staffPermExecuteAssignedTasks;

  /// No description provided for @staffPermViewAssignedBranch.
  ///
  /// In en, this message translates to:
  /// **'View assigned branch preview data'**
  String get staffPermViewAssignedBranch;

  /// No description provided for @staffPermViewBusinessPreview.
  ///
  /// In en, this message translates to:
  /// **'View business preview data (read-only)'**
  String get staffPermViewBusinessPreview;

  /// No description provided for @businessCenterBranchPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch permissions'**
  String get businessCenterBranchPermissionsTitle;

  /// No description provided for @businessCenterBranchPermissionsBody.
  ///
  /// In en, this message translates to:
  /// **'Preview staff access and actions per branch for this session only.'**
  String get businessCenterBranchPermissionsBody;

  /// No description provided for @branchPermPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch permissions'**
  String get branchPermPageTitle;

  /// No description provided for @branchPermPreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview — permissions are saved only in this session. Real server permissions are not connected yet.'**
  String get branchPermPreviewNotice;

  /// No description provided for @branchPermSelectStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff member'**
  String get branchPermSelectStaff;

  /// No description provided for @branchPermSelectBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branchPermSelectBranch;

  /// No description provided for @branchPermAccessStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch access'**
  String get branchPermAccessStatusTitle;

  /// No description provided for @branchPermAccessGrantedPreview.
  ///
  /// In en, this message translates to:
  /// **'Assigned to this branch (preview)'**
  String get branchPermAccessGrantedPreview;

  /// No description provided for @branchPermAccessNonePreview.
  ///
  /// In en, this message translates to:
  /// **'No access — staff is not assigned to this branch'**
  String get branchPermAccessNonePreview;

  /// No description provided for @branchPermUnassignedBranchHint.
  ///
  /// In en, this message translates to:
  /// **'Assign the staff member to this branch in Staff & roles before granting branch permissions.'**
  String get branchPermUnassignedBranchHint;

  /// No description provided for @branchPermOwnerNotEditable.
  ///
  /// In en, this message translates to:
  /// **'The preview business owner permissions cannot be changed here.'**
  String get branchPermOwnerNotEditable;

  /// No description provided for @branchPermRoleSuggestedHint.
  ///
  /// In en, this message translates to:
  /// **'Role suggestions differ from explicit branch permissions you set below.'**
  String get branchPermRoleSuggestedHint;

  /// No description provided for @branchPermSuggestedVsExplicitNotice.
  ///
  /// In en, this message translates to:
  /// **'Suggested role capabilities are guidance only — toggles below are explicit preview permissions for this branch.'**
  String get branchPermSuggestedVsExplicitNotice;

  /// No description provided for @branchPermGroupView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get branchPermGroupView;

  /// No description provided for @branchPermGroupEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get branchPermGroupEdit;

  /// No description provided for @branchPermGroupStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff management'**
  String get branchPermGroupStaff;

  /// No description provided for @branchPermViewBranch.
  ///
  /// In en, this message translates to:
  /// **'View branch'**
  String get branchPermViewBranch;

  /// No description provided for @branchPermEditBranchProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit branch profile'**
  String get branchPermEditBranchProfile;

  /// No description provided for @branchPermManageBranchHours.
  ///
  /// In en, this message translates to:
  /// **'Manage branch hours'**
  String get branchPermManageBranchHours;

  /// No description provided for @branchPermViewStaff.
  ///
  /// In en, this message translates to:
  /// **'View staff'**
  String get branchPermViewStaff;

  /// No description provided for @branchPermManageBranchStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage branch staff'**
  String get branchPermManageBranchStaff;

  /// No description provided for @branchPermViewBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'View business profile'**
  String get branchPermViewBusinessProfile;

  /// No description provided for @branchPermDescViewBranch.
  ///
  /// In en, this message translates to:
  /// **'See branch details in preview.'**
  String get branchPermDescViewBranch;

  /// No description provided for @branchPermDescEditBranchProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit branch name, address, and contacts in preview.'**
  String get branchPermDescEditBranchProfile;

  /// No description provided for @branchPermDescManageBranchHours.
  ///
  /// In en, this message translates to:
  /// **'Edit opening hours in preview.'**
  String get branchPermDescManageBranchHours;

  /// No description provided for @branchPermDescViewStaff.
  ///
  /// In en, this message translates to:
  /// **'See staff linked to this branch in preview.'**
  String get branchPermDescViewStaff;

  /// No description provided for @branchPermDescManageBranchStaff.
  ///
  /// In en, this message translates to:
  /// **'Assign or remove staff for this branch in preview.'**
  String get branchPermDescManageBranchStaff;

  /// No description provided for @branchPermDescViewBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'See business-level profile in preview.'**
  String get branchPermDescViewBusinessProfile;

  /// No description provided for @branchPermSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save permissions'**
  String get branchPermSaveAction;

  /// No description provided for @branchPermCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get branchPermCancelAction;

  /// No description provided for @branchPermSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Branch permissions saved for this session.'**
  String get branchPermSaveSuccess;

  /// No description provided for @branchPermSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your changes are still on screen.'**
  String get branchPermSaveFailed;

  /// No description provided for @branchPermInvalidScopeMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid staff or branch for this business preview scope.'**
  String get branchPermInvalidScopeMessage;

  /// No description provided for @branchPermDiscardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get branchPermDiscardConfirmTitle;

  /// No description provided for @branchPermDiscardConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Unsaved permission changes will be lost.'**
  String get branchPermDiscardConfirmBody;

  /// No description provided for @branchPermDiscardConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get branchPermDiscardConfirmAction;

  /// No description provided for @businessCenterCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get businessCenterCatalogTitle;

  /// No description provided for @businessCenterCatalogBody.
  ///
  /// In en, this message translates to:
  /// **'Preview categories and catalog stats for this business session only.'**
  String get businessCenterCatalogBody;

  /// No description provided for @catalogHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalogHomeTitle;

  /// No description provided for @catalogPreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview — catalog data is saved only in this session. Not connected to public search or customer orders.'**
  String get catalogPreviewNotice;

  /// No description provided for @catalogHomeIntro.
  ///
  /// In en, this message translates to:
  /// **'Organize products and services for your business preview. Customer-facing catalog sync arrives in a later phase.'**
  String get catalogHomeIntro;

  /// No description provided for @catalogStatCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get catalogStatCategories;

  /// No description provided for @catalogStatProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get catalogStatProducts;

  /// No description provided for @catalogStatServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get catalogStatServices;

  /// No description provided for @catalogStatActiveItems.
  ///
  /// In en, this message translates to:
  /// **'Active items'**
  String get catalogStatActiveItems;

  /// No description provided for @catalogStatDraftItems.
  ///
  /// In en, this message translates to:
  /// **'Draft items'**
  String get catalogStatDraftItems;

  /// No description provided for @catalogManageCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get catalogManageCategoriesTitle;

  /// No description provided for @catalogManageCategoriesBody.
  ///
  /// In en, this message translates to:
  /// **'Create and edit multilingual categories for this business preview.'**
  String get catalogManageCategoriesBody;

  /// No description provided for @catalogProductsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get catalogProductsSectionTitle;

  /// No description provided for @catalogProductsSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Manage preview products for this business session.'**
  String get catalogProductsSectionBody;

  /// No description provided for @catalogServicesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get catalogServicesSectionTitle;

  /// No description provided for @catalogServicesSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Manage preview services for this business session.'**
  String get catalogServicesSectionBody;

  /// No description provided for @catalogComingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Next phase'**
  String get catalogComingSoonLabel;

  /// No description provided for @catalogCategoryListTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get catalogCategoryListTitle;

  /// No description provided for @catalogCategoryAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get catalogCategoryAddAction;

  /// No description provided for @catalogCategorySearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get catalogCategorySearchLabel;

  /// No description provided for @catalogCategoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get catalogCategoryEmptyTitle;

  /// No description provided for @catalogCategoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a category to organize your business catalog preview.'**
  String get catalogCategoryEmptyBody;

  /// No description provided for @catalogCategoryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get catalogCategoryDetailTitle;

  /// No description provided for @catalogCategoryEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get catalogCategoryEditAction;

  /// No description provided for @catalogCategoryCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get catalogCategoryCreateTitle;

  /// No description provided for @catalogCategoryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get catalogCategoryEditTitle;

  /// No description provided for @catalogCategoryNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get catalogCategoryNotFoundTitle;

  /// No description provided for @catalogCategoryNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This category is not in the current business preview scope.'**
  String get catalogCategoryNotFoundBody;

  /// No description provided for @catalogCategoryBackToListAction.
  ///
  /// In en, this message translates to:
  /// **'Back to categories'**
  String get catalogCategoryBackToListAction;

  /// No description provided for @catalogCategoryNamesSection.
  ///
  /// In en, this message translates to:
  /// **'Names'**
  String get catalogCategoryNamesSection;

  /// No description provided for @catalogCategoryDescriptionsSection.
  ///
  /// In en, this message translates to:
  /// **'Descriptions'**
  String get catalogCategoryDescriptionsSection;

  /// No description provided for @catalogCategoryFieldEmpty.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get catalogCategoryFieldEmpty;

  /// No description provided for @catalogLanguageUz.
  ///
  /// In en, this message translates to:
  /// **'Uzbek'**
  String get catalogLanguageUz;

  /// No description provided for @catalogLanguageRu.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get catalogLanguageRu;

  /// No description provided for @catalogLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get catalogLanguageEn;

  /// No description provided for @catalogCategoryParentLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent: {name}'**
  String catalogCategoryParentLabel(String name);

  /// No description provided for @catalogCategoryStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get catalogCategoryStatusActive;

  /// No description provided for @catalogCategoryStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get catalogCategoryStatusDraft;

  /// No description provided for @catalogCategoryStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get catalogCategoryStatusArchived;

  /// No description provided for @catalogCategoryFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'Provide a name in at least one language (Uzbek, Russian, or English).'**
  String get catalogCategoryFormNameHint;

  /// No description provided for @catalogCategoryNameRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name in at least one language.'**
  String get catalogCategoryNameRequiredHint;

  /// No description provided for @catalogCategoryNameUzLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (Uzbek)'**
  String get catalogCategoryNameUzLabel;

  /// No description provided for @catalogCategoryNameRuLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (Russian)'**
  String get catalogCategoryNameRuLabel;

  /// No description provided for @catalogCategoryNameEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get catalogCategoryNameEnLabel;

  /// No description provided for @catalogCategoryDescUzLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Uzbek, optional)'**
  String get catalogCategoryDescUzLabel;

  /// No description provided for @catalogCategoryDescRuLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Russian, optional)'**
  String get catalogCategoryDescRuLabel;

  /// No description provided for @catalogCategoryDescEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (English, optional)'**
  String get catalogCategoryDescEnLabel;

  /// No description provided for @catalogCategoryStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get catalogCategoryStatusLabel;

  /// No description provided for @catalogCategoryParentFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent category (optional)'**
  String get catalogCategoryParentFieldLabel;

  /// No description provided for @catalogCategoryNoParent.
  ///
  /// In en, this message translates to:
  /// **'No parent'**
  String get catalogCategoryNoParent;

  /// No description provided for @catalogCategorySaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get catalogCategorySaveAction;

  /// No description provided for @catalogCategoryCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get catalogCategoryCancelAction;

  /// No description provided for @catalogCategorySaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category saved for this session.'**
  String get catalogCategorySaveSuccess;

  /// No description provided for @catalogCategorySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your entries are still on screen.'**
  String get catalogCategorySaveFailed;

  /// No description provided for @catalogCategoryDuplicateNameError.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists in this preview scope.'**
  String get catalogCategoryDuplicateNameError;

  /// No description provided for @catalogCategoryInvalidParentError.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid parent category without circular hierarchy.'**
  String get catalogCategoryInvalidParentError;

  /// No description provided for @catalogCategoryDiscardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get catalogCategoryDiscardConfirmTitle;

  /// No description provided for @catalogCategoryDiscardConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Unsaved category changes will be lost.'**
  String get catalogCategoryDiscardConfirmBody;

  /// No description provided for @catalogCategoryDiscardCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get catalogCategoryDiscardCancelAction;

  /// No description provided for @catalogCategoryDiscardConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get catalogCategoryDiscardConfirmAction;

  /// No description provided for @catalogListingStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get catalogListingStatusActive;

  /// No description provided for @catalogListingStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get catalogListingStatusDraft;

  /// No description provided for @catalogListingStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get catalogListingStatusArchived;

  /// No description provided for @catalogStatArchivedItems.
  ///
  /// In en, this message translates to:
  /// **'Archived items'**
  String get catalogStatArchivedItems;

  /// No description provided for @catalogListingSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get catalogListingSearchLabel;

  /// No description provided for @catalogListingCategoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Category filter'**
  String get catalogListingCategoryFilter;

  /// No description provided for @catalogListingStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status filter'**
  String get catalogListingStatusFilter;

  /// No description provided for @catalogListingAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get catalogListingAllCategories;

  /// No description provided for @catalogListingAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get catalogListingAllStatuses;

  /// No description provided for @catalogListingClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get catalogListingClearFilters;

  /// No description provided for @catalogListingFilteredCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {filtered} of {total}'**
  String catalogListingFilteredCount(int filtered, int total);

  /// No description provided for @catalogListingCategoryField.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get catalogListingCategoryField;

  /// No description provided for @catalogListingCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a category.'**
  String get catalogListingCategoryRequired;

  /// No description provided for @catalogListingInvalidCategory.
  ///
  /// In en, this message translates to:
  /// **'Category is not in this business preview scope.'**
  String get catalogListingInvalidCategory;

  /// No description provided for @catalogListingCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category: {name}'**
  String catalogListingCategoryLabel(String name);

  /// No description provided for @catalogHomeFilteredCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {filtered} of {total} in preview'**
  String catalogHomeFilteredCount(int filtered, int total);

  /// No description provided for @catalogProductListTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get catalogProductListTitle;

  /// No description provided for @catalogProductAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get catalogProductAddAction;

  /// No description provided for @catalogProductEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No products match your filters.'**
  String get catalogProductEmptyBody;

  /// No description provided for @catalogProductDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get catalogProductDetailTitle;

  /// No description provided for @catalogProductCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get catalogProductCreateTitle;

  /// No description provided for @catalogProductEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get catalogProductEditTitle;

  /// No description provided for @catalogProductNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get catalogProductNotFoundTitle;

  /// No description provided for @catalogProductBackToListAction.
  ///
  /// In en, this message translates to:
  /// **'Back to products'**
  String get catalogProductBackToListAction;

  /// No description provided for @catalogProductSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product saved for this session.'**
  String get catalogProductSaveSuccess;

  /// No description provided for @catalogProductSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your entries are still on screen.'**
  String get catalogProductSaveFailed;

  /// No description provided for @catalogProductAttributeKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribute key (optional)'**
  String get catalogProductAttributeKeyLabel;

  /// No description provided for @catalogProductAttributeValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribute value (optional)'**
  String get catalogProductAttributeValueLabel;

  /// No description provided for @catalogProductVariantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Variants ({count})'**
  String catalogProductVariantsTitle(int count);

  /// No description provided for @catalogProductVariantsManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Product variants'**
  String get catalogProductVariantsManageTitle;

  /// No description provided for @catalogServiceListTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get catalogServiceListTitle;

  /// No description provided for @catalogServiceAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get catalogServiceAddAction;

  /// No description provided for @catalogServiceEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No services match your filters.'**
  String get catalogServiceEmptyBody;

  /// No description provided for @catalogServiceDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get catalogServiceDetailTitle;

  /// No description provided for @catalogServiceCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New service'**
  String get catalogServiceCreateTitle;

  /// No description provided for @catalogServiceEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get catalogServiceEditTitle;

  /// No description provided for @catalogServiceBackToListAction.
  ///
  /// In en, this message translates to:
  /// **'Back to services'**
  String get catalogServiceBackToListAction;

  /// No description provided for @catalogServiceSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service saved for this session.'**
  String get catalogServiceSaveSuccess;

  /// No description provided for @catalogServiceSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your entries are still on screen.'**
  String get catalogServiceSaveFailed;

  /// No description provided for @catalogServiceInvalidDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration must be a positive number of minutes.'**
  String get catalogServiceInvalidDuration;

  /// No description provided for @catalogServiceDurationFieldOptional.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes, optional)'**
  String get catalogServiceDurationFieldOptional;

  /// No description provided for @catalogServiceDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} min'**
  String catalogServiceDurationLabel(int minutes);

  /// No description provided for @catalogVariantAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add variant'**
  String get catalogVariantAddAction;

  /// No description provided for @catalogVariantEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No variants yet for this product.'**
  String get catalogVariantEmptyBody;

  /// No description provided for @catalogVariantCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New variant'**
  String get catalogVariantCreateTitle;

  /// No description provided for @catalogVariantEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit variant'**
  String get catalogVariantEditTitle;

  /// No description provided for @catalogVariantLabelField.
  ///
  /// In en, this message translates to:
  /// **'Variant label'**
  String get catalogVariantLabelField;

  /// No description provided for @catalogVariantSkuField.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get catalogVariantSkuField;

  /// No description provided for @catalogVariantLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a variant label.'**
  String get catalogVariantLabelRequired;

  /// No description provided for @catalogVariantSkuRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a SKU.'**
  String get catalogVariantSkuRequired;

  /// No description provided for @catalogVariantSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Variant saved for this session.'**
  String get catalogVariantSaveSuccess;

  /// No description provided for @catalogVariantSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save variant.'**
  String get catalogVariantSaveFailed;

  /// No description provided for @catalogVariantDuplicateSku.
  ///
  /// In en, this message translates to:
  /// **'This SKU already exists in the preview scope.'**
  String get catalogVariantDuplicateSku;

  /// No description provided for @catalogOptionSelectionSingle.
  ///
  /// In en, this message translates to:
  /// **'Single choice'**
  String get catalogOptionSelectionSingle;

  /// No description provided for @catalogOptionSelectionMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get catalogOptionSelectionMultiple;

  /// No description provided for @catalogProductOptionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Options & add-ons'**
  String get catalogProductOptionsSectionTitle;

  /// No description provided for @catalogProductOptionsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No option groups yet for this product.'**
  String get catalogProductOptionsEmptyBody;

  /// No description provided for @catalogProductOptionsRequiresSaveHint.
  ///
  /// In en, this message translates to:
  /// **'Save the product first to manage options and media in this session.'**
  String get catalogProductOptionsRequiresSaveHint;

  /// No description provided for @catalogProductOptionGroupAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add option group'**
  String get catalogProductOptionGroupAddAction;

  /// No description provided for @catalogProductOptionGroupCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New option group'**
  String get catalogProductOptionGroupCreateTitle;

  /// No description provided for @catalogProductOptionGroupEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit option group'**
  String get catalogProductOptionGroupEditTitle;

  /// No description provided for @catalogProductOptionGroupRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get catalogProductOptionGroupRequired;

  /// No description provided for @catalogProductOptionGroupOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get catalogProductOptionGroupOptional;

  /// No description provided for @catalogProductOptionSelectionModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Selection mode'**
  String get catalogProductOptionSelectionModeLabel;

  /// No description provided for @catalogProductOptionMinSelectionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum selections'**
  String get catalogProductOptionMinSelectionsLabel;

  /// No description provided for @catalogProductOptionMaxSelectionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum selections'**
  String get catalogProductOptionMaxSelectionsLabel;

  /// No description provided for @catalogProductOptionSelectionLimits.
  ///
  /// In en, this message translates to:
  /// **'Select {min}–{max}'**
  String catalogProductOptionSelectionLimits(int min, int max);

  /// No description provided for @catalogProductOptionGroupSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Option group saved for this session.'**
  String get catalogProductOptionGroupSaveSuccess;

  /// No description provided for @catalogProductOptionGroupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save option group.'**
  String get catalogProductOptionGroupSaveFailed;

  /// No description provided for @catalogProductOptionGroupInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Check selection limits and names.'**
  String get catalogProductOptionGroupInvalidInput;

  /// No description provided for @catalogProductOptionGroupArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive option group?'**
  String get catalogProductOptionGroupArchiveTitle;

  /// No description provided for @catalogProductOptionGroupArchiveBody.
  ///
  /// In en, this message translates to:
  /// **'The group will be hidden from active preview lists. Existing options stay attached.'**
  String get catalogProductOptionGroupArchiveBody;

  /// No description provided for @catalogProductOptionGroupArchiveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get catalogProductOptionGroupArchiveConfirm;

  /// No description provided for @catalogProductOptionGroupArchiveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Option group archived.'**
  String get catalogProductOptionGroupArchiveSuccess;

  /// No description provided for @catalogProductOptionAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get catalogProductOptionAddAction;

  /// No description provided for @catalogProductOptionCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New option'**
  String get catalogProductOptionCreateTitle;

  /// No description provided for @catalogProductOptionEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit option'**
  String get catalogProductOptionEditTitle;

  /// No description provided for @catalogProductOptionActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get catalogProductOptionActiveLabel;

  /// No description provided for @catalogProductOptionInactiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get catalogProductOptionInactiveLabel;

  /// No description provided for @catalogProductOptionSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Option saved for this session.'**
  String get catalogProductOptionSaveSuccess;

  /// No description provided for @catalogProductOptionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save option.'**
  String get catalogProductOptionSaveFailed;

  /// No description provided for @catalogProductOptionInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Enter a name in at least one language.'**
  String get catalogProductOptionInvalidInput;

  /// No description provided for @catalogProductMediaGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Media gallery'**
  String get catalogProductMediaGalleryTitle;

  /// No description provided for @catalogProductMediaPreviewOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview only — upload comes in a later phase. Images stay in this session and are not sent to a server.'**
  String get catalogProductMediaPreviewOnlyNotice;

  /// No description provided for @catalogProductMediaEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No images yet. Add a local preview image for this session.'**
  String get catalogProductMediaEmptyBody;

  /// No description provided for @catalogProductMediaNoPrimary.
  ///
  /// In en, this message translates to:
  /// **'No primary image selected'**
  String get catalogProductMediaNoPrimary;

  /// No description provided for @catalogProductMediaPrimaryBadge.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get catalogProductMediaPrimaryBadge;

  /// No description provided for @catalogProductMediaAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get catalogProductMediaAddAction;

  /// No description provided for @catalogProductMediaMakePrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Make primary'**
  String get catalogProductMediaMakePrimaryAction;

  /// No description provided for @catalogProductMediaPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected image for preview.'**
  String get catalogProductMediaPickFailed;

  /// No description provided for @catalogProductMediaPreviewAdded.
  ///
  /// In en, this message translates to:
  /// **'Preview image added for this session.'**
  String get catalogProductMediaPreviewAdded;

  /// No description provided for @catalogProductMediaSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update media preview.'**
  String get catalogProductMediaSaveFailed;

  /// No description provided for @catalogAttributeValueKindText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get catalogAttributeValueKindText;

  /// No description provided for @catalogAttributeValueKindNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get catalogAttributeValueKindNumber;

  /// No description provided for @catalogAttributeValueKindChoice.
  ///
  /// In en, this message translates to:
  /// **'Choice'**
  String get catalogAttributeValueKindChoice;

  /// No description provided for @catalogListingAttributesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get catalogListingAttributesSectionTitle;

  /// No description provided for @catalogListingAttributesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No attributes yet for this listing.'**
  String get catalogListingAttributesEmptyBody;

  /// No description provided for @catalogListingAttributeAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add attribute'**
  String get catalogListingAttributeAddAction;

  /// No description provided for @catalogListingAttributeCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New attribute'**
  String get catalogListingAttributeCreateTitle;

  /// No description provided for @catalogListingAttributeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit attribute'**
  String get catalogListingAttributeEditTitle;

  /// No description provided for @catalogListingAttributeKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribute key'**
  String get catalogListingAttributeKeyLabel;

  /// No description provided for @catalogListingAttributeKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters, numbers, and underscores (e.g. unit).'**
  String get catalogListingAttributeKeyHint;

  /// No description provided for @catalogListingAttributeKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an attribute key.'**
  String get catalogListingAttributeKeyRequired;

  /// No description provided for @catalogListingAttributeKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, numbers, and underscores only.'**
  String get catalogListingAttributeKeyInvalid;

  /// No description provided for @catalogListingAttributeValueKindLabel.
  ///
  /// In en, this message translates to:
  /// **'Value type'**
  String get catalogListingAttributeValueKindLabel;

  /// No description provided for @catalogListingAttributeTextValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Text value'**
  String get catalogListingAttributeTextValueLabel;

  /// No description provided for @catalogListingAttributeNumberValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Number value'**
  String get catalogListingAttributeNumberValueLabel;

  /// No description provided for @catalogListingAttributeChoiceValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Choice value'**
  String get catalogListingAttributeChoiceValueLabel;

  /// No description provided for @catalogListingAttributeSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Attribute saved for this session.'**
  String get catalogListingAttributeSaveSuccess;

  /// No description provided for @catalogListingAttributeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save attribute.'**
  String get catalogListingAttributeSaveFailed;

  /// No description provided for @catalogListingAttributeInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Check the key, label, and value.'**
  String get catalogListingAttributeInvalidInput;

  /// No description provided for @catalogListingAttributeDuplicateKey.
  ///
  /// In en, this message translates to:
  /// **'This key already exists on this listing.'**
  String get catalogListingAttributeDuplicateKey;

  /// No description provided for @catalogListingAttributeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove attribute?'**
  String get catalogListingAttributeDeleteTitle;

  /// No description provided for @catalogListingAttributeDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the attribute from the session preview.'**
  String get catalogListingAttributeDeleteBody;

  /// No description provided for @catalogListingAttributeDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get catalogListingAttributeDeleteConfirm;

  /// No description provided for @catalogListingAttributeDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove attribute.'**
  String get catalogListingAttributeDeleteFailed;

  /// No description provided for @catalogInventorySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Product inventory (preview)'**
  String get catalogInventorySectionTitle;

  /// No description provided for @catalogInventorySectionBody.
  ///
  /// In en, this message translates to:
  /// **'Track on-hand and reserved quantities per branch for catalog products. Demo data only — not connected to live inventory.'**
  String get catalogInventorySectionBody;

  /// No description provided for @catalogInventoryListTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get catalogInventoryListTitle;

  /// No description provided for @catalogInventoryDemoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Demo data — not connected to live inventory. Adjustments stay in this session preview only.'**
  String get catalogInventoryDemoDisclaimer;

  /// No description provided for @catalogInventoryBranchFilter.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get catalogInventoryBranchFilter;

  /// No description provided for @catalogInventoryAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get catalogInventoryAllBranches;

  /// No description provided for @catalogInventoryAvailabilityFilter.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get catalogInventoryAvailabilityFilter;

  /// No description provided for @catalogInventoryAllAvailability.
  ///
  /// In en, this message translates to:
  /// **'All availability states'**
  String get catalogInventoryAllAvailability;

  /// No description provided for @catalogInventoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No inventory rows match your filters.'**
  String get catalogInventoryEmptyBody;

  /// No description provided for @catalogInventoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load inventory for this preview session.'**
  String get catalogInventoryLoadFailed;

  /// No description provided for @catalogInventoryRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get catalogInventoryRetryAction;

  /// No description provided for @catalogInventoryVariantLabel.
  ///
  /// In en, this message translates to:
  /// **'Variant: {name}'**
  String catalogInventoryVariantLabel(String name);

  /// No description provided for @catalogInventoryBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch: {name}'**
  String catalogInventoryBranchLabel(String name);

  /// No description provided for @catalogInventoryOnHandLabel.
  ///
  /// In en, this message translates to:
  /// **'On hand: {qty}'**
  String catalogInventoryOnHandLabel(int qty);

  /// No description provided for @catalogInventoryReservedLabel.
  ///
  /// In en, this message translates to:
  /// **'Reserved: {qty}'**
  String catalogInventoryReservedLabel(int qty);

  /// No description provided for @catalogInventoryAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available: {qty}'**
  String catalogInventoryAvailableLabel(int qty);

  /// No description provided for @catalogInventoryLowStockThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Low stock at: {qty}'**
  String catalogInventoryLowStockThresholdLabel(int qty);

  /// No description provided for @catalogInventoryAvailabilityInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get catalogInventoryAvailabilityInStock;

  /// No description provided for @catalogInventoryAvailabilityLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get catalogInventoryAvailabilityLowStock;

  /// No description provided for @catalogInventoryAvailabilityOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get catalogInventoryAvailabilityOutOfStock;

  /// No description provided for @catalogInventoryAvailabilityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get catalogInventoryAvailabilityUnavailable;

  /// No description provided for @catalogInventoryAdjustAction.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get catalogInventoryAdjustAction;

  /// No description provided for @catalogInventoryMarkUnavailableAction.
  ///
  /// In en, this message translates to:
  /// **'Mark unavailable'**
  String get catalogInventoryMarkUnavailableAction;

  /// No description provided for @catalogInventoryMarkAvailableAction.
  ///
  /// In en, this message translates to:
  /// **'Mark available'**
  String get catalogInventoryMarkAvailableAction;

  /// No description provided for @catalogInventoryShowHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get catalogInventoryShowHistoryAction;

  /// No description provided for @catalogInventoryHideHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Hide history'**
  String get catalogInventoryHideHistoryAction;

  /// No description provided for @catalogInventoryHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No adjustments recorded in this preview session yet.'**
  String get catalogInventoryHistoryEmpty;

  /// No description provided for @catalogInventoryHistoryLine.
  ///
  /// In en, this message translates to:
  /// **'Δ {delta} · on-hand {before} → {after} · {reason}'**
  String catalogInventoryHistoryLine(
    int delta,
    int before,
    int after,
    String reason,
  );

  /// No description provided for @catalogInventoryAdjustTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock adjustment'**
  String get catalogInventoryAdjustTitle;

  /// No description provided for @catalogInventoryAdjustKindLabel.
  ///
  /// In en, this message translates to:
  /// **'Adjustment type'**
  String get catalogInventoryAdjustKindLabel;

  /// No description provided for @catalogInventoryAdjustKindOnHand.
  ///
  /// In en, this message translates to:
  /// **'On-hand quantity'**
  String get catalogInventoryAdjustKindOnHand;

  /// No description provided for @catalogInventoryAdjustKindReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved quantity'**
  String get catalogInventoryAdjustKindReserved;

  /// No description provided for @catalogInventoryAdjustDeltaLabel.
  ///
  /// In en, this message translates to:
  /// **'Change (+/−)'**
  String get catalogInventoryAdjustDeltaLabel;

  /// No description provided for @catalogInventoryAdjustDeltaHint.
  ///
  /// In en, this message translates to:
  /// **'Use negative numbers to decrease.'**
  String get catalogInventoryAdjustDeltaHint;

  /// No description provided for @catalogInventoryAdjustReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get catalogInventoryAdjustReasonLabel;

  /// No description provided for @catalogInventoryAdjustConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get catalogInventoryAdjustConfirmAction;

  /// No description provided for @catalogInventoryAdjustReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a short reason.'**
  String get catalogInventoryAdjustReasonRequired;

  /// No description provided for @catalogInventoryAdjustDeltaZero.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-zero change.'**
  String get catalogInventoryAdjustDeltaZero;

  /// No description provided for @catalogInventoryAdjustDeltaInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number.'**
  String get catalogInventoryAdjustDeltaInvalid;

  /// No description provided for @catalogInventoryAdjustInvalidQuantities.
  ///
  /// In en, this message translates to:
  /// **'This change would make quantities invalid.'**
  String get catalogInventoryAdjustInvalidQuantities;

  /// No description provided for @catalogInventoryAdjustSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not apply adjustment. Try again.'**
  String get catalogInventoryAdjustSaveFailed;

  /// No description provided for @catalogInventoryAdjustSuccess.
  ///
  /// In en, this message translates to:
  /// **'Stock updated for this preview session.'**
  String get catalogInventoryAdjustSuccess;

  /// No description provided for @catalogInventoryReservationsNavAction.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get catalogInventoryReservationsNavAction;

  /// No description provided for @catalogInventoryReservationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory reservations'**
  String get catalogInventoryReservationsTitle;

  /// No description provided for @catalogInventoryReservationDemoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Demo reservations only — not connected to live checkout or inventory.'**
  String get catalogInventoryReservationDemoDisclaimer;

  /// No description provided for @catalogInventoryReservationCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Reserve stock'**
  String get catalogInventoryReservationCreateAction;

  /// No description provided for @catalogInventoryReservationCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create demo reservation'**
  String get catalogInventoryReservationCreateTitle;

  /// No description provided for @catalogInventoryReservationCreateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get catalogInventoryReservationCreateConfirm;

  /// No description provided for @catalogInventoryReservationCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reservation created for this preview session.'**
  String get catalogInventoryReservationCreateSuccess;

  /// No description provided for @catalogInventoryReservationItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Inventory row'**
  String get catalogInventoryReservationItemLabel;

  /// No description provided for @catalogInventoryReservationItemRequired.
  ///
  /// In en, this message translates to:
  /// **'Select an inventory row.'**
  String get catalogInventoryReservationItemRequired;

  /// No description provided for @catalogInventoryReservationQuantityField.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get catalogInventoryReservationQuantityField;

  /// No description provided for @catalogInventoryReservationQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {qty}'**
  String catalogInventoryReservationQuantityLabel(int qty);

  /// No description provided for @catalogInventoryReservationQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive quantity.'**
  String get catalogInventoryReservationQuantityInvalid;

  /// No description provided for @catalogInventoryReservationExpiryMinutesField.
  ///
  /// In en, this message translates to:
  /// **'Expires in (minutes)'**
  String get catalogInventoryReservationExpiryMinutesField;

  /// No description provided for @catalogInventoryReservationExpiryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Expiry must be in the future.'**
  String get catalogInventoryReservationExpiryInvalid;

  /// No description provided for @catalogInventoryReservationInsufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough available stock for this preview row.'**
  String get catalogInventoryReservationInsufficientStock;

  /// No description provided for @catalogInventoryReservationItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This inventory row is marked unavailable.'**
  String get catalogInventoryReservationItemUnavailable;

  /// No description provided for @catalogInventoryReservationSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save reservation. Try again.'**
  String get catalogInventoryReservationSaveFailed;

  /// No description provided for @catalogInventoryReservationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reservations in this preview session yet.'**
  String get catalogInventoryReservationEmpty;

  /// No description provided for @catalogInventoryReservationStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get catalogInventoryReservationStatusFilter;

  /// No description provided for @catalogInventoryReservationAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get catalogInventoryReservationAllStatuses;

  /// No description provided for @catalogInventoryReservationStatusReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get catalogInventoryReservationStatusReserved;

  /// No description provided for @catalogInventoryReservationStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get catalogInventoryReservationStatusConfirmed;

  /// No description provided for @catalogInventoryReservationStatusReleased.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get catalogInventoryReservationStatusReleased;

  /// No description provided for @catalogInventoryReservationStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get catalogInventoryReservationStatusExpired;

  /// No description provided for @catalogInventoryReservationCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String catalogInventoryReservationCreatedLabel(String date);

  /// No description provided for @catalogInventoryReservationExpiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String catalogInventoryReservationExpiresLabel(String date);

  /// No description provided for @catalogInventoryReservationReleaseAction.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get catalogInventoryReservationReleaseAction;

  /// No description provided for @catalogInventoryReservationConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm sale'**
  String get catalogInventoryReservationConfirmAction;

  /// No description provided for @catalogInventoryReservationExpireAction.
  ///
  /// In en, this message translates to:
  /// **'Expire'**
  String get catalogInventoryReservationExpireAction;

  /// No description provided for @catalogInventoryReservationExpireAllDue.
  ///
  /// In en, this message translates to:
  /// **'Expire due'**
  String get catalogInventoryReservationExpireAllDue;

  /// No description provided for @catalogInventoryReservationExpireAllResult.
  ///
  /// In en, this message translates to:
  /// **'Expired {count} due reservation(s) in preview.'**
  String catalogInventoryReservationExpireAllResult(int count);

  /// No description provided for @catalogInventoryReservationReleaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reservation released.'**
  String get catalogInventoryReservationReleaseSuccess;

  /// No description provided for @catalogInventoryReservationConfirmSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reservation confirmed as demo sale.'**
  String get catalogInventoryReservationConfirmSuccess;

  /// No description provided for @catalogInventoryReservationExpireSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reservation expired.'**
  String get catalogInventoryReservationExpireSuccess;

  /// No description provided for @catalogInventoryReservationHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No lifecycle events yet.'**
  String get catalogInventoryReservationHistoryEmpty;

  /// No description provided for @catalogInventoryReservationHistoryLine.
  ///
  /// In en, this message translates to:
  /// **'{action}: {fromStatus} → {toStatus} · qty {quantity}'**
  String catalogInventoryReservationHistoryLine(
    String action,
    String fromStatus,
    String toStatus,
    int quantity,
  );

  /// No description provided for @catalogInventoryReservationReconcileAction.
  ///
  /// In en, this message translates to:
  /// **'Run audit'**
  String get catalogInventoryReservationReconcileAction;

  /// No description provided for @catalogInventoryReservationReconcileTitle.
  ///
  /// In en, this message translates to:
  /// **'Reserved quantity audit (demo)'**
  String get catalogInventoryReservationReconcileTitle;

  /// No description provided for @catalogInventoryReservationReconcileDemoNote.
  ///
  /// In en, this message translates to:
  /// **'This audit compares active reservations to inventory reserved totals. It does not change stock.'**
  String get catalogInventoryReservationReconcileDemoNote;

  /// No description provided for @catalogInventoryReservationReconcileClean.
  ///
  /// In en, this message translates to:
  /// **'No discrepancies found.'**
  String get catalogInventoryReservationReconcileClean;

  /// No description provided for @catalogInventoryReservationReconcileLine.
  ///
  /// In en, this message translates to:
  /// **'{itemId}: expected {expected}, actual {actual}'**
  String catalogInventoryReservationReconcileLine(
    String itemId,
    int expected,
    int actual,
  );

  /// No description provided for @catalogResourceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Resource capacity (preview)'**
  String get catalogResourceSectionTitle;

  /// No description provided for @catalogResourceSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Equipment, staff, and service capacity per branch — separate from product stock.'**
  String get catalogResourceSectionBody;

  /// No description provided for @catalogResourceListTitle.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get catalogResourceListTitle;

  /// No description provided for @catalogResourceDemoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Demo resource capacity — not connected to live bookings.'**
  String get catalogResourceDemoDisclaimer;

  /// No description provided for @catalogResourceAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add resource'**
  String get catalogResourceAddAction;

  /// No description provided for @catalogResourceEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No resources match your filters.'**
  String get catalogResourceEmptyBody;

  /// No description provided for @catalogResourceBranchFilter.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get catalogResourceBranchFilter;

  /// No description provided for @catalogResourceAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get catalogResourceAllBranches;

  /// No description provided for @catalogResourceTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Resource type'**
  String get catalogResourceTypeFilter;

  /// No description provided for @catalogResourceAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get catalogResourceAllTypes;

  /// No description provided for @catalogResourceStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get catalogResourceStatusFilter;

  /// No description provided for @catalogResourceAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get catalogResourceAllStatuses;

  /// No description provided for @catalogResourceTypeEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get catalogResourceTypeEquipment;

  /// No description provided for @catalogResourceTypeStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get catalogResourceTypeStaff;

  /// No description provided for @catalogResourceTypeServiceCapacity.
  ///
  /// In en, this message translates to:
  /// **'Service capacity'**
  String get catalogResourceTypeServiceCapacity;

  /// No description provided for @catalogResourceStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get catalogResourceStatusActive;

  /// No description provided for @catalogResourceStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get catalogResourceStatusUnavailable;

  /// No description provided for @catalogResourceStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get catalogResourceStatusArchived;

  /// No description provided for @catalogResourceTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total capacity: {qty}'**
  String catalogResourceTotalLabel(int qty);

  /// No description provided for @catalogResourceAllocatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Allocated (demo): {qty}'**
  String catalogResourceAllocatedLabel(int qty);

  /// No description provided for @catalogResourceAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available: {qty}'**
  String catalogResourceAvailableLabel(int qty);

  /// No description provided for @catalogResourceUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit: {unit}'**
  String catalogResourceUnitLabel(String unit);

  /// No description provided for @catalogResourceEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get catalogResourceEditAction;

  /// No description provided for @catalogResourceChangeCapacityAction.
  ///
  /// In en, this message translates to:
  /// **'Change capacity'**
  String get catalogResourceChangeCapacityAction;

  /// No description provided for @catalogResourceMarkUnavailableAction.
  ///
  /// In en, this message translates to:
  /// **'Mark unavailable'**
  String get catalogResourceMarkUnavailableAction;

  /// No description provided for @catalogResourceMarkActiveAction.
  ///
  /// In en, this message translates to:
  /// **'Mark active'**
  String get catalogResourceMarkActiveAction;

  /// No description provided for @catalogResourceArchiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get catalogResourceArchiveAction;

  /// No description provided for @catalogResourceHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No capacity changes in this preview session yet.'**
  String get catalogResourceHistoryEmpty;

  /// No description provided for @catalogResourceHistoryLine.
  ///
  /// In en, this message translates to:
  /// **'Total {before} → {after} · {reason}'**
  String catalogResourceHistoryLine(int before, int after, String reason);

  /// No description provided for @catalogResourceCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New resource'**
  String get catalogResourceCreateTitle;

  /// No description provided for @catalogResourceEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit resource'**
  String get catalogResourceEditTitle;

  /// No description provided for @catalogResourceNameField.
  ///
  /// In en, this message translates to:
  /// **'Name (English preview)'**
  String get catalogResourceNameField;

  /// No description provided for @catalogResourceUnitField.
  ///
  /// In en, this message translates to:
  /// **'Capacity unit'**
  String get catalogResourceUnitField;

  /// No description provided for @catalogResourceTotalField.
  ///
  /// In en, this message translates to:
  /// **'Total capacity'**
  String get catalogResourceTotalField;

  /// No description provided for @catalogResourceSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get catalogResourceSaveAction;

  /// No description provided for @catalogResourceSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Resource saved for this preview session.'**
  String get catalogResourceSaveSuccess;

  /// No description provided for @catalogResourceSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your entries.'**
  String get catalogResourceSaveFailed;

  /// No description provided for @catalogResourceBranchRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a branch.'**
  String get catalogResourceBranchRequired;

  /// No description provided for @catalogResourceCapacityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative capacity.'**
  String get catalogResourceCapacityInvalid;

  /// No description provided for @catalogResourceBelowAllocated.
  ///
  /// In en, this message translates to:
  /// **'Total capacity cannot be below demo allocated amount.'**
  String get catalogResourceBelowAllocated;

  /// No description provided for @catalogResourceChangeCapacityTitle.
  ///
  /// In en, this message translates to:
  /// **'Change total capacity'**
  String get catalogResourceChangeCapacityTitle;

  /// No description provided for @catalogResourceReasonField.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get catalogResourceReasonField;

  /// No description provided for @catalogResourceReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a short reason.'**
  String get catalogResourceReasonRequired;

  /// No description provided for @catalogResourceNoCapacityChange.
  ///
  /// In en, this message translates to:
  /// **'Enter a different total capacity.'**
  String get catalogResourceNoCapacityChange;

  /// No description provided for @catalogResourceAllocatedHint.
  ///
  /// In en, this message translates to:
  /// **'Demo allocated: {qty} (read-only in this phase).'**
  String catalogResourceAllocatedHint(int qty);

  /// No description provided for @catalogResourceCapacityChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Capacity updated for this preview session.'**
  String get catalogResourceCapacityChangeSuccess;

  /// No description provided for @catalogPricingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Base pricing (preview)'**
  String get catalogPricingSectionTitle;

  /// No description provided for @catalogPricingSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Manage catalog price rules per branch with effective dates. Illustrative demo prices — not connected to live checkout.'**
  String get catalogPricingSectionBody;

  /// No description provided for @catalogPricingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get catalogPricingListTitle;

  /// No description provided for @catalogPricingDemoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Illustrative demo prices — not connected to live checkout.'**
  String get catalogPricingDemoDisclaimer;

  /// No description provided for @catalogPricingAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add price rule'**
  String get catalogPricingAddAction;

  /// No description provided for @catalogPricingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No price rules match your filters.'**
  String get catalogPricingEmptyBody;

  /// No description provided for @catalogPricingBranchFilter.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get catalogPricingBranchFilter;

  /// No description provided for @catalogPricingAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get catalogPricingAllBranches;

  /// No description provided for @catalogPricingKindFilter.
  ///
  /// In en, this message translates to:
  /// **'Listing type'**
  String get catalogPricingKindFilter;

  /// No description provided for @catalogPricingAllKinds.
  ///
  /// In en, this message translates to:
  /// **'All listing types'**
  String get catalogPricingAllKinds;

  /// No description provided for @catalogPricingKindProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get catalogPricingKindProduct;

  /// No description provided for @catalogPricingKindService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get catalogPricingKindService;

  /// No description provided for @catalogPricingStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get catalogPricingStatusFilter;

  /// No description provided for @catalogPricingAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get catalogPricingAllStatuses;

  /// No description provided for @catalogPricingStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get catalogPricingStatusDraft;

  /// No description provided for @catalogPricingStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get catalogPricingStatusActive;

  /// No description provided for @catalogPricingStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get catalogPricingStatusArchived;

  /// No description provided for @catalogPricingVariantLabel.
  ///
  /// In en, this message translates to:
  /// **'Variant: {name}'**
  String catalogPricingVariantLabel(String name);

  /// No description provided for @catalogPricingBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch: {name}'**
  String catalogPricingBranchLabel(String name);

  /// No description provided for @catalogPricingAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String catalogPricingAmountLabel(String amount);

  /// No description provided for @catalogPricingEffectiveIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Effective: {from} → {until}'**
  String catalogPricingEffectiveIntervalLabel(String from, String until);

  /// No description provided for @catalogPricingOpenEnded.
  ///
  /// In en, this message translates to:
  /// **'open-ended'**
  String get catalogPricingOpenEnded;

  /// No description provided for @catalogPricingRevisionLabel.
  ///
  /// In en, this message translates to:
  /// **'Revision: {revision}'**
  String catalogPricingRevisionLabel(int revision);

  /// No description provided for @catalogPricingEffectivePreviewLine.
  ///
  /// In en, this message translates to:
  /// **'Effective price at preview time: {result}'**
  String catalogPricingEffectivePreviewLine(String result);

  /// No description provided for @catalogPricingEffectiveFound.
  ///
  /// In en, this message translates to:
  /// **'{amount}'**
  String catalogPricingEffectiveFound(String amount);

  /// No description provided for @catalogPricingEffectiveNotFound.
  ///
  /// In en, this message translates to:
  /// **'No matching active price'**
  String get catalogPricingEffectiveNotFound;

  /// No description provided for @catalogPricingEffectiveAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Ambiguous — multiple active prices match'**
  String get catalogPricingEffectiveAmbiguous;

  /// No description provided for @catalogPricingEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get catalogPricingEditAction;

  /// No description provided for @catalogPricingActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get catalogPricingActivateAction;

  /// No description provided for @catalogPricingArchiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get catalogPricingArchiveAction;

  /// No description provided for @catalogPricingShowHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get catalogPricingShowHistoryAction;

  /// No description provided for @catalogPricingHideHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Hide history'**
  String get catalogPricingHideHistoryAction;

  /// No description provided for @catalogPricingHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No price history in this preview session yet.'**
  String get catalogPricingHistoryEmpty;

  /// No description provided for @catalogPricingHistoryLine.
  ///
  /// In en, this message translates to:
  /// **'{action}: {before} → {after}'**
  String catalogPricingHistoryLine(String action, String before, String after);

  /// No description provided for @catalogPricingPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Effective price preview'**
  String get catalogPricingPreviewTitle;

  /// No description provided for @catalogPricingPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a demo as-of date to evaluate which active rule applies.'**
  String get catalogPricingPreviewBody;

  /// No description provided for @catalogPricingPreviewAsOfLabel.
  ///
  /// In en, this message translates to:
  /// **'As of: {date}'**
  String catalogPricingPreviewAsOfLabel(String date);

  /// No description provided for @catalogPricingPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Resolver uses active rules only; variant-specific prices override base listing prices.'**
  String get catalogPricingPreviewHint;

  /// No description provided for @catalogPricingCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New price rule'**
  String get catalogPricingCreateTitle;

  /// No description provided for @catalogPricingEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit draft price'**
  String get catalogPricingEditTitle;

  /// No description provided for @catalogPricingVariantOptional.
  ///
  /// In en, this message translates to:
  /// **'Variant (optional)'**
  String get catalogPricingVariantOptional;

  /// No description provided for @catalogPricingBaseListingPrice.
  ///
  /// In en, this message translates to:
  /// **'Base listing (no variant)'**
  String get catalogPricingBaseListingPrice;

  /// No description provided for @catalogPricingAmountField.
  ///
  /// In en, this message translates to:
  /// **'Amount (whole UZS som)'**
  String get catalogPricingAmountField;

  /// No description provided for @catalogPricingEffectiveFromField.
  ///
  /// In en, this message translates to:
  /// **'Effective from (YYYY-MM-DD UTC)'**
  String get catalogPricingEffectiveFromField;

  /// No description provided for @catalogPricingEffectiveUntilField.
  ///
  /// In en, this message translates to:
  /// **'Effective until (optional, YYYY-MM-DD UTC)'**
  String get catalogPricingEffectiveUntilField;

  /// No description provided for @catalogPricingCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Currency: UZS (whole som, no fractional conversion).'**
  String get catalogPricingCurrencyHint;

  /// No description provided for @catalogPricingCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get catalogPricingCancelAction;

  /// No description provided for @catalogPricingSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get catalogPricingSaveAction;

  /// No description provided for @catalogPricingScopeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select branch and listing.'**
  String get catalogPricingScopeRequired;

  /// No description provided for @catalogPricingAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative whole amount.'**
  String get catalogPricingAmountInvalid;

  /// No description provided for @catalogPricingDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter dates as YYYY-MM-DD.'**
  String get catalogPricingDateInvalid;

  /// No description provided for @catalogPricingActiveImmutable.
  ///
  /// In en, this message translates to:
  /// **'Active prices cannot be edited silently. Create a new revision draft instead.'**
  String get catalogPricingActiveImmutable;

  /// No description provided for @catalogPricingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your entries.'**
  String get catalogPricingSaveFailed;

  /// No description provided for @catalogPricingEffectiveRangeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Effective until must be after effective from.'**
  String get catalogPricingEffectiveRangeInvalid;

  /// No description provided for @catalogPricingActivateOverlapError.
  ///
  /// In en, this message translates to:
  /// **'Cannot activate: another active price overlaps this interval for the same target.'**
  String get catalogPricingActivateOverlapError;

  /// No description provided for @catalogDiscountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Discount rules (preview)'**
  String get catalogDiscountSectionTitle;

  /// No description provided for @catalogDiscountSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Illustrative discount rules on top of catalog base prices — not connected to live checkout.'**
  String get catalogDiscountSectionBody;

  /// No description provided for @catalogDiscountListTitle.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get catalogDiscountListTitle;

  /// No description provided for @catalogDiscountDemoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Illustrative discounts only — not connected to live checkout.'**
  String get catalogDiscountDemoDisclaimer;

  /// No description provided for @catalogDiscountAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add discount rule'**
  String get catalogDiscountAddAction;

  /// No description provided for @catalogDiscountEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No discount rules match your filters.'**
  String get catalogDiscountEmptyBody;

  /// No description provided for @catalogDiscountBranchFilter.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get catalogDiscountBranchFilter;

  /// No description provided for @catalogDiscountAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get catalogDiscountAllBranches;

  /// No description provided for @catalogDiscountScopeFilter.
  ///
  /// In en, this message translates to:
  /// **'Target scope'**
  String get catalogDiscountScopeFilter;

  /// No description provided for @catalogDiscountAllScopes.
  ///
  /// In en, this message translates to:
  /// **'All scopes'**
  String get catalogDiscountAllScopes;

  /// No description provided for @catalogDiscountScopeBusinessWide.
  ///
  /// In en, this message translates to:
  /// **'Business-wide'**
  String get catalogDiscountScopeBusinessWide;

  /// No description provided for @catalogDiscountScopeProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get catalogDiscountScopeProduct;

  /// No description provided for @catalogDiscountScopeService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get catalogDiscountScopeService;

  /// No description provided for @catalogDiscountStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get catalogDiscountStatusFilter;

  /// No description provided for @catalogDiscountAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get catalogDiscountAllStatuses;

  /// No description provided for @catalogDiscountTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Discount type'**
  String get catalogDiscountTypeFilter;

  /// No description provided for @catalogDiscountTypePercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get catalogDiscountTypePercentage;

  /// No description provided for @catalogDiscountTypeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount (UZS)'**
  String get catalogDiscountTypeFixed;

  /// No description provided for @catalogDiscountPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% off'**
  String catalogDiscountPercentLabel(int percent);

  /// No description provided for @catalogDiscountFixedLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} off'**
  String catalogDiscountFixedLabel(String amount);

  /// No description provided for @catalogDiscountMinBasketLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum basket: {amount}'**
  String catalogDiscountMinBasketLabel(String amount);

  /// No description provided for @catalogDiscountPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority: {priority}'**
  String catalogDiscountPriorityLabel(int priority);

  /// No description provided for @catalogDiscountEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get catalogDiscountEditAction;

  /// No description provided for @catalogDiscountActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get catalogDiscountActivateAction;

  /// No description provided for @catalogDiscountArchiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get catalogDiscountArchiveAction;

  /// No description provided for @catalogDiscountShowHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get catalogDiscountShowHistoryAction;

  /// No description provided for @catalogDiscountHideHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Hide history'**
  String get catalogDiscountHideHistoryAction;

  /// No description provided for @catalogDiscountHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No discount history in this preview session yet.'**
  String get catalogDiscountHistoryEmpty;

  /// No description provided for @catalogDiscountHistoryLine.
  ///
  /// In en, this message translates to:
  /// **'{action}: rev {before} → {after}'**
  String catalogDiscountHistoryLine(String action, String before, String after);

  /// No description provided for @catalogDiscountPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Illustrative price after discount'**
  String get catalogDiscountPreviewTitle;

  /// No description provided for @catalogDiscountPreviewListingKind.
  ///
  /// In en, this message translates to:
  /// **'Preview listing type'**
  String get catalogDiscountPreviewListingKind;

  /// No description provided for @catalogDiscountPreviewListing.
  ///
  /// In en, this message translates to:
  /// **'Preview listing'**
  String get catalogDiscountPreviewListing;

  /// No description provided for @catalogDiscountPreviewSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Qualifying subtotal (optional, UZS)'**
  String get catalogDiscountPreviewSubtotal;

  /// No description provided for @catalogDiscountPreviewNoBasePrice.
  ///
  /// In en, this message translates to:
  /// **'No active base price for this preview target.'**
  String get catalogDiscountPreviewNoBasePrice;

  /// No description provided for @catalogDiscountPreviewNoDiscount.
  ///
  /// In en, this message translates to:
  /// **'Could not compute discount preview.'**
  String get catalogDiscountPreviewNoDiscount;

  /// No description provided for @catalogDiscountPreviewApplied.
  ///
  /// In en, this message translates to:
  /// **'Base {base} · discount −{discount} · final {finalAmount}'**
  String catalogDiscountPreviewApplied(
    String base,
    String discount,
    String finalAmount,
  );

  /// No description provided for @catalogDiscountPreviewNotApplied.
  ///
  /// In en, this message translates to:
  /// **'No eligible discount rule applies.'**
  String get catalogDiscountPreviewNotApplied;

  /// No description provided for @catalogDiscountPreviewAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Ambiguous — multiple rules share top priority.'**
  String get catalogDiscountPreviewAmbiguous;

  /// No description provided for @catalogDiscountCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New discount rule'**
  String get catalogDiscountCreateTitle;

  /// No description provided for @catalogDiscountEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit draft discount'**
  String get catalogDiscountEditTitle;

  /// No description provided for @catalogDiscountBasisPointsField.
  ///
  /// In en, this message translates to:
  /// **'Basis points (1000 = 10%)'**
  String get catalogDiscountBasisPointsField;

  /// No description provided for @catalogDiscountFixedAmountField.
  ///
  /// In en, this message translates to:
  /// **'Fixed discount (whole UZS)'**
  String get catalogDiscountFixedAmountField;

  /// No description provided for @catalogDiscountMinBasketField.
  ///
  /// In en, this message translates to:
  /// **'Minimum basket (optional, UZS)'**
  String get catalogDiscountMinBasketField;

  /// No description provided for @catalogDiscountPriorityField.
  ///
  /// In en, this message translates to:
  /// **'Priority (higher wins)'**
  String get catalogDiscountPriorityField;

  /// No description provided for @catalogDiscountScopeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select branch and target.'**
  String get catalogDiscountScopeRequired;

  /// No description provided for @catalogDiscountValueInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid discount value and priority.'**
  String get catalogDiscountValueInvalid;

  /// No description provided for @catalogDiscountActiveImmutable.
  ///
  /// In en, this message translates to:
  /// **'Active rules cannot be edited silently. Create a revision draft instead.'**
  String get catalogDiscountActiveImmutable;

  /// No description provided for @catalogDiscountSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your entries.'**
  String get catalogDiscountSaveFailed;

  /// No description provided for @catalogDiscountActivateOverlapError.
  ///
  /// In en, this message translates to:
  /// **'Cannot activate: another active rule overlaps this interval for the same target.'**
  String get catalogDiscountActivateOverlapError;

  /// No description provided for @catalogPromoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo codes (preview)'**
  String get catalogPromoSectionTitle;

  /// No description provided for @catalogPromoSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Illustrative promo codes and eligibility preview — not connected to live checkout.'**
  String get catalogPromoSectionBody;

  /// No description provided for @catalogPromoListTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo codes'**
  String get catalogPromoListTitle;

  /// No description provided for @catalogPromoDemoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Promo-code preview only — no live redemption or checkout.'**
  String get catalogPromoDemoDisclaimer;

  /// No description provided for @catalogPromoAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add promo code'**
  String get catalogPromoAddAction;

  /// No description provided for @catalogPromoEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No promo codes match your filters.'**
  String get catalogPromoEmptyBody;

  /// No description provided for @catalogPromoBranchFilter.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get catalogPromoBranchFilter;

  /// No description provided for @catalogPromoAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get catalogPromoAllBranches;

  /// No description provided for @catalogPromoStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get catalogPromoStatusFilter;

  /// No description provided for @catalogPromoAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get catalogPromoAllStatuses;

  /// No description provided for @catalogPromoPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo eligibility preview'**
  String get catalogPromoPreviewTitle;

  /// No description provided for @catalogPromoPreviewCode.
  ///
  /// In en, this message translates to:
  /// **'Enter promo code'**
  String get catalogPromoPreviewCode;

  /// No description provided for @catalogPromoPreviewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Demo customer reference (optional)'**
  String get catalogPromoPreviewCustomer;

  /// No description provided for @catalogPromoPreviewApplied.
  ///
  /// In en, this message translates to:
  /// **'Base {base} · discount −{discount} · final {finalAmount}'**
  String catalogPromoPreviewApplied(
    String base,
    String discount,
    String finalAmount,
  );

  /// No description provided for @catalogPromoUsageSnapshotLine.
  ///
  /// In en, this message translates to:
  /// **'Usage snapshot: {total} total · {customer} for this customer (preview only)'**
  String catalogPromoUsageSnapshotLine(int total, int customer);

  /// No description provided for @catalogPromoLinkedDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Linked discount: {id}'**
  String catalogPromoLinkedDiscountLabel(String id);

  /// No description provided for @catalogPromoMaxTotalUsesLabel.
  ///
  /// In en, this message translates to:
  /// **'Max total uses: {count}'**
  String catalogPromoMaxTotalUsesLabel(int count);

  /// No description provided for @catalogPromoMaxCustomerUsesLabel.
  ///
  /// In en, this message translates to:
  /// **'Max uses per customer: {count}'**
  String catalogPromoMaxCustomerUsesLabel(int count);

  /// No description provided for @catalogPromoEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get catalogPromoEditAction;

  /// No description provided for @catalogPromoActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get catalogPromoActivateAction;

  /// No description provided for @catalogPromoArchiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get catalogPromoArchiveAction;

  /// No description provided for @catalogPromoShowHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get catalogPromoShowHistoryAction;

  /// No description provided for @catalogPromoShowUsageAction.
  ///
  /// In en, this message translates to:
  /// **'Show usage'**
  String get catalogPromoShowUsageAction;

  /// No description provided for @catalogPromoUsageLine.
  ///
  /// In en, this message translates to:
  /// **'Customer {customer} · redemption {redemption}'**
  String catalogPromoUsageLine(String customer, String redemption);

  /// No description provided for @catalogPromoCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New promo code'**
  String get catalogPromoCreateTitle;

  /// No description provided for @catalogPromoEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit draft promo'**
  String get catalogPromoEditTitle;

  /// No description provided for @catalogPromoCodeField.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get catalogPromoCodeField;

  /// No description provided for @catalogPromoMinBasketField.
  ///
  /// In en, this message translates to:
  /// **'Minimum basket (optional, UZS)'**
  String get catalogPromoMinBasketField;

  /// No description provided for @catalogPromoMaxTotalUsesField.
  ///
  /// In en, this message translates to:
  /// **'Max total uses (optional)'**
  String get catalogPromoMaxTotalUsesField;

  /// No description provided for @catalogPromoMaxCustomerUsesField.
  ///
  /// In en, this message translates to:
  /// **'Max uses per customer (optional)'**
  String get catalogPromoMaxCustomerUsesField;

  /// No description provided for @catalogPromoActivateDiscountError.
  ///
  /// In en, this message translates to:
  /// **'Cannot activate: linked discount is inactive or intervals do not overlap.'**
  String get catalogPromoActivateDiscountError;

  /// No description provided for @catalogPromoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your entries.'**
  String get catalogPromoSaveFailed;

  /// No description provided for @catalogPromoActiveImmutable.
  ///
  /// In en, this message translates to:
  /// **'Active promo codes cannot be edited silently.'**
  String get catalogPromoActiveImmutable;

  /// No description provided for @catalogPromoEligibilityEligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible — linked discount applies.'**
  String get catalogPromoEligibilityEligible;

  /// No description provided for @catalogPromoEligibilityInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or unknown promo code.'**
  String get catalogPromoEligibilityInvalidCode;

  /// No description provided for @catalogPromoEligibilityInactive.
  ///
  /// In en, this message translates to:
  /// **'Promo code is not active.'**
  String get catalogPromoEligibilityInactive;

  /// No description provided for @catalogPromoEligibilityNotYetValid.
  ///
  /// In en, this message translates to:
  /// **'Promo code is not valid yet.'**
  String get catalogPromoEligibilityNotYetValid;

  /// No description provided for @catalogPromoEligibilityExpired.
  ///
  /// In en, this message translates to:
  /// **'Promo code has expired.'**
  String get catalogPromoEligibilityExpired;

  /// No description provided for @catalogPromoEligibilityScopeMismatch.
  ///
  /// In en, this message translates to:
  /// **'Promo code does not apply to this branch or listing.'**
  String get catalogPromoEligibilityScopeMismatch;

  /// No description provided for @catalogPromoEligibilityDiscountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Linked discount rule is unavailable.'**
  String get catalogPromoEligibilityDiscountUnavailable;

  /// No description provided for @catalogPromoEligibilityMinimumBasket.
  ///
  /// In en, this message translates to:
  /// **'Minimum basket requirement not met.'**
  String get catalogPromoEligibilityMinimumBasket;

  /// No description provided for @catalogPromoEligibilityTotalLimit.
  ///
  /// In en, this message translates to:
  /// **'Total usage limit reached.'**
  String get catalogPromoEligibilityTotalLimit;

  /// No description provided for @catalogPromoEligibilityCustomerLimit.
  ///
  /// In en, this message translates to:
  /// **'Customer usage limit reached.'**
  String get catalogPromoEligibilityCustomerLimit;

  /// No description provided for @catalogPromoEligibilityNoApplicableDiscount.
  ///
  /// In en, this message translates to:
  /// **'Linked discount does not apply to this listing.'**
  String get catalogPromoEligibilityNoApplicableDiscount;

  /// No description provided for @catalogPromoEligibilityBasePriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Base price is required for preview.'**
  String get catalogPromoEligibilityBasePriceRequired;

  /// No description provided for @catalogCommercialFeeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial fees (preview)'**
  String get catalogCommercialFeeSectionTitle;

  /// No description provided for @catalogCommercialFeeSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Illustrative platform, service, delivery and commission rules — not settlement.'**
  String get catalogCommercialFeeSectionBody;

  /// No description provided for @catalogCommercialFeeListTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial fees'**
  String get catalogCommercialFeeListTitle;

  /// No description provided for @catalogCommercialFeeDemoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Illustrative commercial fees only — not connected to live checkout or settlement.'**
  String get catalogCommercialFeeDemoDisclaimer;

  /// No description provided for @catalogCommercialFeeAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add fee rule'**
  String get catalogCommercialFeeAddAction;

  /// No description provided for @catalogCommercialFeeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No fee rules match your filters.'**
  String get catalogCommercialFeeEmptyBody;

  /// No description provided for @catalogCommercialFeeTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Fee type'**
  String get catalogCommercialFeeTypeFilter;

  /// No description provided for @catalogCommercialFeeAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All fee types'**
  String get catalogCommercialFeeAllTypes;

  /// No description provided for @catalogCommercialFeeStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get catalogCommercialFeeStatusFilter;

  /// No description provided for @catalogCommercialFeeAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get catalogCommercialFeeAllStatuses;

  /// No description provided for @catalogCommercialFeeBranchFilter.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get catalogCommercialFeeBranchFilter;

  /// No description provided for @catalogCommercialFeeAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get catalogCommercialFeeAllBranches;

  /// No description provided for @catalogCommercialFeeTypePlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform fee'**
  String get catalogCommercialFeeTypePlatform;

  /// No description provided for @catalogCommercialFeeTypeService.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get catalogCommercialFeeTypeService;

  /// No description provided for @catalogCommercialFeeTypeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get catalogCommercialFeeTypeDelivery;

  /// No description provided for @catalogCommercialFeeTypeCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get catalogCommercialFeeTypeCommission;

  /// No description provided for @catalogCommercialFeeBearerCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get catalogCommercialFeeBearerCustomer;

  /// No description provided for @catalogCommercialFeeBearerBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get catalogCommercialFeeBearerBusiness;

  /// No description provided for @catalogCommercialFeeBearerPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform accounting'**
  String get catalogCommercialFeeBearerPlatform;

  /// No description provided for @catalogCommercialFeeCalcFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount (UZS)'**
  String get catalogCommercialFeeCalcFixed;

  /// No description provided for @catalogCommercialFeeCalcPercent.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get catalogCommercialFeeCalcPercent;

  /// No description provided for @catalogCommercialFeeBasisListing.
  ///
  /// In en, this message translates to:
  /// **'Listing base'**
  String get catalogCommercialFeeBasisListing;

  /// No description provided for @catalogCommercialFeeBasisService.
  ///
  /// In en, this message translates to:
  /// **'Service amount'**
  String get catalogCommercialFeeBasisService;

  /// No description provided for @catalogCommercialFeeBasisDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery basis'**
  String get catalogCommercialFeeBasisDelivery;

  /// No description provided for @catalogCommercialFeeBasisCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission basis'**
  String get catalogCommercialFeeBasisCommission;

  /// No description provided for @catalogCommercialFeePriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority: {priority}'**
  String catalogCommercialFeePriorityLabel(int priority);

  /// No description provided for @catalogCommercialFeeEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get catalogCommercialFeeEditAction;

  /// No description provided for @catalogCommercialFeeActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get catalogCommercialFeeActivateAction;

  /// No description provided for @catalogCommercialFeeArchiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get catalogCommercialFeeArchiveAction;

  /// No description provided for @catalogCommercialFeeShowHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get catalogCommercialFeeShowHistoryAction;

  /// No description provided for @catalogCommercialFeeHideHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Hide history'**
  String get catalogCommercialFeeHideHistoryAction;

  /// No description provided for @catalogCommercialFeePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Fee preview'**
  String get catalogCommercialFeePreviewTitle;

  /// No description provided for @catalogCommercialFeePreviewListingBase.
  ///
  /// In en, this message translates to:
  /// **'Listing base (UZS)'**
  String get catalogCommercialFeePreviewListingBase;

  /// No description provided for @catalogCommercialFeePreviewService.
  ///
  /// In en, this message translates to:
  /// **'Service amount (UZS)'**
  String get catalogCommercialFeePreviewService;

  /// No description provided for @catalogCommercialFeePreviewDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery basis (UZS)'**
  String get catalogCommercialFeePreviewDelivery;

  /// No description provided for @catalogCommercialFeePreviewCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission basis (UZS)'**
  String get catalogCommercialFeePreviewCommission;

  /// No description provided for @catalogCommercialFeePreviewLine.
  ///
  /// In en, this message translates to:
  /// **'{type} · {bearer} · basis {basis} · fee {fee}'**
  String catalogCommercialFeePreviewLine(
    String type,
    String bearer,
    String basis,
    String fee,
  );

  /// No description provided for @catalogCommercialFeePreviewBasisMissing.
  ///
  /// In en, this message translates to:
  /// **'{type} ({bearer}): basis not provided.'**
  String catalogCommercialFeePreviewBasisMissing(String type, String bearer);

  /// No description provided for @catalogCommercialFeePreviewAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Ambiguous fee selection for: {types}'**
  String catalogCommercialFeePreviewAmbiguous(String types);

  /// No description provided for @catalogCommercialFeePreviewTotal.
  ///
  /// In en, this message translates to:
  /// **'Illustrative fee total: {amount}'**
  String catalogCommercialFeePreviewTotal(String amount);

  /// No description provided for @catalogCommercialFeeCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New fee rule'**
  String get catalogCommercialFeeCreateTitle;

  /// No description provided for @catalogCommercialFeeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit draft fee rule'**
  String get catalogCommercialFeeEditTitle;

  /// No description provided for @catalogCommercialFeeFixedField.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount (UZS)'**
  String get catalogCommercialFeeFixedField;

  /// No description provided for @catalogCommercialFeeBasisPointsField.
  ///
  /// In en, this message translates to:
  /// **'Basis points (500 = 5%)'**
  String get catalogCommercialFeeBasisPointsField;

  /// No description provided for @catalogCommercialFeePriorityField.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get catalogCommercialFeePriorityField;

  /// No description provided for @catalogCommercialFeeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your entries.'**
  String get catalogCommercialFeeSaveFailed;

  /// No description provided for @catalogCommercialFeeActiveImmutable.
  ///
  /// In en, this message translates to:
  /// **'Active fee rules cannot be edited silently.'**
  String get catalogCommercialFeeActiveImmutable;

  /// No description provided for @catalogCommercialFeeActivateOverlapError.
  ///
  /// In en, this message translates to:
  /// **'Cannot activate: another active rule overlaps this interval for the same scope.'**
  String get catalogCommercialFeeActivateOverlapError;

  /// No description provided for @businessCenterFulfillmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment settings'**
  String get businessCenterFulfillmentTitle;

  /// No description provided for @businessCenterFulfillmentBody.
  ///
  /// In en, this message translates to:
  /// **'Configure supported delivery, pickup and on-site service modes (preview).'**
  String get businessCenterFulfillmentBody;

  /// No description provided for @businessFulfillmentListTitle.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment'**
  String get businessFulfillmentListTitle;

  /// No description provided for @businessFulfillmentDemoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Demo fulfillment settings — not connected to live orders or delivery.'**
  String get businessFulfillmentDemoDisclaimer;

  /// No description provided for @businessFulfillmentAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add configuration'**
  String get businessFulfillmentAddAction;

  /// No description provided for @businessFulfillmentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No fulfillment configurations match your filters.'**
  String get businessFulfillmentEmptyBody;

  /// No description provided for @businessFulfillmentBranchFilter.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get businessFulfillmentBranchFilter;

  /// No description provided for @businessFulfillmentAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get businessFulfillmentAllBranches;

  /// No description provided for @businessFulfillmentTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment type'**
  String get businessFulfillmentTypeFilter;

  /// No description provided for @businessFulfillmentAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get businessFulfillmentAllTypes;

  /// No description provided for @businessFulfillmentStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get businessFulfillmentStatusFilter;

  /// No description provided for @businessFulfillmentAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get businessFulfillmentAllStatuses;

  /// No description provided for @businessFulfillmentTypeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get businessFulfillmentTypeDelivery;

  /// No description provided for @businessFulfillmentTypePickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get businessFulfillmentTypePickup;

  /// No description provided for @businessFulfillmentTypeServiceAtLocation.
  ///
  /// In en, this message translates to:
  /// **'Service at location'**
  String get businessFulfillmentTypeServiceAtLocation;

  /// No description provided for @businessFulfillmentScopeBusinessWide.
  ///
  /// In en, this message translates to:
  /// **'Business-wide'**
  String get businessFulfillmentScopeBusinessWide;

  /// No description provided for @businessFulfillmentScopeProduct.
  ///
  /// In en, this message translates to:
  /// **'Product listing'**
  String get businessFulfillmentScopeProduct;

  /// No description provided for @businessFulfillmentScopeService.
  ///
  /// In en, this message translates to:
  /// **'Service listing'**
  String get businessFulfillmentScopeService;

  /// No description provided for @businessFulfillmentTypesLabel.
  ///
  /// In en, this message translates to:
  /// **'Supported modes: {modes}'**
  String businessFulfillmentTypesLabel(String modes);

  /// No description provided for @businessFulfillmentPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Modes preview'**
  String get businessFulfillmentPreviewTitle;

  /// No description provided for @businessFulfillmentPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No modes selected'**
  String get businessFulfillmentPreviewEmpty;

  /// No description provided for @businessFulfillmentPreviewSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected configuration supports: {modes}'**
  String businessFulfillmentPreviewSelected(String modes);

  /// No description provided for @businessFulfillmentEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get businessFulfillmentEditAction;

  /// No description provided for @businessFulfillmentActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get businessFulfillmentActivateAction;

  /// No description provided for @businessFulfillmentArchiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get businessFulfillmentArchiveAction;

  /// No description provided for @businessFulfillmentShowHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get businessFulfillmentShowHistoryAction;

  /// No description provided for @businessFulfillmentHideHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Hide history'**
  String get businessFulfillmentHideHistoryAction;

  /// No description provided for @businessFulfillmentCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New fulfillment configuration'**
  String get businessFulfillmentCreateTitle;

  /// No description provided for @businessFulfillmentEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit draft configuration'**
  String get businessFulfillmentEditTitle;

  /// No description provided for @businessFulfillmentListingIdField.
  ///
  /// In en, this message translates to:
  /// **'Listing ID (product or service)'**
  String get businessFulfillmentListingIdField;

  /// No description provided for @businessFulfillmentTypesField.
  ///
  /// In en, this message translates to:
  /// **'Supported fulfillment modes'**
  String get businessFulfillmentTypesField;

  /// No description provided for @businessFulfillmentSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your entries.'**
  String get businessFulfillmentSaveFailed;

  /// No description provided for @businessFulfillmentActivateConflictError.
  ///
  /// In en, this message translates to:
  /// **'Another active configuration already exists for this branch and scope.'**
  String get businessFulfillmentActivateConflictError;

  /// No description provided for @businessFulfillmentSelectAtLeastOneType.
  ///
  /// In en, this message translates to:
  /// **'Select at least one fulfillment mode.'**
  String get businessFulfillmentSelectAtLeastOneType;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
