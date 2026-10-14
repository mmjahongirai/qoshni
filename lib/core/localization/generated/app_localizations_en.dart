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
      'Local business profile drafts (demo)';

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
}
