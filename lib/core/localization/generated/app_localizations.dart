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
