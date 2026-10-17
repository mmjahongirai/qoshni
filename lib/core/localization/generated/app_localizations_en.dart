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
  String get homeMapPreviewStatus =>
      'Demo map preview — live location and places will connect later.';

  @override
  String get homeNearbyChainsTitle => 'Nearby chains & essentials';

  @override
  String get homeNearbyChainsSubtitle =>
      'Find branches and everyday places quickly.';

  @override
  String get homeEssentialSupermarkets => 'Supermarkets';

  @override
  String get homeEssentialPharmacies => 'Pharmacies';

  @override
  String get homeEssentialHospitals => 'Hospitals & clinics';

  @override
  String get homeEssentialRestaurants => 'Cafes & restaurants';

  @override
  String get homeEssentialPlaceTypeHint => 'Demo category shortcut';

  @override
  String get homeMapLegendMarkets => 'Markets';

  @override
  String get homeMapLegendPharmacy => 'Pharmacy';

  @override
  String get homeMapLegendHealth => 'Health';

  @override
  String get homeMapLegendFood => 'Food';

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
  String get navHome => 'Home';

  @override
  String get demoContentBadge => 'Demo';

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

  @override
  String get businessDetailSectionCatalog => 'Products & services';

  @override
  String get businessDetailCatalogEmptyTitle => 'No demo offerings yet';

  @override
  String get businessDetailCatalogEmptyBody =>
      'Sample products and services for this business will appear here in future updates.';

  @override
  String get catalogItemTypeProduct => 'Product';

  @override
  String get catalogItemTypeService => 'Service';

  @override
  String catalogSamplePriceDemo(int amount) {
    return 'Demo price: $amount so\'m';
  }

  @override
  String get catalogItemDetailSectionDescription => 'Description';

  @override
  String get catalogItemDetailParentBusiness => 'Business';

  @override
  String get catalogItemDetailNotFoundTitle => 'Offering not found';

  @override
  String get catalogItemDetailNotFoundBody =>
      'This demo item does not exist or does not belong to the selected business.';

  @override
  String get catalogBarakaFreshBreadName => 'Sample — village bread';

  @override
  String get catalogBarakaFreshBreadDesc =>
      'Fictional daily bread listing for the demo grocery.';

  @override
  String get catalogBarakaDailyBasketName => 'Sample — essentials basket';

  @override
  String get catalogBarakaDailyBasketDesc =>
      'Fictional bundle of pantry staples (demo only).';

  @override
  String get catalogSamarkandPlovName => 'Sample — house plov';

  @override
  String get catalogSamarkandPlovDesc =>
      'Fictional single-portion plov for menu preview.';

  @override
  String get catalogSamarkandGreenTeaName => 'Sample — green tea';

  @override
  String get catalogSamarkandGreenTeaDesc =>
      'Fictional teapot serving for the demo cafe.';

  @override
  String get catalogShifoVitaminCName => 'Sample — vitamin C tablets';

  @override
  String get catalogShifoVitaminCDesc =>
      'Fictional OTC item; not a real pharmacy product.';

  @override
  String get catalogShifoFirstAidKitName => 'Sample — first aid kit';

  @override
  String get catalogShifoFirstAidKitDesc =>
      'Fictional basic kit for demonstration.';

  @override
  String get catalogTechUsbHubName => 'Sample — USB hub';

  @override
  String get catalogTechUsbHubDesc =>
      'Fictional accessory for the demo electronics shop.';

  @override
  String get catalogTechPhoneCaseName => 'Sample — phone case';

  @override
  String get catalogTechPhoneCaseDesc => 'Fictional universal case listing.';

  @override
  String get catalogStyleCottonTeeName => 'Sample — cotton T-shirt';

  @override
  String get catalogStyleCottonTeeDesc =>
      'Fictional apparel item for the demo boutique.';

  @override
  String get catalogPipeLeakVisitName => 'Sample — leak inspection';

  @override
  String get catalogPipeLeakVisitDesc =>
      'Fictional call-out plumbing service (demo).';

  @override
  String get catalogPipeTapInstallName => 'Sample — tap installation';

  @override
  String get catalogPipeTapInstallDesc =>
      'Fictional installation service with demo pricing.';

  @override
  String get catalogElectricSocketCheckName => 'Sample — socket safety check';

  @override
  String get catalogElectricSocketCheckDesc =>
      'Fictional electrician visit for the demo catalog.';

  @override
  String get catalogRentStudioNightName => 'Sample — studio (1 night)';

  @override
  String get catalogRentStudioNightDesc =>
      'Fictional short-stay listing; not a real rental.';

  @override
  String get catalogRentSedanDayName => 'Sample — sedan (1 day)';

  @override
  String get catalogRentSedanDayDesc =>
      'Fictional car hire listing for demo purposes.';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartOpenTooltip => 'Cart';

  @override
  String get cartAddToCart => 'Add to cart';

  @override
  String cartAddedSnackBar(String itemName) {
    return '$itemName added to cart (demo)';
  }

  @override
  String get cartCannotAddNoPrice =>
      'This demo item has no sample price and cannot be added to the cart total.';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyBody =>
      'Browse businesses and add demo products or services from an offering page.';

  @override
  String get cartBrowseHome => 'Back to Home';

  @override
  String get cartQuantityIncrease => 'Increase quantity';

  @override
  String get cartQuantityDecrease => 'Decrease quantity';

  @override
  String get cartRemoveItem => 'Remove from cart';

  @override
  String get cartClearAction => 'Clear';

  @override
  String get cartClearConfirmTitle => 'Clear cart?';

  @override
  String get cartClearConfirmBody => 'Remove all demo items from your cart?';

  @override
  String get cartClearConfirmYes => 'Clear cart';

  @override
  String get cartClearConfirmCancel => 'Cancel';

  @override
  String cartDemoAmountUzs(String amount) {
    return '$amount so\'m (demo sample price)';
  }

  @override
  String cartLineSubtotal(String amount) {
    return 'Line subtotal (demo): $amount';
  }

  @override
  String cartEstimatedTotalLabel(String amount) {
    return 'Estimated demo total: $amount';
  }

  @override
  String get cartDemoEstimateDisclaimer =>
      'This is a local demo estimate only — not a quote, invoice, or payment.';

  @override
  String get cartProceedCheckout => 'Proceed to checkout';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutReviewNotice =>
      'Review your demo cart. No payment or personal details are collected in this preview.';

  @override
  String get checkoutConfirmDemoOrder => 'Confirm demo order';

  @override
  String checkoutQuantityLabel(int quantity) {
    return 'Qty: $quantity';
  }

  @override
  String get checkoutEmptyTitle => 'Nothing to check out';

  @override
  String get checkoutEmptyBody =>
      'Your cart is empty. Add demo items before checkout.';

  @override
  String get demoOrderConfirmationTitle => 'Demo confirmation';

  @override
  String get demoOrderPreparedHeading => 'Demo order prepared';

  @override
  String demoOrderReferenceLabel(String referenceId) {
    return 'Demo reference: $referenceId';
  }

  @override
  String get demoOrderNoRealSubmissionNotice =>
      'No real order was sent to any business. No payment was taken and no delivery or booking was scheduled.';

  @override
  String get demoOrderReturnHome => 'Return to Home';

  @override
  String get demoOrderInvalidTitle => 'Confirmation unavailable';

  @override
  String get demoOrderInvalidBody =>
      'This demo confirmation is missing or expired. Start again from the cart.';

  @override
  String get demoOrdersTitle => 'Orders';

  @override
  String get demoOrdersEmptyTitle => 'No demo orders yet';

  @override
  String get demoOrdersEmptyBody =>
      'Confirm a demo checkout to see a local order preview here. Nothing is sent to businesses.';

  @override
  String demoOrdersListSummary(int lineCount, int unitCount) {
    String _temp0 = intl.Intl.pluralLogic(
      lineCount,
      locale: localeName,
      other: '$lineCount lines · $unitCount units',
      one: '1 line · $unitCount unit',
    );
    return '$_temp0';
  }

  @override
  String get demoOrderDetailTitle => 'Demo order';

  @override
  String get demoOrderDetailNotFoundTitle => 'Order not found';

  @override
  String get demoOrderDetailNotFoundBody =>
      'This demo order is not in your current session history. Confirm a new demo order or return home.';

  @override
  String get demoOrderStatusPreparedNotSent => 'Demo prepared — not sent';

  @override
  String get demoOrderStatusLocalOnlyNote =>
      'Status is stored only on this device for the demo. There is no business acceptance, payment, delivery, or booking progress.';

  @override
  String get demoOrderViewHistory => 'View order history';

  @override
  String profileDemoOrdersSavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demo orders this session',
      one: '1 demo order this session',
      zero: 'No demo orders this session',
    );
    return '$_temp0';
  }

  @override
  String get businessCenterTitle => 'Business Center';

  @override
  String get profileBusinessCenterSubtitle =>
      'Business registration and application tracking';

  @override
  String get businessCenterIntroTitle => 'Manage your business (preview)';

  @override
  String get businessCenterIntroBody =>
      'This MVP demonstrates how a business owner might prepare a profile. Nothing here is published publicly or saved to a server.';

  @override
  String get businessCenterSessionNotice =>
      'Drafts exist only in this browser session and disappear after a refresh or restart.';

  @override
  String get businessCenterYourProfilesTitle => 'Your session drafts';

  @override
  String get businessCenterEmptyDraftsTitle => 'No drafts yet';

  @override
  String get businessCenterEmptyDraftsBody =>
      'Create a business profile to preview how your listing could look. It stays on this device only.';

  @override
  String get businessCenterCreateProfile => 'Create profile';

  @override
  String get businessCenterSampleSectionTitle => 'Example profile';

  @override
  String get businessCenterSampleSectionBody =>
      'Read-only fictional demo — not a verified business and not shown to customers in Search or Home.';

  @override
  String get businessProfileSampleBadge => 'Sample demo';

  @override
  String get businessPlannedSectionTitle => 'Coming in later phases';

  @override
  String get businessPlannedSectionBody =>
      'Planned business capabilities (not available in this MVP):';

  @override
  String get businessPlannedProducts => 'Products and services management';

  @override
  String get businessPlannedAvailability => 'Availability and inventory';

  @override
  String get businessPlannedOrders => 'Orders and bookings';

  @override
  String get businessPlannedRental => 'Rental scheduling and deposits';

  @override
  String get businessPlannedStaff => 'Staff and permissions';

  @override
  String get businessPlannedAnalytics => 'Business analytics';

  @override
  String get businessSampleRentalName => 'Sample — Perforator and tool rental';

  @override
  String get businessSampleRentalDescription =>
      'Fictional rental shop example for the Business Center demo. No real inventory, prices, or bookings.';

  @override
  String get businessSampleRentalAddress =>
      'Demo District, Sample Workshop Lane 3 (not a real address)';

  @override
  String get businessSampleRentalHours => 'Mon–Sat, 9:00–18:00 (demo hours)';

  @override
  String get businessSampleRentalPhone => '+998 00 000 00 00 (example)';

  @override
  String get businessProfileDetailTitle => 'Business profile';

  @override
  String get businessProfileEditAction => 'Edit';

  @override
  String get businessProfileSampleReadOnlyNotice =>
      'This is a read-only sample profile for demonstration. It is not published and cannot be edited directly.';

  @override
  String get businessProfileDraftLocalNotice =>
      'This is a local draft only. Saving does not publish your business or contact customers.';

  @override
  String get businessProfileCopySampleToDraft => 'Copy example into new draft';

  @override
  String get businessProfileNotFoundTitle => 'Profile not found';

  @override
  String get businessProfileNotFoundBody =>
      'This profile is not available in the current session. Return to Business Center and try again.';

  @override
  String get businessProfileFormCreateTitle => 'New business profile';

  @override
  String get businessProfileFormEditTitle => 'Edit business profile';

  @override
  String get businessProfileFormLocalSaveNotice =>
      'Changes are stored locally for this session only — not published online.';

  @override
  String get businessProfileFieldName => 'Business name';

  @override
  String get businessProfileFieldCategory => 'Category';

  @override
  String get businessProfileFieldDescription => 'Description';

  @override
  String get businessProfileFieldAddress => 'Address or location';

  @override
  String get businessProfileFieldHours => 'Working hours';

  @override
  String get businessProfileFieldPhone => 'Contact phone';

  @override
  String get businessProfileFieldPhoneOptional => 'Contact phone (optional)';

  @override
  String get businessProfileValidationNameRequired => 'Enter a business name';

  @override
  String get businessProfileValidationDescriptionRequired =>
      'Enter a description';

  @override
  String get businessProfileValidationAddressRequired =>
      'Enter an address or location';

  @override
  String get businessProfileValidationHoursRequired => 'Enter working hours';

  @override
  String get businessProfileSaveAction => 'Save draft';

  @override
  String get businessProfileCancelAction => 'Cancel';

  @override
  String get businessOfferingsSectionTitle => 'Products & services';

  @override
  String get businessOfferingAddAction => 'Add item';

  @override
  String get businessOfferingsOwnerNotice =>
      'Local demo catalog for your draft only — not visible to customers in Search or Home.';

  @override
  String get businessOfferingsSampleNotice =>
      'Demonstration listings only — not editable and not published.';

  @override
  String get businessOfferingsEmptyOwner =>
      'No offerings yet. Add a product, service, or rental item to preview your catalog.';

  @override
  String get businessOfferingsEmptySample =>
      'This sample profile has no demonstration items while samples are disabled.';

  @override
  String get businessOfferingKindProduct => 'Product';

  @override
  String get businessOfferingKindService => 'Service';

  @override
  String get businessOfferingKindRental => 'Rental item';

  @override
  String get businessPricingUnitPerItem => 'per item';

  @override
  String get businessPricingUnitPerHour => 'per hour';

  @override
  String get businessPricingUnitPerDay => 'per day';

  @override
  String get businessOfferingNoDemoPrice => 'No demo sample price';

  @override
  String businessOfferingDemoPriceLine(String amount, String unit) {
    return 'Demo sample: $amount ($unit)';
  }

  @override
  String businessOfferingDemoDepositLine(String amount) {
    return 'Demo deposit (not charged): $amount';
  }

  @override
  String get businessOfferingEditAction => 'Edit offering';

  @override
  String get businessOfferingDeleteAction => 'Remove offering';

  @override
  String get businessOfferingDeleteConfirmTitle => 'Remove offering?';

  @override
  String get businessOfferingDeleteConfirmBody =>
      'Remove this offering from your local draft? This cannot be undone after refresh.';

  @override
  String get businessOfferingDeleteConfirmYes => 'Remove';

  @override
  String get businessOfferingFormCreateTitle => 'New offering';

  @override
  String get businessOfferingFormEditTitle => 'Edit offering';

  @override
  String get businessOfferingFormLocalNotice =>
      'Offerings stay on this device for the session only — not published to customers.';

  @override
  String get businessOfferingFieldName => 'Offering name';

  @override
  String get businessOfferingFieldKind => 'Type';

  @override
  String get businessOfferingFieldDescription => 'Short description';

  @override
  String get businessOfferingFieldPricingUnit => 'Pricing unit';

  @override
  String get businessOfferingFieldDemoPriceOptional =>
      'Demo sample price (UZS, optional)';

  @override
  String get businessOfferingFieldDemoDepositOptional =>
      'Demo deposit (UZS, optional)';

  @override
  String get businessOfferingValidationNameRequired => 'Enter an offering name';

  @override
  String get businessOfferingValidationDescriptionRequired =>
      'Enter a description';

  @override
  String get businessOfferingValidationUzsInvalid =>
      'Enter a valid non-negative whole number in soums';

  @override
  String get businessOfferingSaveAction => 'Save offering';

  @override
  String get businessOfferingProfileNotEditable =>
      'Offerings can only be managed for your own session drafts.';

  @override
  String get businessOfferingNotFoundBody =>
      'This offering was not found or does not belong to this profile.';

  @override
  String get businessSampleOfferingPerforatorName =>
      'Sample — perforator (rental demo)';

  @override
  String get businessSampleOfferingPerforatorDesc =>
      'Fictional tool rental listing for demonstration. No calendar, availability, or real deposit.';

  @override
  String get businessInventorySummaryTitle => 'Inventory & availability';

  @override
  String businessInventorySummaryCounts(
    int configured,
    int total,
    int active,
    int paused,
  ) {
    return 'Configured $configured of $total offerings · Active $active · Paused $paused';
  }

  @override
  String get businessInventorySummaryNotice =>
      'Demo quantities and pause flags are manual and local — not synced to customers or reservations.';

  @override
  String get businessInventoryManageAction => 'Manage inventory & availability';

  @override
  String get businessInventoryPageTitle => 'Inventory & availability';

  @override
  String get businessInventoryPageIntro =>
      'Set demo stock or pause flags for your session offerings. This is not a live reservation system.';

  @override
  String get businessInventoryProfileNotEditable =>
      'Inventory can only be managed for your own session drafts.';

  @override
  String get businessInventoryNoOfferingsTitle => 'No offerings yet';

  @override
  String get businessInventoryNoOfferingsBody =>
      'Add products, services, or rental items on the profile page before configuring inventory.';

  @override
  String get businessInventoryBackToProfile => 'Back to profile';

  @override
  String get businessInventoryNotConfigured => 'Not configured';

  @override
  String get businessInventoryStateActive => 'Active';

  @override
  String get businessInventoryStatePaused => 'Paused';

  @override
  String businessInventoryServiceStatus(String state) {
    return 'Status: $state (demo — no appointment schedule)';
  }

  @override
  String businessInventoryProductStock(int available, int total, String state) {
    return '$available available of $total · $state';
  }

  @override
  String businessInventoryRentalUnits(int available, int total, String state) {
    return '$available available of $total units · $state (manual demo count)';
  }

  @override
  String get businessInventoryConfigureAction => 'Configure';

  @override
  String get businessInventoryEditAction => 'Edit inventory';

  @override
  String get businessInventoryEditTitle => 'Edit inventory';

  @override
  String get businessInventoryLocalNotice =>
      'Local demo settings only — not published to the consumer app.';

  @override
  String get businessInventoryRentalManualNotice =>
      'Available units are entered manually for demo. Reservations and returns do not update this count automatically.';

  @override
  String get businessInventoryAvailabilityToggle => 'Offering active';

  @override
  String get businessInventoryFieldStockTotal => 'Total stock (units)';

  @override
  String get businessInventoryFieldStockAvailable => 'Available stock (units)';

  @override
  String get businessInventoryFieldTotalUnits => 'Total equipment units';

  @override
  String get businessInventoryFieldAvailableUnits => 'Available units now';

  @override
  String get businessInventoryValidationQuantityRequired => 'Enter a quantity';

  @override
  String get businessInventoryValidationQuantityInvalid =>
      'Enter a valid non-negative whole number';

  @override
  String get businessInventoryValidationAvailableExceedsTotal =>
      'Available quantity cannot exceed total';

  @override
  String get businessInventorySaveAction => 'Save inventory';

  @override
  String get authSignInAction => 'Sign in';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignOutAction => 'Sign out';

  @override
  String get authPhonePrompt =>
      'Enter your phone number in international format. We will send a one-time code when sign-in is available.';

  @override
  String get authPhoneFieldLabel => 'Phone number';

  @override
  String get authPhoneHint => '+998901234567';

  @override
  String get authPhoneInvalid =>
      'Enter a valid international phone number, for example +998901234567.';

  @override
  String get authRequestOtpAction => 'Send code';

  @override
  String get authOtpPrompt =>
      'Enter the verification code sent to your phone when delivery is configured.';

  @override
  String get authOtpFieldLabel => 'Verification code';

  @override
  String get authVerifyAction => 'Verify';

  @override
  String get authChangePhoneAction => 'Use a different number';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authApiNotConfigured =>
      'Sign-in server is not configured for this build. Set QOSHNI_API_BASE_URL at compile time.';

  @override
  String get authErrorServiceUnavailable =>
      'Sign-in is temporarily unavailable. SMS delivery may not be configured yet.';

  @override
  String get authErrorRateLimited =>
      'Too many attempts. Please wait and try again.';

  @override
  String get authErrorCodeIncorrect => 'Incorrect verification code.';

  @override
  String get authErrorChallengeExpired =>
      'This code has expired. Request a new one.';

  @override
  String get authErrorChallengeLocked =>
      'Too many incorrect attempts. Request a new code.';

  @override
  String get authErrorNetwork =>
      'Network connection failed. Check your connection and try again.';

  @override
  String get authErrorGeneric => 'Sign-in failed. Please try again.';

  @override
  String get authSignedInTitle => 'Signed in';

  @override
  String get authSignedInBody =>
      'Your phone identity is verified for this session.';

  @override
  String get authSessionsAction => 'Manage sessions';

  @override
  String get authSessionsTitle => 'Your sessions';

  @override
  String get authSessionsEmpty => 'No sessions to show.';

  @override
  String get authSessionUnknownDevice => 'Unknown device';

  @override
  String get authSessionStateActive => 'Active';

  @override
  String get authSessionStateExpired => 'Expired';

  @override
  String get authSessionStateRevoked => 'Revoked';

  @override
  String get authSessionCurrentBadge => 'Current';

  @override
  String get authSessionExpiredNotice =>
      'Your session ended. You can sign in again when the service is available.';

  @override
  String get userProfileDisplayNameHint => 'Display name';

  @override
  String get userProfileDisplayNameEmpty => 'No display name yet';

  @override
  String get userProfileEditDisplayNameAction => 'Edit display name';

  @override
  String get userProfileClearDisplayNameAction => 'Clear display name';

  @override
  String get userProfileSaveAction => 'Save';

  @override
  String get userProfileCancelAction => 'Cancel';

  @override
  String get userProfileRetryAction => 'Try again';

  @override
  String get userProfileLoadError => 'Could not load your profile.';

  @override
  String get userProfileSaveSuccess => 'Profile updated.';

  @override
  String get userProfilePreferencesSaveSuccess => 'Preferences saved.';

  @override
  String get userProfileApiNotConfigured =>
      'Account server is not configured for this build. Set QOSHNI_API_BASE_URL at compile time.';

  @override
  String get userProfileErrorNetwork =>
      'Network connection failed. Check your connection and try again.';

  @override
  String get userProfileErrorServiceUnavailable =>
      'Profile service is temporarily unavailable.';

  @override
  String get userProfileNotFound =>
      'Your profile is not available yet. Try again or sign in again.';

  @override
  String get userProfilePreferencesNotFound =>
      'Your preferences are not available yet. Try again or sign in again.';

  @override
  String get userProfileErrorValidation =>
      'That value is not allowed. Check the display name or language and try again.';

  @override
  String get userProfileErrorGeneric =>
      'Something went wrong. Please try again.';

  @override
  String get userProfileSectionPersonalization => 'Personalization';

  @override
  String get userProfilePersonalizationTitle => 'Personalized suggestions';

  @override
  String get userProfilePersonalizationBody =>
      'When enabled, QO‘SHNI may use your explicit preferences to tailor suggestions. This stays off until you turn it on.';

  @override
  String get userProfileSaving => 'Saving…';

  @override
  String get businessCenterOnboardingTitle => 'Business registration';

  @override
  String get businessCenterOnboardingBody =>
      'Submit a verification application, upload documents, and track review status with your signed-in account.';

  @override
  String get businessCenterOnboardingAction => 'Open registration';

  @override
  String get onboardingHubTitle => 'Business registration';

  @override
  String get onboardingHubIntroTitle => 'Register your business';

  @override
  String get onboardingHubIntroBody =>
      'Create an application, complete the form, upload required documents, and submit for review. Status updates come from the server.';

  @override
  String get onboardingHubEmptyTitle => 'No applications yet';

  @override
  String get onboardingHubEmptyBody =>
      'Start a new application to register your business for verification.';

  @override
  String get onboardingCreateApplication => 'New application';

  @override
  String get onboardingUntitledApplication => 'Untitled application';

  @override
  String get onboardingSignInPrompt =>
      'Sign in to view and manage your business registration applications.';

  @override
  String get onboardingApplicationTitle => 'Application';

  @override
  String get onboardingTabForm => 'Details';

  @override
  String get onboardingTabDocuments => 'Documents';

  @override
  String get onboardingTabStatus => 'Status';

  @override
  String get onboardingFormReadOnlyNotice =>
      'This application is no longer a draft. Details are read-only while review is in progress or complete.';

  @override
  String get onboardingFieldLegalName => 'Legal business name';

  @override
  String get onboardingFieldTradeName => 'Trade / display name (optional)';

  @override
  String get onboardingFieldServiceCategory => 'Service category';

  @override
  String get onboardingFieldJurisdiction =>
      'Registration jurisdiction (ISO code)';

  @override
  String get onboardingFieldRegistrationId =>
      'Registration identifier (optional)';

  @override
  String get onboardingFieldTaxIdOptional => 'Tax identifier (optional)';

  @override
  String get onboardingFieldContactEmailOptional =>
      'Business contact email (optional)';

  @override
  String get onboardingValidationLegalNameRequired =>
      'Enter the legal business name';

  @override
  String get onboardingValidationCategoryRequired =>
      'Select a service category';

  @override
  String get onboardingValidationJurisdictionInvalid =>
      'Enter a two-letter jurisdiction code (e.g. UZ)';

  @override
  String get onboardingValidationEmailInvalid => 'Enter a valid email address';

  @override
  String get onboardingSaveDraftAction => 'Save draft';

  @override
  String get onboardingSubmitAction => 'Submit for review';

  @override
  String get onboardingDraftSaved => 'Draft saved.';

  @override
  String get onboardingSubmitSuccess => 'Application submitted for review.';

  @override
  String get onboardingCategoryGroceries => 'Groceries';

  @override
  String get onboardingCategoryRestaurants => 'Restaurants';

  @override
  String get onboardingCategoryPharmacy => 'Pharmacy';

  @override
  String get onboardingCategoryShops => 'Shops';

  @override
  String get onboardingCategoryMasters => 'Masters & services';

  @override
  String get onboardingCategoryRent => 'Rent';

  @override
  String get onboardingDocumentsIntro =>
      'Register each document type, then upload PDF, JPEG, or PNG files up to 10 MiB.';

  @override
  String get onboardingDocumentsEmpty =>
      'No documents registered yet. Add a document type below.';

  @override
  String get onboardingRegisterDocumentTitle => 'Add document';

  @override
  String get onboardingUploadAction => 'Choose file & upload';

  @override
  String get onboardingUploadTooLarge =>
      'File is larger than 10 MiB. Choose a smaller file.';

  @override
  String get onboardingUploadReadFailed => 'Could not read the selected file.';

  @override
  String get onboardingUploadSuccess => 'Upload completed.';

  @override
  String get onboardingDocTypeRegistrationCertificate =>
      'Registration certificate';

  @override
  String get onboardingDocTypeTaxRegistration => 'Tax registration';

  @override
  String get onboardingDocTypeRepresentativeId =>
      'Authorized representative ID';

  @override
  String get onboardingDocTypeOtherSupporting => 'Other supporting document';

  @override
  String get onboardingVerificationCurrentStatus => 'Current status';

  @override
  String get onboardingVerificationSubmittedAt => 'Submitted';

  @override
  String get onboardingVerificationReviewedAt => 'Reviewed';

  @override
  String get onboardingVerificationRejectionTitle => 'Rejection reason';

  @override
  String get onboardingNextStepsDraft =>
      'Complete the form, upload documents, then submit when ready.';

  @override
  String get onboardingNextStepsSubmitted =>
      'Your application was submitted. You will be notified when review starts.';

  @override
  String get onboardingNextStepsUnderReview =>
      'Our team is reviewing your application. You may be asked for additional documents.';

  @override
  String get onboardingNextStepsVerified =>
      'Your business is verified. Further product features will arrive in later phases.';

  @override
  String get onboardingNextStepsRejected =>
      'Your application was rejected. Review the reason, update your draft if allowed, or contact support.';

  @override
  String get onboardingNextStepsSuspended =>
      'Your application is suspended. Contact support for next steps.';

  @override
  String get onboardingNextStepsGeneric => 'Check back later for updates.';

  @override
  String get onboardingErrorNotFound => 'Application not found.';

  @override
  String get onboardingErrorForbidden =>
      'You do not have access to this application.';

  @override
  String get onboardingErrorInvalidTransition =>
      'This action is not allowed for the current status.';

  @override
  String get onboardingErrorValidation =>
      'Some fields are invalid. Check the form and try again.';

  @override
  String get onboardingErrorUnavailable =>
      'Service temporarily unavailable. Try again later.';

  @override
  String get onboardingErrorScanUnavailable =>
      'Document scanning is temporarily unavailable.';

  @override
  String get onboardingErrorDocumentRejected =>
      'The document was rejected. Register a new document and upload again.';

  @override
  String get onboardingErrorSuspended => 'This application is suspended.';

  @override
  String get onboardingErrorSignInRequired => 'Sign in to continue.';

  @override
  String get onboardingErrorApiNotConfigured =>
      'Registration server is not configured for this build. Set QOSHNI_API_BASE_URL at compile time.';

  @override
  String get onboardingErrorNetwork =>
      'Network connection failed. Check your connection and try again.';

  @override
  String get onboardingErrorUnexpected =>
      'Something went wrong. Please try again.';

  @override
  String get onboardingStatusDraft => 'Draft';

  @override
  String get onboardingStatusSubmitted => 'Submitted';

  @override
  String get onboardingStatusUnderReview => 'Under review';

  @override
  String get onboardingStatusVerified => 'Verified';

  @override
  String get onboardingStatusRejected => 'Rejected';

  @override
  String get onboardingStatusSuspended => 'Suspended';

  @override
  String get onboardingDocAwaitingUpload => 'Awaiting upload';

  @override
  String get onboardingDocUploadedPending => 'Uploaded — pending validation';

  @override
  String get onboardingDocQuarantined => 'Quarantined';

  @override
  String get onboardingDocRejected => 'Rejected';

  @override
  String get onboardingDocAcceptedForReview => 'Accepted for review';

  @override
  String get onboardingDocDeleted => 'Deleted';

  @override
  String get onboardingRejectionIncomplete => 'Incomplete information';

  @override
  String get onboardingRejectionMismatch => 'Registration mismatch';

  @override
  String get onboardingRejectionJurisdiction => 'Unsupported jurisdiction';

  @override
  String get onboardingRejectionPolicy => 'Policy violation';

  @override
  String get onboardingRejectionOther => 'Other';

  @override
  String get businessCenterOwnerProfileTitle => 'Business profile';

  @override
  String get businessCenterOwnerProfileBody =>
      'Preview your business-level profile. Saved only in this session until backend sync arrives.';

  @override
  String get ownerProfileOverviewTitle => 'Business profile';

  @override
  String get ownerProfilePreviewNotice =>
      'Preview — saved only in this session. Not published or verified.';

  @override
  String get ownerProfileStatusLabel => 'Profile status';

  @override
  String get ownerProfileStatusPreview => 'Preview draft';

  @override
  String get ownerProfileCompletenessLabel => 'Profile completeness';

  @override
  String get ownerProfileEditAction => 'Edit profile';

  @override
  String get ownerProfileViewAction => 'View profile';

  @override
  String get ownerProfileSectionBasics => 'Basic information';

  @override
  String get ownerProfileSectionContact => 'Contact';

  @override
  String get ownerProfileSectionSettings => 'Preview settings';

  @override
  String get ownerProfileLegalName => 'Legal business name';

  @override
  String get ownerProfileDisplayName => 'Display name';

  @override
  String get ownerProfileDescription => 'Business description';

  @override
  String get ownerProfileCategory => 'Service category';

  @override
  String get ownerProfileContactPhone => 'Contact phone';

  @override
  String get ownerProfileContactEmail => 'Contact email';

  @override
  String get ownerProfileWebsite => 'Website (preview)';

  @override
  String get ownerProfileVisibility => 'Profile visibility (preview)';

  @override
  String get ownerProfileVisibilityHidden => 'Hidden in preview';

  @override
  String get ownerProfileVisibilityVisible => 'Visible in preview UI only';

  @override
  String get ownerProfileEditorTitle => 'Edit business profile';

  @override
  String get ownerProfileSaveAction => 'Save changes';

  @override
  String get ownerProfileCancelAction => 'Cancel';

  @override
  String get ownerProfileSaveSuccess => 'Profile saved for this session.';

  @override
  String get ownerProfileSaveFailed =>
      'Could not save. Your edits are still in the form.';

  @override
  String get ownerProfileDiscardConfirmTitle => 'Discard changes?';

  @override
  String get ownerProfileDiscardConfirmBody => 'Unsaved edits will be lost.';

  @override
  String get ownerProfileDiscardConfirmAction => 'Discard';

  @override
  String get ownerProfileValidationLegalName => 'Enter the legal business name';

  @override
  String get ownerProfileValidationDisplayName => 'Enter a display name';

  @override
  String get ownerProfileValidationDescription =>
      'Enter a business description';

  @override
  String get ownerProfileValidationEmail => 'Enter a valid email address';

  @override
  String get ownerProfileValidationWebsite => 'Enter a valid website URL';

  @override
  String get businessCenterBranchesTitle => 'Branches';

  @override
  String get businessCenterBranchesBody =>
      'Manage branch locations, hours, and contacts in preview mode.';

  @override
  String get branchListTitle => 'Branches';

  @override
  String get branchPreviewNotice =>
      'Preview — branches are saved only in this session. Not published to search or maps.';

  @override
  String get branchProfileIncompleteNotice =>
      'Complete your business profile preview before branches can sync to a real business later.';

  @override
  String get branchOpenBusinessProfileAction => 'Open business profile';

  @override
  String get branchAddAction => 'Add branch';

  @override
  String get branchEmptyTitle => 'No branches yet';

  @override
  String get branchEmptyBody =>
      'Add a preview branch to plan locations and opening hours.';

  @override
  String get branchStatusActive => 'Active';

  @override
  String get branchStatusInactive => 'Inactive';

  @override
  String get branchScheduleClosedAllWeek => 'Closed all week';

  @override
  String get branchDetailTitle => 'Branch details';

  @override
  String get branchEditAction => 'Edit branch';

  @override
  String get branchNotFoundTitle => 'Branch not found';

  @override
  String get branchNotFoundBody =>
      'This branch is not in your session preview.';

  @override
  String get branchBackToListAction => 'Back to branches';

  @override
  String get branchSectionBasics => 'Basic information';

  @override
  String get branchSectionHours => 'Opening hours';

  @override
  String get branchSectionLocation => 'Location (preview)';

  @override
  String get branchFieldName => 'Branch name';

  @override
  String get branchFieldCity => 'City';

  @override
  String get branchFieldAddress => 'Address';

  @override
  String get branchFieldPhone => 'Contact phone';

  @override
  String get branchFieldStatus => 'Branch status';

  @override
  String get branchFieldOpenTime => 'Opens';

  @override
  String get branchFieldCloseTime => 'Closes';

  @override
  String get branchFieldLatitude => 'Latitude (demo)';

  @override
  String get branchFieldLongitude => 'Longitude (demo)';

  @override
  String get branchDayClosed => 'Closed';

  @override
  String get branchLocationDemoHint =>
      'Demo coordinates only — no map or geocoding in this phase.';

  @override
  String get branchEditorCreateTitle => 'New branch';

  @override
  String get branchEditorEditTitle => 'Edit branch';

  @override
  String get branchSaveAction => 'Save branch';

  @override
  String get branchCancelAction => 'Cancel';

  @override
  String get branchSaveSuccess => 'Branch saved for this session.';

  @override
  String get branchSaveFailed =>
      'Could not save. Your edits are still in the form.';

  @override
  String get branchDiscardConfirmTitle => 'Discard changes?';

  @override
  String get branchDiscardConfirmBody => 'Unsaved branch edits will be lost.';

  @override
  String get branchDiscardConfirmAction => 'Discard';

  @override
  String get branchValidationName => 'Enter a branch name';

  @override
  String get branchValidationCity => 'Enter a city';

  @override
  String get branchValidationAddress => 'Enter an address';

  @override
  String get branchValidationPhone => 'Enter a valid phone number';

  @override
  String get branchValidationTime => 'Use HH:MM format for opening hours';

  @override
  String get branchValidationTimeOrder =>
      'Closing time must be after opening time';

  @override
  String get branchValidationCoordinates => 'Enter valid coordinates';

  @override
  String get branchWeekdayMonday => 'Monday';

  @override
  String get branchWeekdayTuesday => 'Tuesday';

  @override
  String get branchWeekdayWednesday => 'Wednesday';

  @override
  String get branchWeekdayThursday => 'Thursday';

  @override
  String get branchWeekdayFriday => 'Friday';

  @override
  String get branchWeekdaySaturday => 'Saturday';

  @override
  String get branchWeekdaySunday => 'Sunday';

  @override
  String get businessCenterStaffTitle => 'Staff & roles';

  @override
  String get businessCenterStaffBody =>
      'Preview team members, roles, and branch access for this session only.';

  @override
  String get staffListTitle => 'Staff & roles';

  @override
  String get staffPreviewNotice =>
      'Preview — no SMS, email, or real invites. Saved only in this session.';

  @override
  String get staffAddAction => 'Add staff member';

  @override
  String get staffEmptyTitle => 'No staff yet';

  @override
  String get staffEmptyBody => 'Add a preview team member and assign branches.';

  @override
  String get staffEditAction => 'Edit';

  @override
  String get staffDetailTitle => 'Staff member';

  @override
  String get staffNotFoundTitle => 'Staff member not found';

  @override
  String get staffNotFoundBody =>
      'This preview staff member is not in your session.';

  @override
  String get staffBackToListAction => 'Back to staff list';

  @override
  String get staffSectionBasics => 'Basic information';

  @override
  String get staffSectionRole => 'Business role';

  @override
  String get staffSectionBranches => 'Assigned branches';

  @override
  String get staffFieldFirstName => 'First name';

  @override
  String get staffFieldLastName => 'Last name';

  @override
  String get staffFieldPhone => 'Phone';

  @override
  String get staffFieldEmail => 'Email';

  @override
  String get staffFieldEmailOptional => 'Email (optional)';

  @override
  String get staffFieldRole => 'Role';

  @override
  String get staffFieldActive => 'Active in preview';

  @override
  String get staffFieldActiveHint =>
      'Inactive marks the member as removed in preview only.';

  @override
  String get staffBranchSelectionHint =>
      'Select at least one branch. Permissions apply only to assigned branches.';

  @override
  String get staffNoBranchesAvailable =>
      'Add a preview branch before assigning staff.';

  @override
  String get staffEditorCreateTitle => 'New staff member';

  @override
  String get staffEditorEditTitle => 'Edit staff member';

  @override
  String get staffSaveAction => 'Save staff member';

  @override
  String get staffCancelAction => 'Cancel';

  @override
  String get staffSaveSuccess => 'Staff member saved for this session.';

  @override
  String get staffSaveFailed =>
      'Could not save. Your edits are still in the form.';

  @override
  String get staffDiscardConfirmTitle => 'Discard changes?';

  @override
  String get staffDiscardConfirmBody => 'Unsaved staff edits will be lost.';

  @override
  String get staffDiscardConfirmAction => 'Discard';

  @override
  String get staffValidationFirstName => 'Enter a first name';

  @override
  String get staffValidationPhone => 'Enter a valid phone number';

  @override
  String get staffValidationEmail => 'Enter a valid email address';

  @override
  String get staffValidationRoleNotAssignable =>
      'This role cannot be assigned here.';

  @override
  String get staffValidationBranchRequired => 'Select at least one branch.';

  @override
  String get staffInvalidScopeMessage =>
      'One or more branches are not available in this preview scope.';

  @override
  String get staffOwnerNotEditableMessage =>
      'The preview business owner cannot be edited from this form.';

  @override
  String get staffRoleBusinessOwner => 'Business owner';

  @override
  String get staffRoleBusinessAdmin => 'Business admin';

  @override
  String get staffRoleBranchManager => 'Branch manager';

  @override
  String get staffRoleStaff => 'Staff';

  @override
  String get staffRoleReadOnly => 'Read-only';

  @override
  String get staffStatusActivePreview => 'Active (preview)';

  @override
  String get staffStatusInvitePendingPreview => 'Invite pending (preview only)';

  @override
  String get staffStatusRemovedPreview => 'Removed (preview)';

  @override
  String staffBranchesLabel(String names) {
    return 'Branches: $names';
  }

  @override
  String get staffPermissionPreviewTitle => 'Permission preview';

  @override
  String get staffPermissionPreviewDisclaimer =>
      'Demo UI only — backend authorization is not connected yet.';

  @override
  String get staffPermSummaryOwner =>
      'Full business control in preview (not assignable to new staff).';

  @override
  String get staffPermSummaryAdmin =>
      'Manage branches and staff across the business preview.';

  @override
  String get staffPermSummaryBranchManager =>
      'Operate within assigned branches only.';

  @override
  String get staffPermSummaryStaff =>
      'Day-to-day tasks within assigned branches.';

  @override
  String get staffPermSummaryReadOnly => 'View preview data without editing.';

  @override
  String get staffPermManageBusiness => 'Manage business preview settings';

  @override
  String get staffPermManageBranches => 'Manage branch preview records';

  @override
  String get staffPermManageStaff => 'Manage staff preview records';

  @override
  String get staffPermViewReports => 'View preview reports';

  @override
  String get staffPermManageAssignedBranches =>
      'Manage assigned branch preview data';

  @override
  String get staffPermViewBranchReports =>
      'View assigned branch preview reports';

  @override
  String get staffPermExecuteAssignedTasks =>
      'Execute tasks in assigned branches';

  @override
  String get staffPermViewAssignedBranch => 'View assigned branch preview data';

  @override
  String get staffPermViewBusinessPreview =>
      'View business preview data (read-only)';

  @override
  String get businessCenterBranchPermissionsTitle => 'Branch permissions';

  @override
  String get businessCenterBranchPermissionsBody =>
      'Preview staff access and actions per branch for this session only.';

  @override
  String get branchPermPageTitle => 'Branch permissions';

  @override
  String get branchPermPreviewNotice =>
      'Preview — permissions are saved only in this session. Real server permissions are not connected yet.';

  @override
  String get branchPermSelectStaff => 'Staff member';

  @override
  String get branchPermSelectBranch => 'Branch';

  @override
  String get branchPermAccessStatusTitle => 'Branch access';

  @override
  String get branchPermAccessGrantedPreview =>
      'Assigned to this branch (preview)';

  @override
  String get branchPermAccessNonePreview =>
      'No access — staff is not assigned to this branch';

  @override
  String get branchPermUnassignedBranchHint =>
      'Assign the staff member to this branch in Staff & roles before granting branch permissions.';

  @override
  String get branchPermOwnerNotEditable =>
      'The preview business owner permissions cannot be changed here.';

  @override
  String get branchPermRoleSuggestedHint =>
      'Role suggestions differ from explicit branch permissions you set below.';

  @override
  String get branchPermSuggestedVsExplicitNotice =>
      'Suggested role capabilities are guidance only — toggles below are explicit preview permissions for this branch.';

  @override
  String get branchPermGroupView => 'View';

  @override
  String get branchPermGroupEdit => 'Edit';

  @override
  String get branchPermGroupStaff => 'Staff management';

  @override
  String get branchPermViewBranch => 'View branch';

  @override
  String get branchPermEditBranchProfile => 'Edit branch profile';

  @override
  String get branchPermManageBranchHours => 'Manage branch hours';

  @override
  String get branchPermViewStaff => 'View staff';

  @override
  String get branchPermManageBranchStaff => 'Manage branch staff';

  @override
  String get branchPermViewBusinessProfile => 'View business profile';

  @override
  String get branchPermDescViewBranch => 'See branch details in preview.';

  @override
  String get branchPermDescEditBranchProfile =>
      'Edit branch name, address, and contacts in preview.';

  @override
  String get branchPermDescManageBranchHours =>
      'Edit opening hours in preview.';

  @override
  String get branchPermDescViewStaff =>
      'See staff linked to this branch in preview.';

  @override
  String get branchPermDescManageBranchStaff =>
      'Assign or remove staff for this branch in preview.';

  @override
  String get branchPermDescViewBusinessProfile =>
      'See business-level profile in preview.';

  @override
  String get branchPermSaveAction => 'Save permissions';

  @override
  String get branchPermCancelAction => 'Cancel';

  @override
  String get branchPermSaveSuccess =>
      'Branch permissions saved for this session.';

  @override
  String get branchPermSaveFailed =>
      'Could not save. Your changes are still on screen.';

  @override
  String get branchPermInvalidScopeMessage =>
      'Invalid staff or branch for this business preview scope.';

  @override
  String get branchPermDiscardConfirmTitle => 'Discard changes?';

  @override
  String get branchPermDiscardConfirmBody =>
      'Unsaved permission changes will be lost.';

  @override
  String get branchPermDiscardConfirmAction => 'Discard';

  @override
  String get businessCenterCatalogTitle => 'Catalog';

  @override
  String get businessCenterCatalogBody =>
      'Preview categories and catalog stats for this business session only.';

  @override
  String get catalogHomeTitle => 'Catalog';

  @override
  String get catalogPreviewNotice =>
      'Preview — catalog data is saved only in this session. Not connected to public search or customer orders.';

  @override
  String get catalogHomeIntro =>
      'Organize products and services for your business preview. Customer-facing catalog sync arrives in a later phase.';

  @override
  String get catalogStatCategories => 'Categories';

  @override
  String get catalogStatProducts => 'Products';

  @override
  String get catalogStatServices => 'Services';

  @override
  String get catalogStatActiveItems => 'Active items';

  @override
  String get catalogStatDraftItems => 'Draft items';

  @override
  String get catalogManageCategoriesTitle => 'Manage categories';

  @override
  String get catalogManageCategoriesBody =>
      'Create and edit multilingual categories for this business preview.';

  @override
  String get catalogProductsSectionTitle => 'Products';

  @override
  String get catalogProductsSectionBody =>
      'Manage preview products for this business session.';

  @override
  String get catalogServicesSectionTitle => 'Services';

  @override
  String get catalogServicesSectionBody =>
      'Manage preview services for this business session.';

  @override
  String get catalogComingSoonLabel => 'Next phase';

  @override
  String get catalogCategoryListTitle => 'Categories';

  @override
  String get catalogCategoryAddAction => 'Add category';

  @override
  String get catalogCategorySearchLabel => 'Search categories';

  @override
  String get catalogCategoryEmptyTitle => 'No categories yet';

  @override
  String get catalogCategoryEmptyBody =>
      'Add a category to organize your business catalog preview.';

  @override
  String get catalogCategoryDetailTitle => 'Category';

  @override
  String get catalogCategoryEditAction => 'Edit';

  @override
  String get catalogCategoryCreateTitle => 'New category';

  @override
  String get catalogCategoryEditTitle => 'Edit category';

  @override
  String get catalogCategoryNotFoundTitle => 'Category not found';

  @override
  String get catalogCategoryNotFoundBody =>
      'This category is not in the current business preview scope.';

  @override
  String get catalogCategoryBackToListAction => 'Back to categories';

  @override
  String get catalogCategoryNamesSection => 'Names';

  @override
  String get catalogCategoryDescriptionsSection => 'Descriptions';

  @override
  String get catalogCategoryFieldEmpty => '—';

  @override
  String get catalogLanguageUz => 'Uzbek';

  @override
  String get catalogLanguageRu => 'Russian';

  @override
  String get catalogLanguageEn => 'English';

  @override
  String catalogCategoryParentLabel(String name) {
    return 'Parent: $name';
  }

  @override
  String get catalogCategoryStatusActive => 'Active';

  @override
  String get catalogCategoryStatusDraft => 'Draft';

  @override
  String get catalogCategoryStatusArchived => 'Archived';

  @override
  String get catalogCategoryFormNameHint =>
      'Provide a name in at least one language (Uzbek, Russian, or English).';

  @override
  String get catalogCategoryNameRequiredHint =>
      'Enter a category name in at least one language.';

  @override
  String get catalogCategoryNameUzLabel => 'Name (Uzbek)';

  @override
  String get catalogCategoryNameRuLabel => 'Name (Russian)';

  @override
  String get catalogCategoryNameEnLabel => 'Name (English)';

  @override
  String get catalogCategoryDescUzLabel => 'Description (Uzbek, optional)';

  @override
  String get catalogCategoryDescRuLabel => 'Description (Russian, optional)';

  @override
  String get catalogCategoryDescEnLabel => 'Description (English, optional)';

  @override
  String get catalogCategoryStatusLabel => 'Status';

  @override
  String get catalogCategoryParentFieldLabel => 'Parent category (optional)';

  @override
  String get catalogCategoryNoParent => 'No parent';

  @override
  String get catalogCategorySaveAction => 'Save';

  @override
  String get catalogCategoryCancelAction => 'Cancel';

  @override
  String get catalogCategorySaveSuccess => 'Category saved for this session.';

  @override
  String get catalogCategorySaveFailed =>
      'Could not save. Your entries are still on screen.';

  @override
  String get catalogCategoryDuplicateNameError =>
      'A category with this name already exists in this preview scope.';

  @override
  String get catalogCategoryInvalidParentError =>
      'Choose a valid parent category without circular hierarchy.';

  @override
  String get catalogCategoryDiscardConfirmTitle => 'Discard changes?';

  @override
  String get catalogCategoryDiscardConfirmBody =>
      'Unsaved category changes will be lost.';

  @override
  String get catalogCategoryDiscardCancelAction => 'Keep editing';

  @override
  String get catalogCategoryDiscardConfirmAction => 'Discard';

  @override
  String get catalogListingStatusActive => 'Active';

  @override
  String get catalogListingStatusDraft => 'Draft';

  @override
  String get catalogListingStatusArchived => 'Archived';

  @override
  String get catalogStatArchivedItems => 'Archived items';

  @override
  String get catalogListingSearchLabel => 'Search by name';

  @override
  String get catalogListingCategoryFilter => 'Category filter';

  @override
  String get catalogListingStatusFilter => 'Status filter';

  @override
  String get catalogListingAllCategories => 'All categories';

  @override
  String get catalogListingAllStatuses => 'All statuses';

  @override
  String get catalogListingClearFilters => 'Clear filters';

  @override
  String catalogListingFilteredCount(int filtered, int total) {
    return 'Showing $filtered of $total';
  }

  @override
  String get catalogListingCategoryField => 'Category';

  @override
  String get catalogListingCategoryRequired => 'Select a category.';

  @override
  String get catalogListingInvalidCategory =>
      'Category is not in this business preview scope.';

  @override
  String catalogListingCategoryLabel(String name) {
    return 'Category: $name';
  }

  @override
  String catalogHomeFilteredCount(int filtered, int total) {
    return 'Showing $filtered of $total in preview';
  }

  @override
  String get catalogProductListTitle => 'Products';

  @override
  String get catalogProductAddAction => 'Add product';

  @override
  String get catalogProductEmptyBody => 'No products match your filters.';

  @override
  String get catalogProductDetailTitle => 'Product';

  @override
  String get catalogProductCreateTitle => 'New product';

  @override
  String get catalogProductEditTitle => 'Edit product';

  @override
  String get catalogProductNotFoundTitle => 'Product not found';

  @override
  String get catalogProductBackToListAction => 'Back to products';

  @override
  String get catalogProductSaveSuccess => 'Product saved for this session.';

  @override
  String get catalogProductSaveFailed =>
      'Could not save. Your entries are still on screen.';

  @override
  String get catalogProductAttributeKeyLabel => 'Attribute key (optional)';

  @override
  String get catalogProductAttributeValueLabel => 'Attribute value (optional)';

  @override
  String catalogProductVariantsTitle(int count) {
    return 'Variants ($count)';
  }

  @override
  String get catalogProductVariantsManageTitle => 'Product variants';

  @override
  String get catalogServiceListTitle => 'Services';

  @override
  String get catalogServiceAddAction => 'Add service';

  @override
  String get catalogServiceEmptyBody => 'No services match your filters.';

  @override
  String get catalogServiceDetailTitle => 'Service';

  @override
  String get catalogServiceCreateTitle => 'New service';

  @override
  String get catalogServiceEditTitle => 'Edit service';

  @override
  String get catalogServiceBackToListAction => 'Back to services';

  @override
  String get catalogServiceSaveSuccess => 'Service saved for this session.';

  @override
  String get catalogServiceSaveFailed =>
      'Could not save. Your entries are still on screen.';

  @override
  String get catalogServiceInvalidDuration =>
      'Duration must be a positive number of minutes.';

  @override
  String get catalogServiceDurationFieldOptional =>
      'Duration (minutes, optional)';

  @override
  String catalogServiceDurationLabel(int minutes) {
    return 'Duration: $minutes min';
  }

  @override
  String get catalogVariantAddAction => 'Add variant';

  @override
  String get catalogVariantEmptyBody => 'No variants yet for this product.';

  @override
  String get catalogVariantCreateTitle => 'New variant';

  @override
  String get catalogVariantEditTitle => 'Edit variant';

  @override
  String get catalogVariantLabelField => 'Variant label';

  @override
  String get catalogVariantSkuField => 'SKU';

  @override
  String get catalogVariantLabelRequired => 'Enter a variant label.';

  @override
  String get catalogVariantSkuRequired => 'Enter a SKU.';

  @override
  String get catalogVariantSaveSuccess => 'Variant saved for this session.';

  @override
  String get catalogVariantSaveFailed => 'Could not save variant.';

  @override
  String get catalogVariantDuplicateSku =>
      'This SKU already exists in the preview scope.';
}
