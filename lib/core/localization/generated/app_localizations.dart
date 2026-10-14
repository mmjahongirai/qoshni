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
  /// **'Local business profile drafts (demo)'**
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
