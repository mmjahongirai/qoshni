// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'QO\'SHNI';

  @override
  String get homeHeadline => 'Основа готова';

  @override
  String get homeSubtitle =>
      'Масштабируемая архитектура для локальных сервисов и маркетплейса.';

  @override
  String environmentLabel(String env) {
    return 'Среда: $env';
  }

  @override
  String get homeMainHeading => 'Что вам нужно сейчас?';

  @override
  String get homeSearchHint => 'Найти сервис или магазин';

  @override
  String get homeNearbyTitle => 'Рядом с вами';

  @override
  String get mapPreviewTitle => 'Искать на карте';

  @override
  String get mapPreviewSubtitle => 'Сервисы и магазины рядом';

  @override
  String get openMap => 'Открыть карту';

  @override
  String get homeMapPreviewStatus =>
      'Демо-карта — живая геолокация и места появятся позже.';

  @override
  String get homeNearbyChainsTitle => 'Сети и важные места рядом';

  @override
  String get homeNearbyChainsSubtitle =>
      'Быстро находите филиалы и нужные точки.';

  @override
  String get homeEssentialSupermarkets => 'Супермаркеты';

  @override
  String get homeEssentialPharmacies => 'Аптеки';

  @override
  String get homeEssentialHospitals => 'Больницы и клиники';

  @override
  String get homeEssentialRestaurants => 'Кафе и рестораны';

  @override
  String get homeEssentialPlaceTypeHint => 'Демо-ярлык категории';

  @override
  String get homeMapLegendMarkets => 'Магазины';

  @override
  String get homeMapLegendPharmacy => 'Аптека';

  @override
  String get homeMapLegendHealth => 'Медицина';

  @override
  String get homeMapLegendFood => 'Еда';

  @override
  String get mapPlaceholderTitle => 'Карта';

  @override
  String get mapPlaceholderBody =>
      'Интерактивная карта будет подключена позже.';

  @override
  String get categoryGroceries => 'Продукты';

  @override
  String get categoryRestaurants => 'Рестораны';

  @override
  String get categoryPharmacy => 'Аптека';

  @override
  String get categoryShops => 'Магазины';

  @override
  String get categoryMasters => 'Мастера';

  @override
  String get categoryRent => 'Аренда';

  @override
  String get nearbyMock1Name => 'Baraka Market';

  @override
  String get nearbyMock1Distance => '0.8 км';

  @override
  String get nearbyMock1Description =>
      'Вымышленный продуктовый магазин с базовым ассортиментом (демо-запись).';

  @override
  String get nearbyMock1Address => 'Примерный район, Demo-улица 12';

  @override
  String get nearbyMock1Hours => 'Ежедневно, 8:00–22:00';

  @override
  String get nearbyMock2Name => 'Samarkand Cafe';

  @override
  String get nearbyMock2Distance => '1.2 км';

  @override
  String get nearbyMock2Description =>
      'Вымышленное кафе для предпросмотра MVP.';

  @override
  String get nearbyMock2Address => 'Примерный район, Demo-проспект 5';

  @override
  String get nearbyMock2Hours => 'Пн–Вс, 9:00–23:00';

  @override
  String get nearbyMock3Name => 'Shifo Plus';

  @override
  String get nearbyMock3Distance => '1.5 км';

  @override
  String get nearbyMock3Description => 'Вымышленная аптека в демо-каталоге.';

  @override
  String get nearbyMock3Address => 'Примерный район, Здоровье-пер. 3';

  @override
  String get nearbyMock3Hours => 'Ежедневно, 8:00–20:00';

  @override
  String get listingMockShop1Name => 'Пример — Техника';

  @override
  String get listingMockShop1Distance => '1.0 км';

  @override
  String get listingMockShop1Description =>
      'Вымышленный магазин электроники для списка категории.';

  @override
  String get listingMockShop1Address => 'Demo Mall, 1 этаж, пав. 7';

  @override
  String get listingMockShop1Hours => 'Ежедневно, 10:00–21:00';

  @override
  String get listingMockShop2Name => 'Пример — Одежда';

  @override
  String get listingMockShop2Distance => '1.8 км';

  @override
  String get listingMockShop2Description =>
      'Вымышленный бутик одежды для категории «Магазины».';

  @override
  String get listingMockShop2Address => 'Demo Bazaar, ряд B, маг. 14';

  @override
  String get listingMockShop2Hours => 'Вт–Вс, 10:00–19:00';

  @override
  String get listingMockMaster1Name => 'Пример — Сантехника';

  @override
  String get listingMockMaster1Distance => '2.1 км';

  @override
  String get listingMockMaster1Description =>
      'Вымышленная сантехническая служба для демо.';

  @override
  String get listingMockMaster1Address => 'По вызову — только demo-зона';

  @override
  String get listingMockMaster1Hours => 'Пн–Сб, 9:00–18:00';

  @override
  String get listingMockMaster2Name => 'Пример — Электрик';

  @override
  String get listingMockMaster2Distance => '2.6 км';

  @override
  String get listingMockMaster2Description =>
      'Вымышленный электрик для категории «Мастера».';

  @override
  String get listingMockMaster2Address => 'По вызову — только demo-зона';

  @override
  String get listingMockMaster2Hours => 'Пн–Пт, 8:00–17:00';

  @override
  String get listingMockRent1Name => 'Пример — Аренда жилья';

  @override
  String get listingMockRent1Distance => '3.0 км';

  @override
  String get listingMockRent1Description =>
      'Вымышленная краткосрочная аренда жилья.';

  @override
  String get listingMockRent1Address => 'Примерный район, Demo Residence';

  @override
  String get listingMockRent1Hours => 'Офис: Пн–Пт, 9:00–18:00';

  @override
  String get listingMockRent2Name => 'Пример — Аренда авто';

  @override
  String get listingMockRent2Distance => '3.4 км';

  @override
  String get listingMockRent2Description =>
      'Вымышленная аренда автомобилей для демо.';

  @override
  String get listingMockRent2Address => 'Demo Airport Road, парковка C';

  @override
  String get listingMockRent2Hours => 'Ежедневно, 7:00–22:00';

  @override
  String get businessDetailSectionAbout => 'Описание';

  @override
  String get businessDetailSectionLocation => 'Адрес';

  @override
  String get businessDetailSectionHours => 'Часы работы';

  @override
  String get businessDetailInfoNotAvailable => 'Не указано в этой демо-записи.';

  @override
  String get businessDetailNotFoundTitle => 'Бизнес не найден';

  @override
  String get businessDetailNotFoundBody =>
      'Вернитесь назад и выберите другую запись в поиске или категориях.';

  @override
  String get categoryListingEmptyTitle => 'Пока нет объявлений';

  @override
  String get categoryListingEmptyBody =>
      'Новые партнёры в этой категории скоро появятся здесь.';

  @override
  String get categoryListingUnknownTitle => 'Категория не найдена';

  @override
  String get categoryListingUnknownBody =>
      'Вернитесь назад и выберите категорию на главном экране.';

  @override
  String get toggleThemeTooltip => 'Сменить тему';

  @override
  String get languageTooltip => 'Язык';

  @override
  String get navHome => 'Главная';

  @override
  String get demoContentBadge => 'Демо';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchClearQuery => 'Очистить запрос';

  @override
  String get searchInitialTitle => 'Что вы ищете?';

  @override
  String get searchInitialBody =>
      'Введите название сервиса, магазина или категории.';

  @override
  String get searchEmptyTitle => 'Ничего не найдено';

  @override
  String get searchEmptyBody => 'Попробуйте другой запрос.';

  @override
  String get searchCategoryEntrySubtitle => 'Категория';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get favoritesAddTooltip => 'Добавить в избранное';

  @override
  String get favoritesRemoveTooltip => 'Удалить из избранного';

  @override
  String get favoritesEmptyTitle => 'Пока нет сохранённых мест';

  @override
  String get favoritesEmptyBody =>
      'Нажмите сердечко на странице бизнеса, чтобы сохранить его здесь.';

  @override
  String get favoritesGoHome => 'На главную';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileOpenTooltip => 'Профиль';

  @override
  String get profileGuestTitle => 'Гостевой пользователь';

  @override
  String get profileGuestBody =>
      'Вы используете QO‘SHNI без входа в аккаунт. Функции аккаунта появятся позже.';

  @override
  String get profileSectionShortcuts => 'Быстрые ссылки';

  @override
  String profileFavoritesSavedCount(int count) {
    return 'Сохранено: $count';
  }

  @override
  String get profileSectionAppearance => 'Оформление';

  @override
  String get profileThemeSystem => 'Системная';

  @override
  String get profileThemeLight => 'Светлая';

  @override
  String get profileThemeDark => 'Тёмная';

  @override
  String get profileSectionLanguage => 'Язык';

  @override
  String get profileLanguageSystem => 'Как в системе';

  @override
  String get profileLanguageUz => 'O‘zbekcha';

  @override
  String get profileLanguageRu => 'Русский';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileAboutTitle => 'О приложении';

  @override
  String get profileAboutGuestNote =>
      'Гостевой режим — личные данные не сохраняются после текущего сеанса.';

  @override
  String get businessDetailSectionCatalog => 'Товары и услуги';

  @override
  String get businessDetailCatalogEmptyTitle => 'Пока нет демо-предложений';

  @override
  String get businessDetailCatalogEmptyBody =>
      'Примеры товаров и услуг для этого бизнеса появятся здесь позже.';

  @override
  String get catalogItemTypeProduct => 'Товар';

  @override
  String get catalogItemTypeService => 'Услуга';

  @override
  String catalogSamplePriceDemo(int amount) {
    return 'Демо-цена: $amount сум';
  }

  @override
  String get catalogItemDetailSectionDescription => 'Описание';

  @override
  String get catalogItemDetailParentBusiness => 'Бизнес';

  @override
  String get catalogItemDetailNotFoundTitle => 'Предложение не найдено';

  @override
  String get catalogItemDetailNotFoundBody =>
      'Этот демо-элемент не существует или не относится к выбранному бизнесу.';

  @override
  String get catalogBarakaFreshBreadName => 'Пример — деревенский хлеб';

  @override
  String get catalogBarakaFreshBreadDesc =>
      'Вымышленная позиция для демо-магазина.';

  @override
  String get catalogBarakaDailyBasketName => 'Пример — корзина essentials';

  @override
  String get catalogBarakaDailyBasketDesc =>
      'Вымышленный набор продуктов (только демо).';

  @override
  String get catalogSamarkandPlovName => 'Пример — домашний плов';

  @override
  String get catalogSamarkandPlovDesc => 'Вымышленная порция для демо-кафе.';

  @override
  String get catalogSamarkandGreenTeaName => 'Пример — зелёный чай';

  @override
  String get catalogSamarkandGreenTeaDesc => 'Вымышленная подача чая для демо.';

  @override
  String get catalogShifoVitaminCName => 'Пример — витамин C';

  @override
  String get catalogShifoVitaminCDesc =>
      'Вымышленный OTC-товар; не реальный препарат.';

  @override
  String get catalogShifoFirstAidKitName => 'Пример — аптечка';

  @override
  String get catalogShifoFirstAidKitDesc =>
      'Вымышленный набор для демонстрации.';

  @override
  String get catalogTechUsbHubName => 'Пример — USB-хаб';

  @override
  String get catalogTechUsbHubDesc => 'Вымышленный аксессуар демо-магазина.';

  @override
  String get catalogTechPhoneCaseName => 'Пример — чехол';

  @override
  String get catalogTechPhoneCaseDesc => 'Вымышленный универсальный чехол.';

  @override
  String get catalogStyleCottonTeeName => 'Пример — хлопковая футболка';

  @override
  String get catalogStyleCottonTeeDesc => 'Вымышленная одежда для демо-бутика.';

  @override
  String get catalogPipeLeakVisitName => 'Пример — проверка протечки';

  @override
  String get catalogPipeLeakVisitDesc => 'Вымышленный выезд сантехника (демо).';

  @override
  String get catalogPipeTapInstallName => 'Пример — установка крана';

  @override
  String get catalogPipeTapInstallDesc => 'Вымышленная услуга с демо-ценой.';

  @override
  String get catalogElectricSocketCheckName => 'Пример — проверка розеток';

  @override
  String get catalogElectricSocketCheckDesc =>
      'Вымышленный визит электрика для демо.';

  @override
  String get catalogRentStudioNightName => 'Пример — студия (1 ночь)';

  @override
  String get catalogRentStudioNightDesc =>
      'Вымышленная аренда; не реальное объявление.';

  @override
  String get catalogRentSedanDayName => 'Пример — седан (1 день)';

  @override
  String get catalogRentSedanDayDesc => 'Вымышленная аренда авто для демо.';

  @override
  String get cartTitle => 'Корзина';

  @override
  String get cartOpenTooltip => 'Корзина';

  @override
  String get cartAddToCart => 'В корзину';

  @override
  String cartAddedSnackBar(String itemName) {
    return '$itemName добавлено в корзину (демо)';
  }

  @override
  String get cartCannotAddNoPrice =>
      'У этого демо-элемента нет sample-цены — нельзя добавить в итог.';

  @override
  String get cartEmptyTitle => 'Корзина пуста';

  @override
  String get cartEmptyBody =>
      'Просмотрите бизнесы и добавьте демо-товары или услуги со страницы предложения.';

  @override
  String get cartBrowseHome => 'На главную';

  @override
  String get cartQuantityIncrease => 'Увеличить количество';

  @override
  String get cartQuantityDecrease => 'Уменьшить количество';

  @override
  String get cartRemoveItem => 'Удалить из корзины';

  @override
  String get cartClearAction => 'Очистить';

  @override
  String get cartClearConfirmTitle => 'Очистить корзину?';

  @override
  String get cartClearConfirmBody => 'Удалить все демо-позиции из корзины?';

  @override
  String get cartClearConfirmYes => 'Очистить';

  @override
  String get cartClearConfirmCancel => 'Отмена';

  @override
  String cartDemoAmountUzs(String amount) {
    return '$amount сум (демо sample-цена)';
  }

  @override
  String cartLineSubtotal(String amount) {
    return 'Промежуточный итог (демо): $amount';
  }

  @override
  String cartEstimatedTotalLabel(String amount) {
    return 'Оценочный демо-итог: $amount';
  }

  @override
  String get cartDemoEstimateDisclaimer =>
      'Только локальная демо-оценка — не счёт и не оплата.';

  @override
  String get cartProceedCheckout => 'Перейти к оформлению';

  @override
  String get checkoutTitle => 'Оформление';

  @override
  String get checkoutReviewNotice =>
      'Проверьте демо-корзину. В этом превью не собираются оплата и личные данные.';

  @override
  String get checkoutConfirmDemoOrder => 'Подтвердить демо-заказ';

  @override
  String checkoutQuantityLabel(int quantity) {
    return 'Кол-во: $quantity';
  }

  @override
  String get checkoutEmptyTitle => 'Нечего оформлять';

  @override
  String get checkoutEmptyBody =>
      'Корзина пуста. Добавьте демо-товары перед оформлением.';

  @override
  String get demoOrderConfirmationTitle => 'Демо-подтверждение';

  @override
  String get demoOrderPreparedHeading => 'Демо-заказ подготовлен';

  @override
  String demoOrderReferenceLabel(String referenceId) {
    return 'Демо-номер: $referenceId';
  }

  @override
  String get demoOrderNoRealSubmissionNotice =>
      'Реальный заказ бизнесу не отправлен. Оплата не списана, доставка и бронирование не назначены.';

  @override
  String get demoOrderReturnHome => 'На главную';

  @override
  String get demoOrderInvalidTitle => 'Подтверждение недоступно';

  @override
  String get demoOrderInvalidBody =>
      'Это демо-подтверждение отсутствует или устарело. Начните снова из корзины.';

  @override
  String get demoOrdersTitle => 'Заказы';

  @override
  String get demoOrdersEmptyTitle => 'Демо-заказов пока нет';

  @override
  String get demoOrdersEmptyBody =>
      'Подтвердите демо-оформление, чтобы увидеть локальный предпросмотр заказа. Бизнесам ничего не отправляется.';

  @override
  String demoOrdersListSummary(int lineCount, int unitCount) {
    String _temp0 = intl.Intl.pluralLogic(
      lineCount,
      locale: localeName,
      other: '$lineCount поз. · $unitCount шт.',
      one: '1 позиция · $unitCount шт.',
    );
    return '$_temp0';
  }

  @override
  String get demoOrderDetailTitle => 'Демо-заказ';

  @override
  String get demoOrderDetailNotFoundTitle => 'Заказ не найден';

  @override
  String get demoOrderDetailNotFoundBody =>
      'Этого демо-заказа нет в истории текущей сессии. Подтвердите новый демо-заказ или вернитесь на главную.';

  @override
  String get demoOrderStatusPreparedNotSent =>
      'Демо подготовлен — не отправлен';

  @override
  String get demoOrderStatusLocalOnlyNote =>
      'Статус хранится только на этом устройстве для демо. Нет принятия бизнесом, оплаты, доставки или бронирования.';

  @override
  String get demoOrderViewHistory => 'История заказов';

  @override
  String profileDemoOrdersSavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count демо-заказов в этой сессии',
      one: '1 демо-заказ в этой сессии',
      zero: 'Нет демо-заказов в этой сессии',
    );
    return '$_temp0';
  }

  @override
  String get businessCenterTitle => 'Бизнес-центр';

  @override
  String get profileBusinessCenterSubtitle =>
      'Локальные черновики профиля (демо)';

  @override
  String get businessCenterIntroTitle => 'Управление бизнесом (превью)';

  @override
  String get businessCenterIntroBody =>
      'Этот MVP показывает, как владелец может подготовить профиль. Ничего не публикуется и не сохраняется на сервере.';

  @override
  String get businessCenterSessionNotice =>
      'Черновики существуют только в этой сессии браузера и исчезают после обновления или перезапуска.';

  @override
  String get businessCenterYourProfilesTitle => 'Черновики сессии';

  @override
  String get businessCenterEmptyDraftsTitle => 'Черновиков пока нет';

  @override
  String get businessCenterEmptyDraftsBody =>
      'Создайте профиль, чтобы увидеть, как может выглядеть ваше объявление. Только на этом устройстве.';

  @override
  String get businessCenterCreateProfile => 'Создать профиль';

  @override
  String get businessCenterSampleSectionTitle => 'Пример профиля';

  @override
  String get businessCenterSampleSectionBody =>
      'Вымышленный демо-профиль только для чтения — не проверенный бизнес и не показывается в Поиске или на Главной.';

  @override
  String get businessProfileSampleBadge => 'Демо-пример';

  @override
  String get businessPlannedSectionTitle => 'В следующих фазах';

  @override
  String get businessPlannedSectionBody =>
      'Запланированные возможности (недоступны в этом MVP):';

  @override
  String get businessPlannedProducts => 'Управление товарами и услугами';

  @override
  String get businessPlannedAvailability => 'Наличие и склад';

  @override
  String get businessPlannedOrders => 'Заказы и бронирования';

  @override
  String get businessPlannedRental => 'Аренда, расписание и депозиты';

  @override
  String get businessPlannedStaff => 'Сотрудники и права доступа';

  @override
  String get businessPlannedAnalytics => 'Бизнес-аналитика';

  @override
  String get businessSampleRentalName =>
      'Пример — аренда перфораторов и инструментов';

  @override
  String get businessSampleRentalDescription =>
      'Вымышленный пример проката для демо бизнес-центра. Нет реального склада, цен или бронирования.';

  @override
  String get businessSampleRentalAddress =>
      'Демо-район, ул. Примерная мастерская 3 (не реальный адрес)';

  @override
  String get businessSampleRentalHours => 'Пн–Сб, 9:00–18:00 (демо-часы)';

  @override
  String get businessSampleRentalPhone => '+998 00 000 00 00 (пример)';

  @override
  String get businessProfileDetailTitle => 'Профиль бизнеса';

  @override
  String get businessProfileEditAction => 'Изменить';

  @override
  String get businessProfileSampleReadOnlyNotice =>
      'Это демо-профиль только для просмотра. Не публикуется и не редактируется напрямую.';

  @override
  String get businessProfileDraftLocalNotice =>
      'Это локальный черновик. Сохранение не публикует бизнес и не связывает с клиентами.';

  @override
  String get businessProfileCopySampleToDraft =>
      'Скопировать пример в новый черновик';

  @override
  String get businessProfileNotFoundTitle => 'Профиль не найден';

  @override
  String get businessProfileNotFoundBody =>
      'Этот профиль недоступен в текущей сессии. Вернитесь в бизнес-центр и попробуйте снова.';

  @override
  String get businessProfileFormCreateTitle => 'Новый профиль бизнеса';

  @override
  String get businessProfileFormEditTitle => 'Редактировать профиль';

  @override
  String get businessProfileFormLocalSaveNotice =>
      'Изменения сохраняются локально только для этой сессии — без публикации в сети.';

  @override
  String get businessProfileFieldName => 'Название бизнеса';

  @override
  String get businessProfileFieldCategory => 'Категория';

  @override
  String get businessProfileFieldDescription => 'Описание';

  @override
  String get businessProfileFieldAddress => 'Адрес или местоположение';

  @override
  String get businessProfileFieldHours => 'Часы работы';

  @override
  String get businessProfileFieldPhone => 'Контактный телефон';

  @override
  String get businessProfileFieldPhoneOptional =>
      'Контактный телефон (необязательно)';

  @override
  String get businessProfileValidationNameRequired =>
      'Введите название бизнеса';

  @override
  String get businessProfileValidationDescriptionRequired => 'Введите описание';

  @override
  String get businessProfileValidationAddressRequired =>
      'Введите адрес или местоположение';

  @override
  String get businessProfileValidationHoursRequired => 'Укажите часы работы';

  @override
  String get businessProfileSaveAction => 'Сохранить черновик';

  @override
  String get businessProfileCancelAction => 'Отмена';

  @override
  String get businessOfferingsSectionTitle => 'Товары и услуги';

  @override
  String get businessOfferingAddAction => 'Добавить';

  @override
  String get businessOfferingsOwnerNotice =>
      'Локальный демо-каталог только для черновика — не виден клиентам в Поиске или на Главной.';

  @override
  String get businessOfferingsSampleNotice =>
      'Только демонстрация — не редактируется и не публикуется.';

  @override
  String get businessOfferingsEmptyOwner =>
      'Пока нет предложений. Добавьте товар, услугу или аренду для предпросмотра.';

  @override
  String get businessOfferingsEmptySample =>
      'У примера профиля нет демо-позиций, если образцы отключены.';

  @override
  String get businessOfferingKindProduct => 'Товар';

  @override
  String get businessOfferingKindService => 'Услуга';

  @override
  String get businessOfferingKindRental => 'Аренда';

  @override
  String get businessPricingUnitPerItem => 'за штуку';

  @override
  String get businessPricingUnitPerHour => 'за час';

  @override
  String get businessPricingUnitPerDay => 'за сутки';

  @override
  String get businessOfferingNoDemoPrice => 'Нет демо-цены';

  @override
  String businessOfferingDemoPriceLine(String amount, String unit) {
    return 'Демо-цена: $amount ($unit)';
  }

  @override
  String businessOfferingDemoDepositLine(String amount) {
    return 'Демо-депозит (не списывается): $amount';
  }

  @override
  String get businessOfferingEditAction => 'Изменить';

  @override
  String get businessOfferingDeleteAction => 'Удалить';

  @override
  String get businessOfferingDeleteConfirmTitle => 'Удалить предложение?';

  @override
  String get businessOfferingDeleteConfirmBody =>
      'Удалить из локального черновика? После обновления страницы восстановить нельзя.';

  @override
  String get businessOfferingDeleteConfirmYes => 'Удалить';

  @override
  String get businessOfferingFormCreateTitle => 'Новое предложение';

  @override
  String get businessOfferingFormEditTitle => 'Редактировать предложение';

  @override
  String get businessOfferingFormLocalNotice =>
      'Предложения только на этом устройстве в текущей сессии — клиентам не публикуются.';

  @override
  String get businessOfferingFieldName => 'Название';

  @override
  String get businessOfferingFieldKind => 'Тип';

  @override
  String get businessOfferingFieldDescription => 'Краткое описание';

  @override
  String get businessOfferingFieldPricingUnit => 'Единица цены';

  @override
  String get businessOfferingFieldDemoPriceOptional =>
      'Демо-цена (сум, необязательно)';

  @override
  String get businessOfferingFieldDemoDepositOptional =>
      'Демо-депозит (сум, необязательно)';

  @override
  String get businessOfferingValidationNameRequired => 'Введите название';

  @override
  String get businessOfferingValidationDescriptionRequired =>
      'Введите описание';

  @override
  String get businessOfferingValidationUzsInvalid =>
      'Введите неотрицательное целое число в сумах';

  @override
  String get businessOfferingSaveAction => 'Сохранить';

  @override
  String get businessOfferingProfileNotEditable =>
      'Предложения можно управлять только для своих черновиков сессии.';

  @override
  String get businessOfferingNotFoundBody =>
      'Предложение не найдено или не принадлежит этому профилю.';

  @override
  String get businessSampleOfferingPerforatorName =>
      'Пример — перфоратор (демо аренды)';

  @override
  String get businessSampleOfferingPerforatorDesc =>
      'Вымышленная аренда инструмента для демо. Нет календаря, наличия или реального депозита.';

  @override
  String get businessInventorySummaryTitle => 'Склад и доступность';

  @override
  String businessInventorySummaryCounts(
    int configured,
    int total,
    int active,
    int paused,
  ) {
    return 'Настроено $configured из $total · Активно $active · Пауза $paused';
  }

  @override
  String get businessInventorySummaryNotice =>
      'Демо-остатки и пауза только локально — не синхронизируются с клиентами или бронями.';

  @override
  String get businessInventoryManageAction =>
      'Управление складом и доступностью';

  @override
  String get businessInventoryPageTitle => 'Склад и доступность';

  @override
  String get businessInventoryPageIntro =>
      'Задайте демо-остатки или паузу для предложений сессии. Это не система бронирования.';

  @override
  String get businessInventoryProfileNotEditable =>
      'Склад доступен только для ваших черновиков сессии.';

  @override
  String get businessInventoryNoOfferingsTitle => 'Пока нет предложений';

  @override
  String get businessInventoryNoOfferingsBody =>
      'Добавьте товары, услуги или аренду в профиле, затем настройте склад.';

  @override
  String get businessInventoryBackToProfile => 'К профилю';

  @override
  String get businessInventoryNotConfigured => 'Не настроено';

  @override
  String get businessInventoryStateActive => 'Активно';

  @override
  String get businessInventoryStatePaused => 'Пауза';

  @override
  String businessInventoryServiceStatus(String state) {
    return 'Статус: $state (демо — без расписания)';
  }

  @override
  String businessInventoryProductStock(int available, int total, String state) {
    return '$available доступно из $total · $state';
  }

  @override
  String businessInventoryRentalUnits(int available, int total, String state) {
    return '$available доступно из $total шт. · $state (ручной демо-счёт)';
  }

  @override
  String get businessInventoryConfigureAction => 'Настроить';

  @override
  String get businessInventoryEditAction => 'Изменить склад';

  @override
  String get businessInventoryEditTitle => 'Редактировать склад';

  @override
  String get businessInventoryLocalNotice =>
      'Только локальное демо — не публикуется в клиентском приложении.';

  @override
  String get businessInventoryRentalManualNotice =>
      'Доступные единицы вводятся вручную для демо. Брони и возвраты не обновляют счёт автоматически.';

  @override
  String get businessInventoryAvailabilityToggle => 'Предложение активно';

  @override
  String get businessInventoryFieldStockTotal => 'Всего на складе (шт.)';

  @override
  String get businessInventoryFieldStockAvailable => 'Доступно (шт.)';

  @override
  String get businessInventoryFieldTotalUnits => 'Всего единиц оборудования';

  @override
  String get businessInventoryFieldAvailableUnits => 'Сейчас доступно';

  @override
  String get businessInventoryValidationQuantityRequired =>
      'Введите количество';

  @override
  String get businessInventoryValidationQuantityInvalid =>
      'Введите неотрицательное целое число';

  @override
  String get businessInventoryValidationAvailableExceedsTotal =>
      'Доступное не может превышать общее';

  @override
  String get businessInventorySaveAction => 'Сохранить склад';

  @override
  String get authSignInAction => 'Войти';

  @override
  String get authSignInTitle => 'Вход';

  @override
  String get authSignOutAction => 'Выйти';

  @override
  String get authPhonePrompt =>
      'Введите номер телефона в международном формате. Когда сервис будет доступен, мы отправим одноразовый код.';

  @override
  String get authPhoneFieldLabel => 'Номер телефона';

  @override
  String get authPhoneHint => '+998901234567';

  @override
  String get authPhoneInvalid =>
      'Введите корректный международный номер, например +998901234567.';

  @override
  String get authRequestOtpAction => 'Отправить код';

  @override
  String get authOtpPrompt => 'Введите код из SMS, когда доставка настроена.';

  @override
  String get authOtpFieldLabel => 'Код подтверждения';

  @override
  String get authVerifyAction => 'Подтвердить';

  @override
  String get authChangePhoneAction => 'Другой номер';

  @override
  String get authContinueAsGuest => 'Продолжить как гость';

  @override
  String get authApiNotConfigured =>
      'Для этой сборки сервер входа не настроен. Укажите QOSHNI_API_BASE_URL при сборке.';

  @override
  String get authErrorServiceUnavailable =>
      'Вход временно недоступен. SMS-шлюз может быть ещё не настроен.';

  @override
  String get authErrorRateLimited =>
      'Слишком много попыток. Подождите и попробуйте снова.';

  @override
  String get authErrorCodeIncorrect => 'Неверный код подтверждения.';

  @override
  String get authErrorChallengeExpired =>
      'Срок действия кода истёк. Запросите новый.';

  @override
  String get authErrorChallengeLocked =>
      'Слишком много неверных попыток. Запросите новый код.';

  @override
  String get authErrorNetwork =>
      'Ошибка сети. Проверьте подключение и повторите.';

  @override
  String get authErrorGeneric => 'Не удалось выполнить вход. Попробуйте снова.';

  @override
  String get authSignedInTitle => 'Вы вошли';

  @override
  String get authSignedInBody => 'Телефон подтверждён для текущей сессии.';

  @override
  String get authSessionsAction => 'Управление сессиями';

  @override
  String get authSessionsTitle => 'Ваши сессии';

  @override
  String get authSessionsEmpty => 'Нет сессий для отображения.';

  @override
  String get authSessionUnknownDevice => 'Неизвестное устройство';

  @override
  String get authSessionStateActive => 'Активна';

  @override
  String get authSessionStateExpired => 'Истекла';

  @override
  String get authSessionStateRevoked => 'Отозвана';

  @override
  String get authSessionCurrentBadge => 'Текущая';

  @override
  String get authSessionExpiredNotice =>
      'Сессия завершена. Вы сможете войти снова, когда сервис будет доступен.';

  @override
  String get userProfileDisplayNameHint => 'Отображаемое имя';

  @override
  String get userProfileDisplayNameEmpty => 'Имя не задано';

  @override
  String get userProfileEditDisplayNameAction => 'Изменить имя';

  @override
  String get userProfileClearDisplayNameAction => 'Удалить имя';

  @override
  String get userProfileSaveAction => 'Сохранить';

  @override
  String get userProfileCancelAction => 'Отмена';

  @override
  String get userProfileRetryAction => 'Повторить';

  @override
  String get userProfileLoadError => 'Не удалось загрузить профиль.';

  @override
  String get userProfileSaveSuccess => 'Профиль обновлён.';

  @override
  String get userProfilePreferencesSaveSuccess => 'Настройки сохранены.';

  @override
  String get userProfileApiNotConfigured =>
      'Сервер аккаунта не настроен для этой сборки. Укажите QOSHNI_API_BASE_URL при сборке.';

  @override
  String get userProfileErrorNetwork =>
      'Ошибка сети. Проверьте подключение и повторите.';

  @override
  String get userProfileErrorServiceUnavailable =>
      'Сервис профиля временно недоступен.';

  @override
  String get userProfileNotFound =>
      'Профиль пока недоступен. Повторите попытку или войдите снова.';

  @override
  String get userProfilePreferencesNotFound =>
      'Настройки пока недоступны. Повторите попытку или войдите снова.';

  @override
  String get userProfileErrorValidation =>
      'Недопустимое значение. Проверьте имя или язык.';

  @override
  String get userProfileErrorGeneric =>
      'Что-то пошло не так. Попробуйте снова.';

  @override
  String get userProfileSectionPersonalization => 'Персонализация';

  @override
  String get userProfilePersonalizationTitle => 'Персональные подсказки';

  @override
  String get userProfilePersonalizationBody =>
      'Если включено, QO‘SHNI может использовать ваши явные настройки для подсказок. По умолчанию выключено.';

  @override
  String get userProfileSaving => 'Сохранение…';
}
