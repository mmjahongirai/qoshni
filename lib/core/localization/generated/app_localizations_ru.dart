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
  String get homeMapPreviewStatusNotConfigured =>
      'Mapbox — укажите MAPBOX_ACCESS_TOKEN для карты.';

  @override
  String get homeMapPreviewStatusConfigured =>
      'Mapbox — вид по Узбекистану (не ваше местоположение).';

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
  String get mapboxConfigRequiredTitle => 'Нужен токен Mapbox';

  @override
  String get mapboxConfigRequiredBody =>
      'Передайте pk-токен через --dart-define=MAPBOX_ACCESS_TOKEN=…';

  @override
  String get mapboxDefaultViewLabel => 'Вид по умолчанию — Узбекистан';

  @override
  String get mapboxLoadErrorBody =>
      'Карта не загрузилась. Проверьте токен и сеть.';

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
      'Регистрация бизнеса и отслеживание заявок';

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

  @override
  String get businessCenterOnboardingTitle => 'Регистрация бизнеса';

  @override
  String get businessCenterOnboardingBody =>
      'Подайте заявку на проверку, загрузите документы и отслеживайте статус под своим аккаунтом.';

  @override
  String get businessCenterOnboardingAction => 'Открыть регистрацию';

  @override
  String get onboardingHubTitle => 'Регистрация бизнеса';

  @override
  String get onboardingHubIntroTitle => 'Зарегистрируйте бизнес';

  @override
  String get onboardingHubIntroBody =>
      'Создайте заявку, заполните форму, загрузите документы и отправьте на проверку. Статус приходит с сервера.';

  @override
  String get onboardingHubEmptyTitle => 'Заявок пока нет';

  @override
  String get onboardingHubEmptyBody =>
      'Начните новую заявку для проверки вашего бизнеса.';

  @override
  String get onboardingCreateApplication => 'Новая заявка';

  @override
  String get onboardingUntitledApplication => 'Без названия';

  @override
  String get onboardingSignInPrompt =>
      'Войдите, чтобы просматривать и управлять заявками на регистрацию.';

  @override
  String get onboardingApplicationTitle => 'Заявка';

  @override
  String get onboardingTabForm => 'Данные';

  @override
  String get onboardingTabDocuments => 'Документы';

  @override
  String get onboardingTabStatus => 'Статус';

  @override
  String get onboardingFormReadOnlyNotice =>
      'Заявка больше не черновик. Поля доступны только для чтения во время проверки.';

  @override
  String get onboardingFieldLegalName => 'Юридическое название';

  @override
  String get onboardingFieldTradeName =>
      'Торговое / отображаемое имя (необяз.)';

  @override
  String get onboardingFieldServiceCategory => 'Категория услуг';

  @override
  String get onboardingFieldJurisdiction => 'Юрисдикция регистрации (ISO)';

  @override
  String get onboardingFieldRegistrationId => 'Регистрационный номер (необяз.)';

  @override
  String get onboardingFieldTaxIdOptional => 'ИНН / налоговый ID (необяз.)';

  @override
  String get onboardingFieldContactEmailOptional =>
      'Контактный email (необяз.)';

  @override
  String get onboardingValidationLegalNameRequired =>
      'Введите юридическое название';

  @override
  String get onboardingValidationCategoryRequired => 'Выберите категорию';

  @override
  String get onboardingValidationJurisdictionInvalid =>
      'Введите двухбуквенный код (например, UZ)';

  @override
  String get onboardingValidationEmailInvalid => 'Введите корректный email';

  @override
  String get onboardingSaveDraftAction => 'Сохранить черновик';

  @override
  String get onboardingSubmitAction => 'Отправить на проверку';

  @override
  String get onboardingDraftSaved => 'Черновик сохранён.';

  @override
  String get onboardingSubmitSuccess => 'Заявка отправлена на проверку.';

  @override
  String get onboardingCategoryGroceries => 'Продукты';

  @override
  String get onboardingCategoryRestaurants => 'Рестораны';

  @override
  String get onboardingCategoryPharmacy => 'Аптека';

  @override
  String get onboardingCategoryShops => 'Магазины';

  @override
  String get onboardingCategoryMasters => 'Мастера и услуги';

  @override
  String get onboardingCategoryRent => 'Аренда';

  @override
  String get onboardingDocumentsIntro =>
      'Зарегистрируйте тип документа, затем загрузите PDF, JPEG или PNG до 10 МиБ.';

  @override
  String get onboardingDocumentsEmpty =>
      'Документов пока нет. Добавьте тип ниже.';

  @override
  String get onboardingRegisterDocumentTitle => 'Добавить документ';

  @override
  String get onboardingUploadAction => 'Выбрать файл и загрузить';

  @override
  String get onboardingUploadTooLarge =>
      'Файл больше 10 МиБ. Выберите меньший файл.';

  @override
  String get onboardingUploadReadFailed => 'Не удалось прочитать файл.';

  @override
  String get onboardingUploadSuccess => 'Загрузка завершена.';

  @override
  String get onboardingDocTypeRegistrationCertificate =>
      'Свидетельство о регистрации';

  @override
  String get onboardingDocTypeTaxRegistration => 'Налоговая регистрация';

  @override
  String get onboardingDocTypeRepresentativeId => 'ID представителя';

  @override
  String get onboardingDocTypeOtherSupporting => 'Другой документ';

  @override
  String get onboardingVerificationCurrentStatus => 'Текущий статус';

  @override
  String get onboardingVerificationSubmittedAt => 'Отправлено';

  @override
  String get onboardingVerificationReviewedAt => 'Проверено';

  @override
  String get onboardingVerificationRejectionTitle => 'Причина отказа';

  @override
  String get onboardingNextStepsDraft =>
      'Заполните форму, загрузите документы и отправьте, когда будете готовы.';

  @override
  String get onboardingNextStepsSubmitted =>
      'Заявка отправлена. Мы сообщим, когда начнётся проверка.';

  @override
  String get onboardingNextStepsUnderReview =>
      'Команда проверяет заявку. Могут запросить дополнительные документы.';

  @override
  String get onboardingNextStepsVerified =>
      'Бизнес подтверждён. Дальнейшие функции появятся позже.';

  @override
  String get onboardingNextStepsRejected =>
      'Заявка отклонена. Изучите причину и обновите данные, если возможно.';

  @override
  String get onboardingNextStepsSuspended =>
      'Заявка приостановлена. Обратитесь в поддержку.';

  @override
  String get onboardingNextStepsGeneric => 'Загляните позже за обновлениями.';

  @override
  String get onboardingErrorNotFound => 'Заявка не найдена.';

  @override
  String get onboardingErrorForbidden => 'Нет доступа к этой заявке.';

  @override
  String get onboardingErrorInvalidTransition =>
      'Действие недоступно для текущего статуса.';

  @override
  String get onboardingErrorValidation =>
      'Некоторые поля неверны. Проверьте форму.';

  @override
  String get onboardingErrorUnavailable => 'Сервис временно недоступен.';

  @override
  String get onboardingErrorScanUnavailable =>
      'Сканирование документов временно недоступно.';

  @override
  String get onboardingErrorDocumentRejected =>
      'Документ отклонён. Зарегистрируйте новый и загрузите снова.';

  @override
  String get onboardingErrorSuspended => 'Заявка приостановлена.';

  @override
  String get onboardingErrorSignInRequired => 'Войдите, чтобы продолжить.';

  @override
  String get onboardingErrorApiNotConfigured =>
      'Сервер регистрации не настроен. Укажите QOSHNI_API_BASE_URL при сборке.';

  @override
  String get onboardingErrorNetwork => 'Ошибка сети. Проверьте подключение.';

  @override
  String get onboardingErrorUnexpected =>
      'Что-то пошло не так. Попробуйте снова.';

  @override
  String get onboardingStatusDraft => 'Черновик';

  @override
  String get onboardingStatusSubmitted => 'Отправлена';

  @override
  String get onboardingStatusUnderReview => 'На проверке';

  @override
  String get onboardingStatusVerified => 'Подтверждена';

  @override
  String get onboardingStatusRejected => 'Отклонена';

  @override
  String get onboardingStatusSuspended => 'Приостановлена';

  @override
  String get onboardingDocAwaitingUpload => 'Ожидает загрузки';

  @override
  String get onboardingDocUploadedPending => 'Загружен — проверка';

  @override
  String get onboardingDocQuarantined => 'Карантин';

  @override
  String get onboardingDocRejected => 'Отклонён';

  @override
  String get onboardingDocAcceptedForReview => 'Принят к проверке';

  @override
  String get onboardingDocDeleted => 'Удалён';

  @override
  String get onboardingRejectionIncomplete => 'Неполные данные';

  @override
  String get onboardingRejectionMismatch => 'Несоответствие регистрации';

  @override
  String get onboardingRejectionJurisdiction => 'Неподдерживаемая юрисдикция';

  @override
  String get onboardingRejectionPolicy => 'Нарушение правил';

  @override
  String get onboardingRejectionOther => 'Другое';

  @override
  String get businessCenterOwnerProfileTitle => 'Профиль бизнеса';

  @override
  String get businessCenterOwnerProfileBody =>
      'Предпросмотр профиля на уровне бизнеса. Сохраняется только в этой сессии до подключения backend.';

  @override
  String get ownerProfileOverviewTitle => 'Профиль бизнеса';

  @override
  String get ownerProfilePreviewNotice =>
      'Предпросмотр — сохраняется только в этой сессии. Не опубликован и не верифицирован.';

  @override
  String get ownerProfileStatusLabel => 'Статус профиля';

  @override
  String get ownerProfileStatusPreview => 'Черновик предпросмотра';

  @override
  String get ownerProfileCompletenessLabel => 'Заполненность профиля';

  @override
  String get ownerProfileEditAction => 'Редактировать профиль';

  @override
  String get ownerProfileViewAction => 'Просмотр профиля';

  @override
  String get ownerProfileSectionBasics => 'Основная информация';

  @override
  String get ownerProfileSectionContact => 'Контакты';

  @override
  String get ownerProfileSectionSettings => 'Настройки предпросмотра';

  @override
  String get ownerProfileLegalName => 'Юридическое название';

  @override
  String get ownerProfileDisplayName => 'Отображаемое название';

  @override
  String get ownerProfileDescription => 'Описание бизнеса';

  @override
  String get ownerProfileCategory => 'Категория услуг';

  @override
  String get ownerProfileContactPhone => 'Контактный телефон';

  @override
  String get ownerProfileContactEmail => 'Контактный email';

  @override
  String get ownerProfileWebsite => 'Сайт (предпросмотр)';

  @override
  String get ownerProfileVisibility => 'Видимость профиля (предпросмотр)';

  @override
  String get ownerProfileVisibilityHidden => 'Скрыт в предпросмотре';

  @override
  String get ownerProfileVisibilityVisible => 'Виден только в UI предпросмотра';

  @override
  String get ownerProfileEditorTitle => 'Редактирование профиля';

  @override
  String get ownerProfileSaveAction => 'Сохранить';

  @override
  String get ownerProfileCancelAction => 'Отмена';

  @override
  String get ownerProfileSaveSuccess => 'Профиль сохранён для этой сессии.';

  @override
  String get ownerProfileSaveFailed =>
      'Не удалось сохранить. Изменения остались в форме.';

  @override
  String get ownerProfileDiscardConfirmTitle => 'Отменить изменения?';

  @override
  String get ownerProfileDiscardConfirmBody =>
      'Несохранённые правки будут потеряны.';

  @override
  String get ownerProfileDiscardConfirmAction => 'Отменить';

  @override
  String get ownerProfileValidationLegalName => 'Введите юридическое название';

  @override
  String get ownerProfileValidationDisplayName =>
      'Введите отображаемое название';

  @override
  String get ownerProfileValidationDescription => 'Введите описание бизнеса';

  @override
  String get ownerProfileValidationEmail => 'Введите корректный email';

  @override
  String get ownerProfileValidationWebsite => 'Введите корректный URL сайта';

  @override
  String get businessCenterBranchesTitle => 'Филиалы';

  @override
  String get businessCenterBranchesBody =>
      'Адреса, часы работы и контакты филиалов в режиме предпросмотра.';

  @override
  String get branchListTitle => 'Филиалы';

  @override
  String get branchPreviewNotice =>
      'Предпросмотр — филиалы сохраняются только в этой сессии. Не публикуются в поиске и на карте.';

  @override
  String get branchProfileIncompleteNotice =>
      'Заполните профиль бизнеса в предпросмотре, прежде чем филиалы смогут синхронизироваться с реальным бизнесом.';

  @override
  String get branchOpenBusinessProfileAction => 'Открыть профиль бизнеса';

  @override
  String get branchAddAction => 'Добавить филиал';

  @override
  String get branchEmptyTitle => 'Филиалов пока нет';

  @override
  String get branchEmptyBody =>
      'Добавьте филиал для планирования адреса и часов работы.';

  @override
  String get branchStatusActive => 'Активен';

  @override
  String get branchStatusInactive => 'Неактивен';

  @override
  String get branchScheduleClosedAllWeek => 'Закрыто всю неделю';

  @override
  String get branchDetailTitle => 'Детали филиала';

  @override
  String get branchEditAction => 'Редактировать';

  @override
  String get branchNotFoundTitle => 'Филиал не найден';

  @override
  String get branchNotFoundBody => 'Этого филиала нет в предпросмотре сессии.';

  @override
  String get branchBackToListAction => 'К списку филиалов';

  @override
  String get branchSectionBasics => 'Основная информация';

  @override
  String get branchSectionHours => 'Часы работы';

  @override
  String get branchSectionLocation => 'Местоположение (предпросмотр)';

  @override
  String get branchFieldName => 'Название филиала';

  @override
  String get branchFieldCity => 'Город';

  @override
  String get branchFieldAddress => 'Адрес';

  @override
  String get branchFieldPhone => 'Контактный телефон';

  @override
  String get branchFieldStatus => 'Статус филиала';

  @override
  String get branchFieldOpenTime => 'Открытие';

  @override
  String get branchFieldCloseTime => 'Закрытие';

  @override
  String get branchFieldLatitude => 'Широта (demo)';

  @override
  String get branchFieldLongitude => 'Долгота (demo)';

  @override
  String get branchDayClosed => 'Выходной';

  @override
  String get branchLocationDemoHint =>
      'Только demo-координаты — без карты и геокодинга на этом этапе.';

  @override
  String get branchEditorCreateTitle => 'Новый филиал';

  @override
  String get branchEditorEditTitle => 'Редактирование филиала';

  @override
  String get branchSaveAction => 'Сохранить филиал';

  @override
  String get branchCancelAction => 'Отмена';

  @override
  String get branchSaveSuccess => 'Филиал сохранён для этой сессии.';

  @override
  String get branchSaveFailed =>
      'Не удалось сохранить. Изменения остались в форме.';

  @override
  String get branchDiscardConfirmTitle => 'Отменить изменения?';

  @override
  String get branchDiscardConfirmBody =>
      'Несохранённые правки филиала будут потеряны.';

  @override
  String get branchDiscardConfirmAction => 'Отменить';

  @override
  String get branchValidationName => 'Введите название филиала';

  @override
  String get branchValidationCity => 'Введите город';

  @override
  String get branchValidationAddress => 'Введите адрес';

  @override
  String get branchValidationPhone => 'Введите корректный телефон';

  @override
  String get branchValidationTime => 'Используйте формат ЧЧ:ММ';

  @override
  String get branchValidationTimeOrder =>
      'Время закрытия должно быть позже открытия';

  @override
  String get branchValidationCoordinates => 'Введите корректные координаты';

  @override
  String get branchWeekdayMonday => 'Понедельник';

  @override
  String get branchWeekdayTuesday => 'Вторник';

  @override
  String get branchWeekdayWednesday => 'Среда';

  @override
  String get branchWeekdayThursday => 'Четверг';

  @override
  String get branchWeekdayFriday => 'Пятница';

  @override
  String get branchWeekdaySaturday => 'Суббота';

  @override
  String get branchWeekdaySunday => 'Воскресенье';

  @override
  String get businessCenterStaffTitle => 'Сотрудники и роли';

  @override
  String get businessCenterStaffBody =>
      'Предпросмотр команды, ролей и доступа к филиалам только в этой сессии.';

  @override
  String get staffListTitle => 'Сотрудники и роли';

  @override
  String get staffPreviewNotice =>
      'Предпросмотр — без SMS, email и реальных приглашений. Сохраняется только в сессии.';

  @override
  String get staffAddAction => 'Добавить сотрудника';

  @override
  String get staffEmptyTitle => 'Сотрудников пока нет';

  @override
  String get staffEmptyBody =>
      'Добавьте сотрудника предпросмотра и назначьте филиалы.';

  @override
  String get staffEditAction => 'Редактировать';

  @override
  String get staffDetailTitle => 'Сотрудник';

  @override
  String get staffNotFoundTitle => 'Сотрудник не найден';

  @override
  String get staffNotFoundBody =>
      'Этого сотрудника нет в предпросмотре сессии.';

  @override
  String get staffBackToListAction => 'К списку сотрудников';

  @override
  String get staffSectionBasics => 'Основная информация';

  @override
  String get staffSectionRole => 'Роль в бизнесе';

  @override
  String get staffSectionBranches => 'Назначенные филиалы';

  @override
  String get staffFieldFirstName => 'Имя';

  @override
  String get staffFieldLastName => 'Фамилия';

  @override
  String get staffFieldPhone => 'Телефон';

  @override
  String get staffFieldEmail => 'Email';

  @override
  String get staffFieldEmailOptional => 'Email (необязательно)';

  @override
  String get staffFieldRole => 'Роль';

  @override
  String get staffFieldActive => 'Активен в предпросмотре';

  @override
  String get staffFieldActiveHint =>
      'Неактивный статус помечает сотрудника как удалённого только в предпросмотре.';

  @override
  String get staffBranchSelectionHint =>
      'Выберите хотя бы один филиал. Права действуют только для назначенных филиалов.';

  @override
  String get staffNoBranchesAvailable =>
      'Сначала добавьте филиал предпросмотра.';

  @override
  String get staffEditorCreateTitle => 'Новый сотрудник';

  @override
  String get staffEditorEditTitle => 'Редактирование сотрудника';

  @override
  String get staffSaveAction => 'Сохранить сотрудника';

  @override
  String get staffCancelAction => 'Отмена';

  @override
  String get staffSaveSuccess => 'Сотрудник сохранён для этой сессии.';

  @override
  String get staffSaveFailed =>
      'Не удалось сохранить. Изменения остались в форме.';

  @override
  String get staffDiscardConfirmTitle => 'Отменить изменения?';

  @override
  String get staffDiscardConfirmBody =>
      'Несохранённые правки сотрудника будут потеряны.';

  @override
  String get staffDiscardConfirmAction => 'Отменить';

  @override
  String get staffValidationFirstName => 'Введите имя';

  @override
  String get staffValidationPhone => 'Введите корректный телефон';

  @override
  String get staffValidationEmail => 'Введите корректный email';

  @override
  String get staffValidationRoleNotAssignable =>
      'Эту роль нельзя назначить здесь.';

  @override
  String get staffValidationBranchRequired => 'Выберите хотя бы один филиал.';

  @override
  String get staffInvalidScopeMessage =>
      'Один или несколько филиалов недоступны в этом предпросмотре.';

  @override
  String get staffOwnerNotEditableMessage =>
      'Владельца бизнеса предпросмотра нельзя редактировать в этой форме.';

  @override
  String get staffRoleBusinessOwner => 'Владелец бизнеса';

  @override
  String get staffRoleBusinessAdmin => 'Администратор бизнеса';

  @override
  String get staffRoleBranchManager => 'Менеджер филиала';

  @override
  String get staffRoleStaff => 'Сотрудник';

  @override
  String get staffRoleReadOnly => 'Только просмотр';

  @override
  String get staffStatusActivePreview => 'Активен (предпросмотр)';

  @override
  String get staffStatusInvitePendingPreview =>
      'Приглашение ожидается (только предпросмотр)';

  @override
  String get staffStatusRemovedPreview => 'Удалён (предпросмотр)';

  @override
  String staffBranchesLabel(String names) {
    return 'Филиалы: $names';
  }

  @override
  String get staffPermissionPreviewTitle => 'Предпросмотр прав';

  @override
  String get staffPermissionPreviewDisclaimer =>
      'Только demo UI — backend авторизация ещё не подключена.';

  @override
  String get staffPermSummaryOwner =>
      'Полный контроль в предпросмотре (нельзя назначить новому сотруднику).';

  @override
  String get staffPermSummaryAdmin =>
      'Управление филиалами и сотрудниками в предпросмотре бизнеса.';

  @override
  String get staffPermSummaryBranchManager =>
      'Работа только в назначенных филиалах.';

  @override
  String get staffPermSummaryStaff =>
      'Ежедневные задачи в назначенных филиалах.';

  @override
  String get staffPermSummaryReadOnly =>
      'Просмотр данных предпросмотра без редактирования.';

  @override
  String get staffPermManageBusiness => 'Настройки предпросмотра бизнеса';

  @override
  String get staffPermManageBranches => 'Записи филиалов предпросмотра';

  @override
  String get staffPermManageStaff => 'Записи сотрудников предпросмотра';

  @override
  String get staffPermViewReports => 'Отчёты предпросмотра';

  @override
  String get staffPermManageAssignedBranches => 'Данные назначенных филиалов';

  @override
  String get staffPermViewBranchReports => 'Отчёты назначенных филиалов';

  @override
  String get staffPermExecuteAssignedTasks => 'Задачи в назначенных филиалах';

  @override
  String get staffPermViewAssignedBranch =>
      'Просмотр данных назначенных филиалов';

  @override
  String get staffPermViewBusinessPreview =>
      'Просмотр данных бизнеса (read-only)';

  @override
  String get businessCenterBranchPermissionsTitle => 'Права филиалов';

  @override
  String get businessCenterBranchPermissionsBody =>
      'Предпросмотр доступа сотрудников и действий по филиалам только в этой сессии.';

  @override
  String get branchPermPageTitle => 'Права филиалов';

  @override
  String get branchPermPreviewNotice =>
      'Предпросмотр — права сохраняются только в этой сессии. Реальные серверные права ещё не подключены.';

  @override
  String get branchPermSelectStaff => 'Сотрудник';

  @override
  String get branchPermSelectBranch => 'Филиал';

  @override
  String get branchPermAccessStatusTitle => 'Доступ к филиалу';

  @override
  String get branchPermAccessGrantedPreview =>
      'Назначен на этот филиал (предпросмотр)';

  @override
  String get branchPermAccessNonePreview =>
      'Нет доступа — сотрудник не назначен на этот филиал';

  @override
  String get branchPermUnassignedBranchHint =>
      'Сначала назначьте сотрудника на филиал в разделе «Сотрудники и роли».';

  @override
  String get branchPermOwnerNotEditable =>
      'Права владельца предпросмотра нельзя изменить здесь.';

  @override
  String get branchPermRoleSuggestedHint =>
      'Рекомендации роли отличаются от явных прав филиала ниже.';

  @override
  String get branchPermSuggestedVsExplicitNotice =>
      'Возможности роли — только подсказка; переключатели ниже задают явные права предпросмотра для филиала.';

  @override
  String get branchPermGroupView => 'Просмотр';

  @override
  String get branchPermGroupEdit => 'Редактирование';

  @override
  String get branchPermGroupStaff => 'Управление персоналом';

  @override
  String get branchPermViewBranch => 'Просмотр филиала';

  @override
  String get branchPermEditBranchProfile => 'Редактирование профиля филиала';

  @override
  String get branchPermManageBranchHours => 'Управление часами работы';

  @override
  String get branchPermViewStaff => 'Просмотр сотрудников';

  @override
  String get branchPermManageBranchStaff => 'Управление staff филиала';

  @override
  String get branchPermViewBusinessProfile => 'Просмотр профиля бизнеса';

  @override
  String get branchPermDescViewBranch =>
      'Просмотр данных филиала в предпросмотре.';

  @override
  String get branchPermDescEditBranchProfile =>
      'Редактирование названия, адреса и контактов филиала.';

  @override
  String get branchPermDescManageBranchHours =>
      'Редактирование часов работы в предпросмотре.';

  @override
  String get branchPermDescViewStaff =>
      'Просмотр staff, связанного с филиалом.';

  @override
  String get branchPermDescManageBranchStaff =>
      'Назначение или удаление staff филиала в предпросмотре.';

  @override
  String get branchPermDescViewBusinessProfile =>
      'Просмотр профиля бизнеса в предпросмотре.';

  @override
  String get branchPermSaveAction => 'Сохранить права';

  @override
  String get branchPermCancelAction => 'Отмена';

  @override
  String get branchPermSaveSuccess =>
      'Права филиала сохранены для этой сессии.';

  @override
  String get branchPermSaveFailed =>
      'Не удалось сохранить. Изменения остались на экране.';

  @override
  String get branchPermInvalidScopeMessage =>
      'Недопустимый сотрудник или филиал для этого предпросмотра.';

  @override
  String get branchPermDiscardConfirmTitle => 'Отменить изменения?';

  @override
  String get branchPermDiscardConfirmBody =>
      'Несохранённые изменения прав будут потеряны.';

  @override
  String get branchPermDiscardConfirmAction => 'Отменить';

  @override
  String get businessCenterCatalogTitle => 'Каталог';

  @override
  String get businessCenterCatalogBody =>
      'Предпросмотр категорий и статистики каталога только для этой сессии.';

  @override
  String get catalogHomeTitle => 'Каталог';

  @override
  String get catalogPreviewNotice =>
      'Предпросмотр — данные каталога сохраняются только в этой сессии. Не связаны с публичным поиском и заказами.';

  @override
  String get catalogHomeIntro =>
      'Организуйте товары и услуги для предпросмотра бизнеса. Синхронизация с клиентским каталогом — в следующей фазе.';

  @override
  String get catalogStatCategories => 'Категории';

  @override
  String get catalogStatProducts => 'Товары';

  @override
  String get catalogStatServices => 'Услуги';

  @override
  String get catalogStatActiveItems => 'Активные позиции';

  @override
  String get catalogStatDraftItems => 'Черновики';

  @override
  String get catalogManageCategoriesTitle => 'Управление категориями';

  @override
  String get catalogManageCategoriesBody =>
      'Создавайте и редактируйте многоязычные категории для предпросмотра.';

  @override
  String get catalogProductsSectionTitle => 'Товары';

  @override
  String get catalogProductsSectionBody =>
      'Полное управление товарами — в Phase 09.2.';

  @override
  String get catalogServicesSectionTitle => 'Услуги';

  @override
  String get catalogServicesSectionBody =>
      'Полное управление услугами — в Phase 09.2.';

  @override
  String get catalogComingSoonLabel => 'Следующая фаза';

  @override
  String get catalogCategoryListTitle => 'Категории';

  @override
  String get catalogCategoryAddAction => 'Добавить категорию';

  @override
  String get catalogCategorySearchLabel => 'Поиск категорий';

  @override
  String get catalogCategoryEmptyTitle => 'Категорий пока нет';

  @override
  String get catalogCategoryEmptyBody =>
      'Добавьте категорию для организации предпросмотра каталога.';

  @override
  String get catalogCategoryDetailTitle => 'Категория';

  @override
  String get catalogCategoryEditAction => 'Редактировать';

  @override
  String get catalogCategoryCreateTitle => 'Новая категория';

  @override
  String get catalogCategoryEditTitle => 'Редактировать категорию';

  @override
  String get catalogCategoryNotFoundTitle => 'Категория не найдена';

  @override
  String get catalogCategoryNotFoundBody =>
      'Эта категория не входит в текущий предпросмотр бизнеса.';

  @override
  String get catalogCategoryBackToListAction => 'К списку категорий';

  @override
  String get catalogCategoryNamesSection => 'Названия';

  @override
  String get catalogCategoryDescriptionsSection => 'Описания';

  @override
  String get catalogCategoryFieldEmpty => '—';

  @override
  String get catalogLanguageUz => 'Узбекский';

  @override
  String get catalogLanguageRu => 'Русский';

  @override
  String get catalogLanguageEn => 'Английский';

  @override
  String catalogCategoryParentLabel(String name) {
    return 'Родитель: $name';
  }

  @override
  String get catalogCategoryStatusActive => 'Активна';

  @override
  String get catalogCategoryStatusDraft => 'Черновик';

  @override
  String get catalogCategoryStatusArchived => 'В архиве';

  @override
  String get catalogCategoryFormNameHint =>
      'Укажите название хотя бы на одном языке (узбекский, русский или английский).';

  @override
  String get catalogCategoryNameRequiredHint =>
      'Введите название категории хотя бы на одном языке.';

  @override
  String get catalogCategoryNameUzLabel => 'Название (узбекский)';

  @override
  String get catalogCategoryNameRuLabel => 'Название (русский)';

  @override
  String get catalogCategoryNameEnLabel => 'Название (английский)';

  @override
  String get catalogCategoryDescUzLabel =>
      'Описание (узбекский, необязательно)';

  @override
  String get catalogCategoryDescRuLabel => 'Описание (русский, необязательно)';

  @override
  String get catalogCategoryDescEnLabel =>
      'Описание (английский, необязательно)';

  @override
  String get catalogCategoryStatusLabel => 'Статус';

  @override
  String get catalogCategoryParentFieldLabel =>
      'Родительская категория (необязательно)';

  @override
  String get catalogCategoryNoParent => 'Без родителя';

  @override
  String get catalogCategorySaveAction => 'Сохранить';

  @override
  String get catalogCategoryCancelAction => 'Отмена';

  @override
  String get catalogCategorySaveSuccess =>
      'Категория сохранена для этой сессии.';

  @override
  String get catalogCategorySaveFailed =>
      'Не удалось сохранить. Данные остались на экране.';

  @override
  String get catalogCategoryDuplicateNameError =>
      'Категория с таким названием уже есть в этом предпросмотре.';

  @override
  String get catalogCategoryInvalidParentError =>
      'Выберите корректную родительскую категорию без циклической иерархии.';

  @override
  String get catalogCategoryDiscardConfirmTitle => 'Отменить изменения?';

  @override
  String get catalogCategoryDiscardConfirmBody =>
      'Несохранённые изменения категории будут потеряны.';

  @override
  String get catalogCategoryDiscardCancelAction => 'Продолжить редактирование';

  @override
  String get catalogCategoryDiscardConfirmAction => 'Отменить';

  @override
  String get catalogListingStatusActive => 'Активен';

  @override
  String get catalogListingStatusDraft => 'Черновик';

  @override
  String get catalogListingStatusArchived => 'В архиве';

  @override
  String get catalogStatArchivedItems => 'В архиве';

  @override
  String get catalogListingSearchLabel => 'Поиск по названию';

  @override
  String get catalogListingCategoryFilter => 'Фильтр категории';

  @override
  String get catalogListingStatusFilter => 'Фильтр статуса';

  @override
  String get catalogListingAllCategories => 'Все категории';

  @override
  String get catalogListingAllStatuses => 'Все статусы';

  @override
  String get catalogListingClearFilters => 'Сбросить фильтры';

  @override
  String catalogListingFilteredCount(int filtered, int total) {
    return 'Показано $filtered из $total';
  }

  @override
  String get catalogListingCategoryField => 'Категория';

  @override
  String get catalogListingCategoryRequired => 'Выберите категорию.';

  @override
  String get catalogListingInvalidCategory =>
      'Категория не в предпросмотре этого бизнеса.';

  @override
  String catalogListingCategoryLabel(String name) {
    return 'Категория: $name';
  }

  @override
  String catalogHomeFilteredCount(int filtered, int total) {
    return 'Показано $filtered из $total в preview';
  }

  @override
  String get catalogProductListTitle => 'Товары';

  @override
  String get catalogProductAddAction => 'Добавить товар';

  @override
  String get catalogProductEmptyBody => 'Нет товаров по фильтрам.';

  @override
  String get catalogProductDetailTitle => 'Товар';

  @override
  String get catalogProductCreateTitle => 'Новый товар';

  @override
  String get catalogProductEditTitle => 'Редактировать товар';

  @override
  String get catalogProductNotFoundTitle => 'Товар не найден';

  @override
  String get catalogProductBackToListAction => 'К списку товаров';

  @override
  String get catalogProductSaveSuccess => 'Товар сохранён для этой сессии.';

  @override
  String get catalogProductSaveFailed =>
      'Не удалось сохранить. Данные на экране.';

  @override
  String get catalogProductAttributeKeyLabel => 'Ключ атрибута (необяз.)';

  @override
  String get catalogProductAttributeValueLabel => 'Значение атрибута (необяз.)';

  @override
  String catalogProductVariantsTitle(int count) {
    return 'Варианты ($count)';
  }

  @override
  String get catalogProductVariantsManageTitle => 'Варианты товара';

  @override
  String get catalogServiceListTitle => 'Услуги';

  @override
  String get catalogServiceAddAction => 'Добавить услугу';

  @override
  String get catalogServiceEmptyBody => 'Нет услуг по фильтрам.';

  @override
  String get catalogServiceDetailTitle => 'Услуга';

  @override
  String get catalogServiceCreateTitle => 'Новая услуга';

  @override
  String get catalogServiceEditTitle => 'Редактировать услугу';

  @override
  String get catalogServiceBackToListAction => 'К списку услуг';

  @override
  String get catalogServiceSaveSuccess => 'Услуга сохранена для этой сессии.';

  @override
  String get catalogServiceSaveFailed => 'Не удалось сохранить.';

  @override
  String get catalogServiceInvalidDuration =>
      'Длительность — положительное число минут.';

  @override
  String get catalogServiceDurationFieldOptional =>
      'Длительность (мин., необяз.)';

  @override
  String catalogServiceDurationLabel(int minutes) {
    return 'Длительность: $minutes мин';
  }

  @override
  String get catalogVariantAddAction => 'Добавить вариант';

  @override
  String get catalogVariantEmptyBody => 'Вариантов пока нет.';

  @override
  String get catalogVariantCreateTitle => 'Новый вариант';

  @override
  String get catalogVariantEditTitle => 'Редактировать вариант';

  @override
  String get catalogVariantLabelField => 'Название варианта';

  @override
  String get catalogVariantSkuField => 'SKU';

  @override
  String get catalogVariantLabelRequired => 'Введите название варианта.';

  @override
  String get catalogVariantSkuRequired => 'Введите SKU.';

  @override
  String get catalogVariantSaveSuccess => 'Вариант сохранён для этой сессии.';

  @override
  String get catalogVariantSaveFailed => 'Не удалось сохранить вариант.';

  @override
  String get catalogVariantDuplicateSku => 'Такой SKU уже есть в preview.';

  @override
  String get catalogOptionSelectionSingle => 'Один вариант';

  @override
  String get catalogOptionSelectionMultiple => 'Несколько';

  @override
  String get catalogProductOptionsSectionTitle => 'Опции и дополнения';

  @override
  String get catalogProductOptionsEmptyBody => 'Групп опций пока нет.';

  @override
  String get catalogProductOptionsRequiresSaveHint =>
      'Сначала сохраните товар, чтобы управлять опциями и медиа.';

  @override
  String get catalogProductOptionGroupAddAction => 'Добавить группу';

  @override
  String get catalogProductOptionGroupCreateTitle => 'Новая группа опций';

  @override
  String get catalogProductOptionGroupEditTitle => 'Редактировать группу';

  @override
  String get catalogProductOptionGroupRequired => 'Обязательно';

  @override
  String get catalogProductOptionGroupOptional => 'Необязательно';

  @override
  String get catalogProductOptionSelectionModeLabel => 'Режим выбора';

  @override
  String get catalogProductOptionMinSelectionsLabel => 'Минимум выборов';

  @override
  String get catalogProductOptionMaxSelectionsLabel => 'Максимум выборов';

  @override
  String catalogProductOptionSelectionLimits(int min, int max) {
    return 'Выбор $min–$max';
  }

  @override
  String get catalogProductOptionGroupSaveSuccess =>
      'Группа сохранена для сессии.';

  @override
  String get catalogProductOptionGroupSaveFailed =>
      'Не удалось сохранить группу.';

  @override
  String get catalogProductOptionGroupInvalidInput =>
      'Проверьте лимиты и названия.';

  @override
  String get catalogProductOptionGroupArchiveTitle => 'Архивировать группу?';

  @override
  String get catalogProductOptionGroupArchiveBody =>
      'Группа скроется из активных списков preview.';

  @override
  String get catalogProductOptionGroupArchiveConfirm => 'Архивировать';

  @override
  String get catalogProductOptionGroupArchiveSuccess => 'Группа архивирована.';

  @override
  String get catalogProductOptionAddAction => 'Добавить опцию';

  @override
  String get catalogProductOptionCreateTitle => 'Новая опция';

  @override
  String get catalogProductOptionEditTitle => 'Редактировать опцию';

  @override
  String get catalogProductOptionActiveLabel => 'Активна';

  @override
  String get catalogProductOptionInactiveLabel => 'Неактивна';

  @override
  String get catalogProductOptionSaveSuccess => 'Опция сохранена для сессии.';

  @override
  String get catalogProductOptionSaveFailed => 'Не удалось сохранить опцию.';

  @override
  String get catalogProductOptionInvalidInput =>
      'Введите название хотя бы на одном языке.';

  @override
  String get catalogProductMediaGalleryTitle => 'Галерея';

  @override
  String get catalogProductMediaPreviewOnlyNotice =>
      'Только preview — загрузка позже. Изображения остаются в сессии и не отправляются на сервер.';

  @override
  String get catalogProductMediaEmptyBody => 'Изображений пока нет.';

  @override
  String get catalogProductMediaNoPrimary => 'Основное изображение не выбранo';

  @override
  String get catalogProductMediaPrimaryBadge => 'Основное';

  @override
  String get catalogProductMediaAddAction => 'Добавить изображение';

  @override
  String get catalogProductMediaMakePrimaryAction => 'Сделать основным';

  @override
  String get catalogProductMediaPickFailed =>
      'Не удалось прочитать изображение.';

  @override
  String get catalogProductMediaPreviewAdded => 'Preview добавлен для сессии.';

  @override
  String get catalogProductMediaSaveFailed => 'Не удалось обновить preview.';

  @override
  String get catalogAttributeValueKindText => 'Текст';

  @override
  String get catalogAttributeValueKindNumber => 'Число';

  @override
  String get catalogAttributeValueKindChoice => 'Выбор';

  @override
  String get catalogListingAttributesSectionTitle => 'Атрибуты';

  @override
  String get catalogListingAttributesEmptyBody => 'Атрибутов пока нет.';

  @override
  String get catalogListingAttributeAddAction => 'Добавить атрибут';

  @override
  String get catalogListingAttributeCreateTitle => 'Новый атрибут';

  @override
  String get catalogListingAttributeEditTitle => 'Редактировать атрибут';

  @override
  String get catalogListingAttributeKeyLabel => 'Ключ атрибута';

  @override
  String get catalogListingAttributeKeyHint =>
      'Строчные буквы, цифры и подчёркивания.';

  @override
  String get catalogListingAttributeKeyRequired => 'Введите ключ.';

  @override
  String get catalogListingAttributeKeyInvalid => 'Недопустимый формат ключа.';

  @override
  String get catalogListingAttributeValueKindLabel => 'Тип значения';

  @override
  String get catalogListingAttributeTextValueLabel => 'Текстовое значение';

  @override
  String get catalogListingAttributeNumberValueLabel => 'Числовое значение';

  @override
  String get catalogListingAttributeChoiceValueLabel => 'Значение выбора';

  @override
  String get catalogListingAttributeSaveSuccess =>
      'Атрибут сохранён для сессии.';

  @override
  String get catalogListingAttributeSaveFailed =>
      'Не удалось сохранить атрибут.';

  @override
  String get catalogListingAttributeInvalidInput =>
      'Проверьте ключ, название и значение.';

  @override
  String get catalogListingAttributeDuplicateKey =>
      'Такой ключ уже есть у этой позиции.';

  @override
  String get catalogListingAttributeDeleteTitle => 'Удалить атрибут?';

  @override
  String get catalogListingAttributeDeleteBody =>
      'Атрибут будет удалён из preview сессии.';

  @override
  String get catalogListingAttributeDeleteConfirm => 'Удалить';

  @override
  String get catalogListingAttributeDeleteFailed =>
      'Не удалось удалить атрибут.';

  @override
  String get catalogInventorySectionTitle => 'Остатки товаров (preview)';

  @override
  String get catalogInventorySectionBody =>
      'Учёт on-hand и reserved по филиалам для товаров каталога. Только demo — не связано с live-складом.';

  @override
  String get catalogInventoryListTitle => 'Остатки';

  @override
  String get catalogInventoryDemoDisclaimer =>
      'Demo-данные — не связаны с live-складом. Изменения только в preview-сессии.';

  @override
  String get catalogInventoryBranchFilter => 'Филиал';

  @override
  String get catalogInventoryAllBranches => 'Все филиалы';

  @override
  String get catalogInventoryAvailabilityFilter => 'Доступность';

  @override
  String get catalogInventoryAllAvailability => 'Все состояния';

  @override
  String get catalogInventoryEmptyBody => 'Нет строк по выбранным фильтрам.';

  @override
  String get catalogInventoryLoadFailed =>
      'Не удалось загрузить остатки для preview-сессии.';

  @override
  String get catalogInventoryRetryAction => 'Повторить';

  @override
  String catalogInventoryVariantLabel(String name) {
    return 'Вариант: $name';
  }

  @override
  String catalogInventoryBranchLabel(String name) {
    return 'Филиал: $name';
  }

  @override
  String catalogInventoryOnHandLabel(int qty) {
    return 'На складе: $qty';
  }

  @override
  String catalogInventoryReservedLabel(int qty) {
    return 'Зарезервировано: $qty';
  }

  @override
  String catalogInventoryAvailableLabel(int qty) {
    return 'Доступно: $qty';
  }

  @override
  String catalogInventoryLowStockThresholdLabel(int qty) {
    return 'Низкий остаток от: $qty';
  }

  @override
  String get catalogInventoryAvailabilityInStock => 'В наличии';

  @override
  String get catalogInventoryAvailabilityLowStock => 'Мало на складе';

  @override
  String get catalogInventoryAvailabilityOutOfStock => 'Нет в наличии';

  @override
  String get catalogInventoryAvailabilityUnavailable => 'Недоступно';

  @override
  String get catalogInventoryAdjustAction => 'Корректировка';

  @override
  String get catalogInventoryMarkUnavailableAction => 'Сделать недоступным';

  @override
  String get catalogInventoryMarkAvailableAction => 'Сделать доступным';

  @override
  String get catalogInventoryShowHistoryAction => 'История';

  @override
  String get catalogInventoryHideHistoryAction => 'Скрыть историю';

  @override
  String get catalogInventoryHistoryEmpty =>
      'В этой preview-сессии корректировок пока нет.';

  @override
  String catalogInventoryHistoryLine(
    int delta,
    int before,
    int after,
    String reason,
  ) {
    return 'Δ $delta · на складе $before → $after · $reason';
  }

  @override
  String get catalogInventoryAdjustTitle => 'Корректировка остатка';

  @override
  String get catalogInventoryAdjustKindLabel => 'Тип';

  @override
  String get catalogInventoryAdjustKindOnHand => 'On-hand';

  @override
  String get catalogInventoryAdjustKindReserved => 'Reserved';

  @override
  String get catalogInventoryAdjustDeltaLabel => 'Изменение (+/−)';

  @override
  String get catalogInventoryAdjustDeltaHint =>
      'Отрицательное число уменьшает.';

  @override
  String get catalogInventoryAdjustReasonLabel => 'Причина';

  @override
  String get catalogInventoryAdjustConfirmAction => 'Применить';

  @override
  String get catalogInventoryAdjustReasonRequired =>
      'Укажите короткую причину.';

  @override
  String get catalogInventoryAdjustDeltaZero => 'Введите ненулевое изменение.';

  @override
  String get catalogInventoryAdjustDeltaInvalid => 'Введите целое число.';

  @override
  String get catalogInventoryAdjustInvalidQuantities =>
      'Изменение сделает количества недопустимыми.';

  @override
  String get catalogInventoryAdjustSaveFailed =>
      'Не удалось применить корректировку.';

  @override
  String get catalogInventoryAdjustSuccess =>
      'Остаток обновлён в preview-сессии.';

  @override
  String get catalogInventoryReservationsNavAction => 'Резервы';

  @override
  String get catalogInventoryReservationsTitle => 'Резервирование остатков';

  @override
  String get catalogInventoryReservationDemoDisclaimer =>
      'Demo-резервы — не связаны с live checkout или складом.';

  @override
  String get catalogInventoryReservationCreateAction => 'Зарезервировать';

  @override
  String get catalogInventoryReservationCreateTitle => 'Demo-резерв';

  @override
  String get catalogInventoryReservationCreateConfirm => 'Зарезервировать';

  @override
  String get catalogInventoryReservationCreateSuccess =>
      'Резерв создан в preview-сессии.';

  @override
  String get catalogInventoryReservationItemLabel => 'Строка остатка';

  @override
  String get catalogInventoryReservationItemRequired =>
      'Выберите строку остатка.';

  @override
  String get catalogInventoryReservationQuantityField => 'Количество';

  @override
  String catalogInventoryReservationQuantityLabel(int qty) {
    return 'Количество: $qty';
  }

  @override
  String get catalogInventoryReservationQuantityInvalid =>
      'Введите положительное количество.';

  @override
  String get catalogInventoryReservationExpiryMinutesField =>
      'Истекает через (минут)';

  @override
  String get catalogInventoryReservationExpiryInvalid =>
      'Срок должен быть в будущем.';

  @override
  String get catalogInventoryReservationInsufficientStock =>
      'Недостаточно доступного остатка.';

  @override
  String get catalogInventoryReservationItemUnavailable =>
      'Строка помечена как недоступная.';

  @override
  String get catalogInventoryReservationSaveFailed =>
      'Не удалось сохранить резерв.';

  @override
  String get catalogInventoryReservationEmpty =>
      'Резервов в preview-сессии пока нет.';

  @override
  String get catalogInventoryReservationStatusFilter => 'Статус';

  @override
  String get catalogInventoryReservationAllStatuses => 'Все статусы';

  @override
  String get catalogInventoryReservationStatusReserved => 'Зарезервировано';

  @override
  String get catalogInventoryReservationStatusConfirmed => 'Подтверждено';

  @override
  String get catalogInventoryReservationStatusReleased => 'Освобождено';

  @override
  String get catalogInventoryReservationStatusExpired => 'Истекло';

  @override
  String catalogInventoryReservationCreatedLabel(String date) {
    return 'Создано: $date';
  }

  @override
  String catalogInventoryReservationExpiresLabel(String date) {
    return 'Истекает: $date';
  }

  @override
  String get catalogInventoryReservationReleaseAction => 'Освободить';

  @override
  String get catalogInventoryReservationConfirmAction => 'Подтвердить продажу';

  @override
  String get catalogInventoryReservationExpireAction => 'Истечь';

  @override
  String get catalogInventoryReservationExpireAllDue => 'Истечь просроченные';

  @override
  String catalogInventoryReservationExpireAllResult(int count) {
    return 'Истекло резервов: $count.';
  }

  @override
  String get catalogInventoryReservationReleaseSuccess => 'Резерв освобождён.';

  @override
  String get catalogInventoryReservationConfirmSuccess =>
      'Резерв подтверждён (demo).';

  @override
  String get catalogInventoryReservationExpireSuccess => 'Резерв истёк.';

  @override
  String get catalogInventoryReservationHistoryEmpty =>
      'Событий lifecycle пока нет.';

  @override
  String catalogInventoryReservationHistoryLine(
    String action,
    String fromStatus,
    String toStatus,
    int quantity,
  ) {
    return '$action: $fromStatus → $toStatus · qty $quantity';
  }

  @override
  String get catalogInventoryReservationReconcileAction => 'Аудит';

  @override
  String get catalogInventoryReservationReconcileTitle =>
      'Аудит reserved (demo)';

  @override
  String get catalogInventoryReservationReconcileDemoNote =>
      'Сравнение активных резервов с inventory reserved. Stock не меняется.';

  @override
  String get catalogInventoryReservationReconcileClean => 'Расхождений нет.';

  @override
  String catalogInventoryReservationReconcileLine(
    String itemId,
    int expected,
    int actual,
  ) {
    return '$itemId: ожидалось $expected, факт $actual';
  }

  @override
  String get catalogResourceSectionTitle => 'Ресурсы и capacity (preview)';

  @override
  String get catalogResourceSectionBody =>
      'Оборудование, персонал и service capacity по филиалам — отдельно от stock.';

  @override
  String get catalogResourceListTitle => 'Ресурсы';

  @override
  String get catalogResourceDemoDisclaimer =>
      'Demo capacity — не связано с live-бронированием.';

  @override
  String get catalogResourceAddAction => 'Добавить ресурс';

  @override
  String get catalogResourceEmptyBody => 'Нет ресурсов по фильтрам.';

  @override
  String get catalogResourceBranchFilter => 'Филиал';

  @override
  String get catalogResourceAllBranches => 'Все филиалы';

  @override
  String get catalogResourceTypeFilter => 'Тип ресурса';

  @override
  String get catalogResourceAllTypes => 'Все типы';

  @override
  String get catalogResourceStatusFilter => 'Статус';

  @override
  String get catalogResourceAllStatuses => 'Все статусы';

  @override
  String get catalogResourceTypeEquipment => 'Оборудование';

  @override
  String get catalogResourceTypeStaff => 'Персонал';

  @override
  String get catalogResourceTypeServiceCapacity => 'Service capacity';

  @override
  String get catalogResourceStatusActive => 'Активен';

  @override
  String get catalogResourceStatusUnavailable => 'Недоступен';

  @override
  String get catalogResourceStatusArchived => 'Архив';

  @override
  String catalogResourceTotalLabel(int qty) {
    return 'Всего: $qty';
  }

  @override
  String catalogResourceAllocatedLabel(int qty) {
    return 'Allocated (demo): $qty';
  }

  @override
  String catalogResourceAvailableLabel(int qty) {
    return 'Доступно: $qty';
  }

  @override
  String catalogResourceUnitLabel(String unit) {
    return 'Единица: $unit';
  }

  @override
  String get catalogResourceEditAction => 'Изменить';

  @override
  String get catalogResourceChangeCapacityAction => 'Изменить capacity';

  @override
  String get catalogResourceMarkUnavailableAction => 'Сделать недоступным';

  @override
  String get catalogResourceMarkActiveAction => 'Сделать активным';

  @override
  String get catalogResourceArchiveAction => 'В архив';

  @override
  String get catalogResourceHistoryEmpty => 'Изменений capacity пока нет.';

  @override
  String catalogResourceHistoryLine(int before, int after, String reason) {
    return 'Total $before → $after · $reason';
  }

  @override
  String get catalogResourceCreateTitle => 'Новый ресурс';

  @override
  String get catalogResourceEditTitle => 'Редактировать ресурс';

  @override
  String get catalogResourceNameField => 'Название (EN preview)';

  @override
  String get catalogResourceUnitField => 'Единица capacity';

  @override
  String get catalogResourceTotalField => 'Total capacity';

  @override
  String get catalogResourceSaveAction => 'Сохранить';

  @override
  String get catalogResourceSaveSuccess => 'Ресурс сохранён в preview.';

  @override
  String get catalogResourceSaveFailed => 'Не удалось сохранить.';

  @override
  String get catalogResourceBranchRequired => 'Выберите филиал.';

  @override
  String get catalogResourceCapacityInvalid => 'Введите корректную capacity.';

  @override
  String get catalogResourceBelowAllocated =>
      'Total не может быть ниже demo allocated.';

  @override
  String get catalogResourceChangeCapacityTitle => 'Изменить total capacity';

  @override
  String get catalogResourceReasonField => 'Причина';

  @override
  String get catalogResourceReasonRequired => 'Укажите причину.';

  @override
  String get catalogResourceNoCapacityChange =>
      'Введите другое значение total.';

  @override
  String catalogResourceAllocatedHint(int qty) {
    return 'Demo allocated: $qty (только чтение).';
  }

  @override
  String get catalogResourceCapacityChangeSuccess =>
      'Capacity обновлена в preview.';

  @override
  String get catalogPricingSectionTitle => 'Базовые цены (preview)';

  @override
  String get catalogPricingSectionBody =>
      'Правила цен по филиалам и датам. Illustrative demo — не checkout.';

  @override
  String get catalogPricingListTitle => 'Цены';

  @override
  String get catalogPricingDemoDisclaimer =>
      'Illustrative demo prices — not connected to live checkout.';

  @override
  String get catalogPricingAddAction => 'Добавить правило';

  @override
  String get catalogPricingEmptyBody => 'Нет правил по фильтрам.';

  @override
  String get catalogPricingBranchFilter => 'Филиал';

  @override
  String get catalogPricingAllBranches => 'Все филиалы';

  @override
  String get catalogPricingKindFilter => 'Тип listing';

  @override
  String get catalogPricingAllKinds => 'Все типы';

  @override
  String get catalogPricingKindProduct => 'Product';

  @override
  String get catalogPricingKindService => 'Service';

  @override
  String get catalogPricingStatusFilter => 'Статус';

  @override
  String get catalogPricingAllStatuses => 'Все статусы';

  @override
  String get catalogPricingStatusDraft => 'Черновик';

  @override
  String get catalogPricingStatusActive => 'Активно';

  @override
  String get catalogPricingStatusArchived => 'Архив';

  @override
  String catalogPricingVariantLabel(String name) {
    return 'Variant: $name';
  }

  @override
  String catalogPricingBranchLabel(String name) {
    return 'Филиал: $name';
  }

  @override
  String catalogPricingAmountLabel(String amount) {
    return 'Сумма: $amount';
  }

  @override
  String catalogPricingEffectiveIntervalLabel(String from, String until) {
    return 'Период: $from → $until';
  }

  @override
  String get catalogPricingOpenEnded => 'без конца';

  @override
  String catalogPricingRevisionLabel(int revision) {
    return 'Ревизия: $revision';
  }

  @override
  String catalogPricingEffectivePreviewLine(String result) {
    return 'Effective на preview: $result';
  }

  @override
  String catalogPricingEffectiveFound(String amount) {
    return '$amount';
  }

  @override
  String get catalogPricingEffectiveNotFound => 'Нет активной цены';

  @override
  String get catalogPricingEffectiveAmbiguous =>
      'Неоднозначно — несколько активных цен';

  @override
  String get catalogPricingEditAction => 'Редактировать draft';

  @override
  String get catalogPricingActivateAction => 'Активировать';

  @override
  String get catalogPricingArchiveAction => 'В архив';

  @override
  String get catalogPricingShowHistoryAction => 'История';

  @override
  String get catalogPricingHideHistoryAction => 'Скрыть историю';

  @override
  String get catalogPricingHistoryEmpty => 'История пуста.';

  @override
  String catalogPricingHistoryLine(String action, String before, String after) {
    return '$action: $before → $after';
  }

  @override
  String get catalogPricingPreviewTitle => 'Preview effective price';

  @override
  String get catalogPricingPreviewBody => 'Выберите demo as-of дату.';

  @override
  String catalogPricingPreviewAsOfLabel(String date) {
    return 'As of: $date';
  }

  @override
  String get catalogPricingPreviewHint =>
      'Variant price имеет приоритет над base.';

  @override
  String get catalogPricingCreateTitle => 'Новое правило';

  @override
  String get catalogPricingEditTitle => 'Редактировать draft';

  @override
  String get catalogPricingVariantOptional => 'Variant (optional)';

  @override
  String get catalogPricingBaseListingPrice => 'Base listing';

  @override
  String get catalogPricingAmountField => 'Сумма (UZS, целые)';

  @override
  String get catalogPricingEffectiveFromField =>
      'Effective from (YYYY-MM-DD UTC)';

  @override
  String get catalogPricingEffectiveUntilField => 'Effective until (optional)';

  @override
  String get catalogPricingCurrencyHint => 'Валюта: UZS (целые сумы).';

  @override
  String get catalogPricingCancelAction => 'Отмена';

  @override
  String get catalogPricingSaveAction => 'Сохранить';

  @override
  String get catalogPricingScopeRequired => 'Выберите филиал и listing.';

  @override
  String get catalogPricingAmountInvalid => 'Некорректная сумма.';

  @override
  String get catalogPricingDateInvalid => 'Дата: YYYY-MM-DD.';

  @override
  String get catalogPricingActiveImmutable =>
      'Active нельзя менять молча — создайте revision.';

  @override
  String get catalogPricingSaveFailed => 'Не удалось сохранить.';

  @override
  String get catalogPricingEffectiveRangeInvalid =>
      'Until должно быть после from.';

  @override
  String get catalogPricingActivateOverlapError =>
      'Пересечение с другим active интервалом.';

  @override
  String get catalogDiscountSectionTitle => 'Скидки (preview)';

  @override
  String get catalogDiscountSectionBody =>
      'Illustrative discount rules — not checkout.';

  @override
  String get catalogDiscountListTitle => 'Скидки';

  @override
  String get catalogDiscountDemoDisclaimer =>
      'Illustrative discounts only — not connected to live checkout.';

  @override
  String get catalogDiscountAddAction => 'Добавить скидку';

  @override
  String get catalogDiscountEmptyBody => 'Нет правил по фильтрам.';

  @override
  String get catalogDiscountBranchFilter => 'Филиал';

  @override
  String get catalogDiscountAllBranches => 'Все филиалы';

  @override
  String get catalogDiscountScopeFilter => 'Scope';

  @override
  String get catalogDiscountAllScopes => 'Все scopes';

  @override
  String get catalogDiscountScopeBusinessWide => 'Business-wide';

  @override
  String get catalogDiscountScopeProduct => 'Product';

  @override
  String get catalogDiscountScopeService => 'Service';

  @override
  String get catalogDiscountStatusFilter => 'Статус';

  @override
  String get catalogDiscountAllStatuses => 'Все статусы';

  @override
  String get catalogDiscountTypeFilter => 'Тип скидки';

  @override
  String get catalogDiscountTypePercentage => 'Процент';

  @override
  String get catalogDiscountTypeFixed => 'Fixed UZS';

  @override
  String catalogDiscountPercentLabel(int percent) {
    return '$percent% off';
  }

  @override
  String catalogDiscountFixedLabel(String amount) {
    return '$amount off';
  }

  @override
  String catalogDiscountMinBasketLabel(String amount) {
    return 'Min basket: $amount';
  }

  @override
  String catalogDiscountPriorityLabel(int priority) {
    return 'Priority: $priority';
  }

  @override
  String get catalogDiscountEditAction => 'Edit draft';

  @override
  String get catalogDiscountActivateAction => 'Activate';

  @override
  String get catalogDiscountArchiveAction => 'Archive';

  @override
  String get catalogDiscountShowHistoryAction => 'History';

  @override
  String get catalogDiscountHideHistoryAction => 'Hide history';

  @override
  String get catalogDiscountHistoryEmpty => 'History empty.';

  @override
  String catalogDiscountHistoryLine(
    String action,
    String before,
    String after,
  ) {
    return '$action: rev $before → $after';
  }

  @override
  String get catalogDiscountPreviewTitle => 'Preview after discount';

  @override
  String get catalogDiscountPreviewListingKind => 'Listing type';

  @override
  String get catalogDiscountPreviewListing => 'Listing';

  @override
  String get catalogDiscountPreviewSubtotal => 'Subtotal (optional)';

  @override
  String get catalogDiscountPreviewNoBasePrice => 'No base price.';

  @override
  String get catalogDiscountPreviewNoDiscount => 'No discount preview.';

  @override
  String catalogDiscountPreviewApplied(
    String base,
    String discount,
    String finalAmount,
  ) {
    return 'Base $base · −$discount · final $finalAmount';
  }

  @override
  String get catalogDiscountPreviewNotApplied => 'No eligible discount.';

  @override
  String get catalogDiscountPreviewAmbiguous => 'Ambiguous top priority.';

  @override
  String get catalogDiscountCreateTitle => 'New discount';

  @override
  String get catalogDiscountEditTitle => 'Edit draft';

  @override
  String get catalogDiscountBasisPointsField => 'Basis points';

  @override
  String get catalogDiscountFixedAmountField => 'Fixed UZS';

  @override
  String get catalogDiscountMinBasketField => 'Min basket';

  @override
  String get catalogDiscountPriorityField => 'Priority';

  @override
  String get catalogDiscountScopeRequired => 'Select branch/target.';

  @override
  String get catalogDiscountValueInvalid => 'Invalid value.';

  @override
  String get catalogDiscountActiveImmutable =>
      'Active immutable — use revision.';

  @override
  String get catalogDiscountSaveFailed => 'Save failed.';

  @override
  String get catalogDiscountActivateOverlapError => 'Active interval overlap.';

  @override
  String get catalogPromoSectionTitle => 'Промокоды (preview)';

  @override
  String get catalogPromoSectionBody =>
      'Illustrative promo codes — not checkout.';

  @override
  String get catalogPromoListTitle => 'Промокоды';

  @override
  String get catalogPromoDemoDisclaimer =>
      'Promo-code preview only — no live redemption or checkout.';

  @override
  String get catalogPromoAddAction => 'Добавить промокод';

  @override
  String get catalogPromoEmptyBody => 'Нет промокодов по фильтрам.';

  @override
  String get catalogPromoBranchFilter => 'Филиал';

  @override
  String get catalogPromoAllBranches => 'Все филиалы';

  @override
  String get catalogPromoStatusFilter => 'Статус';

  @override
  String get catalogPromoAllStatuses => 'Все статусы';

  @override
  String get catalogPromoPreviewTitle => 'Preview eligibility';

  @override
  String get catalogPromoPreviewCode => 'Промокод';

  @override
  String get catalogPromoPreviewCustomer => 'Demo customer ref (optional)';

  @override
  String catalogPromoPreviewApplied(
    String base,
    String discount,
    String finalAmount,
  ) {
    return 'Base $base · −$discount · final $finalAmount';
  }

  @override
  String catalogPromoUsageSnapshotLine(int total, int customer) {
    return 'Usage: $total total · $customer customer';
  }

  @override
  String catalogPromoLinkedDiscountLabel(String id) {
    return 'Discount: $id';
  }

  @override
  String catalogPromoMaxTotalUsesLabel(int count) {
    return 'Max total: $count';
  }

  @override
  String catalogPromoMaxCustomerUsesLabel(int count) {
    return 'Max per customer: $count';
  }

  @override
  String get catalogPromoEditAction => 'Edit draft';

  @override
  String get catalogPromoActivateAction => 'Activate';

  @override
  String get catalogPromoArchiveAction => 'Archive';

  @override
  String get catalogPromoShowHistoryAction => 'History';

  @override
  String get catalogPromoShowUsageAction => 'Usage';

  @override
  String catalogPromoUsageLine(String customer, String redemption) {
    return '$customer · $redemption';
  }

  @override
  String get catalogPromoCreateTitle => 'New promo';

  @override
  String get catalogPromoEditTitle => 'Edit draft';

  @override
  String get catalogPromoCodeField => 'Code';

  @override
  String get catalogPromoMinBasketField => 'Min basket';

  @override
  String get catalogPromoMaxTotalUsesField => 'Max total uses';

  @override
  String get catalogPromoMaxCustomerUsesField => 'Max per customer';

  @override
  String get catalogPromoActivateDiscountError => 'Linked discount invalid.';

  @override
  String get catalogPromoSaveFailed => 'Save failed.';

  @override
  String get catalogPromoActiveImmutable => 'Active immutable.';

  @override
  String get catalogPromoEligibilityEligible => 'Eligible.';

  @override
  String get catalogPromoEligibilityInvalidCode => 'Invalid code.';

  @override
  String get catalogPromoEligibilityInactive => 'Inactive.';

  @override
  String get catalogPromoEligibilityNotYetValid => 'Not yet valid.';

  @override
  String get catalogPromoEligibilityExpired => 'Expired.';

  @override
  String get catalogPromoEligibilityScopeMismatch => 'Scope mismatch.';

  @override
  String get catalogPromoEligibilityDiscountUnavailable =>
      'Discount unavailable.';

  @override
  String get catalogPromoEligibilityMinimumBasket => 'Minimum basket not met.';

  @override
  String get catalogPromoEligibilityTotalLimit => 'Total limit reached.';

  @override
  String get catalogPromoEligibilityCustomerLimit => 'Customer limit reached.';

  @override
  String get catalogPromoEligibilityNoApplicableDiscount =>
      'Discount not applicable.';

  @override
  String get catalogPromoEligibilityBasePriceRequired => 'Base price required.';

  @override
  String get catalogCommercialFeeSectionTitle => 'Commercial fees (preview)';

  @override
  String get catalogCommercialFeeSectionBody =>
      'Illustrative fee rules — not settlement.';

  @override
  String get catalogCommercialFeeListTitle => 'Commercial fees';

  @override
  String get catalogCommercialFeeDemoDisclaimer =>
      'Illustrative commercial fees only — not connected to live checkout or settlement.';

  @override
  String get catalogCommercialFeeAddAction => 'Add fee rule';

  @override
  String get catalogCommercialFeeEmptyBody => 'No fee rules.';

  @override
  String get catalogCommercialFeeTypeFilter => 'Fee type';

  @override
  String get catalogCommercialFeeAllTypes => 'All types';

  @override
  String get catalogCommercialFeeStatusFilter => 'Status';

  @override
  String get catalogCommercialFeeAllStatuses => 'All statuses';

  @override
  String get catalogCommercialFeeBranchFilter => 'Branch';

  @override
  String get catalogCommercialFeeAllBranches => 'All branches';

  @override
  String get catalogCommercialFeeTypePlatform => 'Platform fee';

  @override
  String get catalogCommercialFeeTypeService => 'Service fee';

  @override
  String get catalogCommercialFeeTypeDelivery => 'Delivery fee';

  @override
  String get catalogCommercialFeeTypeCommission => 'Commission';

  @override
  String get catalogCommercialFeeBearerCustomer => 'Customer';

  @override
  String get catalogCommercialFeeBearerBusiness => 'Business';

  @override
  String get catalogCommercialFeeBearerPlatform => 'Platform accounting';

  @override
  String get catalogCommercialFeeCalcFixed => 'Fixed UZS';

  @override
  String get catalogCommercialFeeCalcPercent => 'Percentage';

  @override
  String get catalogCommercialFeeBasisListing => 'Listing base';

  @override
  String get catalogCommercialFeeBasisService => 'Service amount';

  @override
  String get catalogCommercialFeeBasisDelivery => 'Delivery basis';

  @override
  String get catalogCommercialFeeBasisCommission => 'Commission basis';

  @override
  String catalogCommercialFeePriorityLabel(int priority) {
    return 'Priority: $priority';
  }

  @override
  String get catalogCommercialFeeEditAction => 'Edit draft';

  @override
  String get catalogCommercialFeeActivateAction => 'Activate';

  @override
  String get catalogCommercialFeeArchiveAction => 'Archive';

  @override
  String get catalogCommercialFeeShowHistoryAction => 'History';

  @override
  String get catalogCommercialFeeHideHistoryAction => 'Hide history';

  @override
  String get catalogCommercialFeePreviewTitle => 'Fee preview';

  @override
  String get catalogCommercialFeePreviewListingBase => 'Listing base';

  @override
  String get catalogCommercialFeePreviewService => 'Service amount';

  @override
  String get catalogCommercialFeePreviewDelivery => 'Delivery basis';

  @override
  String get catalogCommercialFeePreviewCommission => 'Commission basis';

  @override
  String catalogCommercialFeePreviewLine(
    String type,
    String bearer,
    String basis,
    String fee,
  ) {
    return '$type · $bearer · $basis · $fee';
  }

  @override
  String catalogCommercialFeePreviewBasisMissing(String type, String bearer) {
    return '$type ($bearer): basis missing';
  }

  @override
  String catalogCommercialFeePreviewAmbiguous(String types) {
    return 'Ambiguous: $types';
  }

  @override
  String catalogCommercialFeePreviewTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get catalogCommercialFeeCreateTitle => 'New fee';

  @override
  String get catalogCommercialFeeEditTitle => 'Edit draft';

  @override
  String get catalogCommercialFeeFixedField => 'Fixed UZS';

  @override
  String get catalogCommercialFeeBasisPointsField => 'Basis points';

  @override
  String get catalogCommercialFeePriorityField => 'Priority';

  @override
  String get catalogCommercialFeeSaveFailed => 'Save failed.';

  @override
  String get catalogCommercialFeeActiveImmutable => 'Active immutable.';

  @override
  String get catalogCommercialFeeActivateOverlapError =>
      'Active interval overlap.';

  @override
  String get businessCenterFulfillmentTitle => 'Fulfillment settings';

  @override
  String get businessCenterFulfillmentBody =>
      'Delivery, pickup, on-site service (preview).';

  @override
  String get businessFulfillmentListTitle => 'Fulfillment';

  @override
  String get businessFulfillmentDemoDisclaimer =>
      'Demo fulfillment settings — not connected to live orders or delivery.';

  @override
  String get businessFulfillmentAddAction => 'Add configuration';

  @override
  String get businessFulfillmentEmptyBody => 'No configurations.';

  @override
  String get businessFulfillmentBranchFilter => 'Branch';

  @override
  String get businessFulfillmentAllBranches => 'All branches';

  @override
  String get businessFulfillmentTypeFilter => 'Type';

  @override
  String get businessFulfillmentAllTypes => 'All types';

  @override
  String get businessFulfillmentStatusFilter => 'Status';

  @override
  String get businessFulfillmentAllStatuses => 'All statuses';

  @override
  String get businessFulfillmentTypeDelivery => 'Delivery';

  @override
  String get businessFulfillmentTypePickup => 'Pickup';

  @override
  String get businessFulfillmentTypeServiceAtLocation => 'Service at location';

  @override
  String get businessFulfillmentScopeBusinessWide => 'Business-wide';

  @override
  String get businessFulfillmentScopeProduct => 'Product';

  @override
  String get businessFulfillmentScopeService => 'Service';

  @override
  String businessFulfillmentTypesLabel(String modes) {
    return 'Modes: $modes';
  }

  @override
  String get businessFulfillmentPreviewTitle => 'Preview';

  @override
  String get businessFulfillmentPreviewEmpty => 'None';

  @override
  String businessFulfillmentPreviewSelected(String modes) {
    return 'Supports: $modes';
  }

  @override
  String get businessFulfillmentEditAction => 'Edit draft';

  @override
  String get businessFulfillmentActivateAction => 'Activate';

  @override
  String get businessFulfillmentArchiveAction => 'Archive';

  @override
  String get businessFulfillmentShowHistoryAction => 'History';

  @override
  String get businessFulfillmentHideHistoryAction => 'Hide';

  @override
  String get businessFulfillmentCreateTitle => 'New configuration';

  @override
  String get businessFulfillmentEditTitle => 'Edit draft';

  @override
  String get businessFulfillmentListingIdField => 'Listing ID';

  @override
  String get businessFulfillmentTypesField => 'Modes';

  @override
  String get businessFulfillmentSaveFailed => 'Save failed.';

  @override
  String get businessFulfillmentActivateConflictError =>
      'Active configuration conflict.';

  @override
  String get businessFulfillmentSelectAtLeastOneType =>
      'Select at least one mode.';

  @override
  String get businessFulfillmentDeliveryTasksLink => 'Delivery tasks';

  @override
  String get businessFulfillmentDeliveryTasksBody =>
      'Demo delivery task lifecycle (separate from orders).';

  @override
  String get businessDeliveryTaskListTitle => 'Delivery tasks';

  @override
  String get businessDeliveryTaskDemoDisclaimer =>
      'Demo delivery tasks only — not connected to live orders, couriers or tracking.';

  @override
  String get businessDeliveryTaskEmptyBody =>
      'No delivery tasks match filters.';

  @override
  String get businessDeliveryTaskBranchFilter => 'Branch';

  @override
  String get businessDeliveryTaskAllBranches => 'All branches';

  @override
  String get businessDeliveryTaskStatusFilter => 'Status';

  @override
  String get businessDeliveryTaskAllStatuses => 'All statuses';

  @override
  String get businessDeliveryTaskStatusCreated => 'Created';

  @override
  String get businessDeliveryTaskStatusReadyForPickup => 'Ready for pickup';

  @override
  String get businessDeliveryTaskStatusAssigned => 'Assigned (demo)';

  @override
  String get businessDeliveryTaskStatusPickedUp => 'Picked up';

  @override
  String get businessDeliveryTaskStatusInTransit => 'In transit';

  @override
  String get businessDeliveryTaskStatusDelivered => 'Delivered';

  @override
  String get businessDeliveryTaskStatusFailed => 'Failed';

  @override
  String get businessDeliveryTaskStatusCancelled => 'Cancelled';

  @override
  String businessDeliveryTaskBranchLabel(String name) {
    return 'Branch: $name';
  }

  @override
  String businessDeliveryTaskStatusLine(String status) {
    return 'Status: $status';
  }

  @override
  String businessDeliveryTaskPickupLabel(String label) {
    return 'Pickup: $label';
  }

  @override
  String businessDeliveryTaskDropOffLabel(String label) {
    return 'Drop-off: $label';
  }

  @override
  String businessDeliveryTaskAssignmentLabel(String ref) {
    return 'Demo assignment: $ref';
  }

  @override
  String businessDeliveryTaskFailureLine(String reason) {
    return 'Failure: $reason';
  }

  @override
  String businessDeliveryTaskUpdatedAt(String timestamp) {
    return 'Updated: $timestamp';
  }

  @override
  String get businessDeliveryTaskActionReadyForPickup => 'Ready for pickup';

  @override
  String get businessDeliveryTaskActionAssignDemo => 'Assign (demo)';

  @override
  String get businessDeliveryTaskActionConfirmPickup => 'Confirm pickup';

  @override
  String get businessDeliveryTaskActionMarkInTransit => 'In transit';

  @override
  String get businessDeliveryTaskActionMarkDelivered => 'Delivered';

  @override
  String get businessDeliveryTaskActionMarkFailed => 'Failed';

  @override
  String get businessDeliveryTaskActionCancel => 'Cancel';

  @override
  String get businessDeliveryTaskShowHistoryAction => 'History';

  @override
  String get businessDeliveryTaskHideHistoryAction => 'Hide';

  @override
  String businessDeliveryTaskHistoryLine(
    String from,
    String to,
    String timestamp,
  ) {
    return '$from → $to at $timestamp';
  }

  @override
  String get businessDeliveryTaskFailureDialogTitle => 'Failure reason';

  @override
  String get businessDeliveryTaskFailureReasonLabel => 'Reason (demo)';

  @override
  String get businessDeliveryTaskFailureDialogCancel => 'Cancel';

  @override
  String get businessDeliveryTaskFailureDialogConfirm => 'Confirm';

  @override
  String get businessDeliveryTaskFailureReasonInvalid =>
      'Enter a failure reason.';

  @override
  String get businessDeliveryTaskTransitionInvalid =>
      'Status change not allowed.';

  @override
  String get businessDeliveryTaskTransitionSaveError =>
      'Could not save. Try again.';

  @override
  String get businessDeliveryExceptionDemoDisclaimer =>
      'Demo delivery exceptions — not the same as task failed status.';

  @override
  String get businessDeliveryProofDemoDisclaimer =>
      'Demo proof only — no real photo upload, OTP verification or signature storage.';

  @override
  String get businessDeliveryExceptionSectionTitle => 'Delivery exceptions';

  @override
  String get businessDeliveryProofSectionTitle => 'Proof of delivery';

  @override
  String get businessDeliveryExceptionAddAction => 'Log exception';

  @override
  String get businessDeliveryProofAddAction => 'Add demo proof';

  @override
  String get businessDeliveryExceptionEmptyForTask =>
      'No exceptions for this task.';

  @override
  String get businessDeliveryProofEmptyForTask => 'No proof for this task.';

  @override
  String get businessDeliveryExceptionCategoryRecipientUnavailable =>
      'Recipient unavailable';

  @override
  String get businessDeliveryExceptionCategoryAddressIssue => 'Address issue';

  @override
  String get businessDeliveryExceptionCategoryAccessBlocked => 'Access blocked';

  @override
  String get businessDeliveryExceptionCategoryDeliveryDelayed => 'Delayed';

  @override
  String get businessDeliveryExceptionCategoryItemIssue => 'Item issue';

  @override
  String get businessDeliveryExceptionCategoryOther => 'Other';

  @override
  String get businessDeliveryExceptionStatusOpen => 'Open';

  @override
  String get businessDeliveryExceptionStatusResolved => 'Resolved';

  @override
  String get businessDeliveryExceptionStatusDismissed => 'Dismissed';

  @override
  String get businessDeliveryExceptionSeverityLow => 'Low';

  @override
  String get businessDeliveryExceptionSeverityMedium => 'Medium';

  @override
  String get businessDeliveryExceptionSeverityHigh => 'High';

  @override
  String businessDeliveryExceptionLine(
    String category,
    String status,
    String reason,
  ) {
    return '$category · $status · $reason';
  }

  @override
  String businessDeliveryProofLine(
    String method,
    String status,
    String reference,
  ) {
    return '$method · $status · $reference';
  }

  @override
  String get businessDeliveryExceptionResolveAction => 'Resolve';

  @override
  String get businessDeliveryExceptionDismissAction => 'Dismiss';

  @override
  String get businessDeliveryExceptionReopenAction => 'Reopen';

  @override
  String get businessDeliveryProofVerifyDemoAction => 'Demo verify';

  @override
  String get businessDeliveryProofRejectDemoAction => 'Demo reject';

  @override
  String get businessDeliveryExceptionCreateTitle => 'Log exception';

  @override
  String get businessDeliveryExceptionReasonField => 'Reason';

  @override
  String get businessDeliveryExceptionCategoryField => 'Category';

  @override
  String get businessDeliveryExceptionResolveTitle => 'Resolve';

  @override
  String get businessDeliveryExceptionResolutionField => 'Resolution note';

  @override
  String get businessDeliveryProofCreateTitle => 'Add demo proof';

  @override
  String get businessDeliveryProofMethodField => 'Method';

  @override
  String get businessDeliveryProofEvidenceField => 'Demo evidence reference';

  @override
  String get businessDeliveryProofDescriptionField => 'Description';

  @override
  String get businessDeliveryProofVerifyTitle => 'Demo verification';

  @override
  String get businessDeliveryProofVerificationReasonField => 'Note (demo)';

  @override
  String get businessDeliveryDialogCancel => 'Cancel';

  @override
  String get businessDeliveryDialogSave => 'Save';

  @override
  String get businessDeliveryDialogConfirm => 'Confirm';

  @override
  String get businessDeliveryExceptionSaveError => 'Could not save exception.';

  @override
  String get businessDeliveryProofSaveError => 'Could not save proof.';

  @override
  String get businessDeliveryExceptionValidationError =>
      'Check exception fields.';

  @override
  String get businessDeliveryProofValidationError =>
      'Use demo references only.';

  @override
  String get businessDeliveryProofMethodPhoto => 'Photo (demo)';

  @override
  String get businessDeliveryProofMethodRecipientOtp => 'OTP (demo)';

  @override
  String get businessDeliveryProofMethodSignature => 'Signature (demo)';

  @override
  String get businessDeliveryProofMethodRecipientConfirmation => 'Confirmation';

  @override
  String get businessDeliveryProofStatusPending => 'Pending';

  @override
  String get businessDeliveryProofStatusVerified => 'Verified (demo)';

  @override
  String get businessDeliveryProofStatusRejected => 'Rejected';

  @override
  String get businessDeliveryProofStatusSuperseded => 'Superseded';

  @override
  String get businessDeliveryExceptionHistoryAction => 'Exception history';

  @override
  String get businessDeliveryProofHistoryAction => 'Proof history';

  @override
  String get businessCenterReviewsTitle => 'Reviews & ratings';

  @override
  String get businessCenterReviewsBody =>
      'Demo verified reviews (synthetic evidence).';

  @override
  String get businessReviewListTitle => 'Reviews & ratings';

  @override
  String get businessReviewDemoDisclaimer =>
      'Demo reviews only — synthetic transaction evidence; no real customer reviews.';

  @override
  String get businessReviewDemoRatingNote =>
      'Demo rating summary — not production reputation.';

  @override
  String get businessReviewCreateDemoAction => 'Create demo review';

  @override
  String get businessReviewSummaryTitle => 'Rating summary';

  @override
  String businessReviewSummaryAverage(String average) {
    return 'Average: $average';
  }

  @override
  String businessReviewSummaryCount(int count) {
    return 'Published: $count';
  }

  @override
  String businessReviewDistributionLine(int stars, int count) {
    return '$stars★ — $count';
  }

  @override
  String get businessReviewBranchFilter => 'Branch';

  @override
  String get businessReviewAllBranches => 'All branches';

  @override
  String get businessReviewTargetTypeFilter => 'Target type';

  @override
  String get businessReviewAllTargetTypes => 'All types';

  @override
  String get businessReviewStatusFilter => 'Status';

  @override
  String get businessReviewAllStatuses => 'All statuses';

  @override
  String get businessReviewTargetBusiness => 'Business';

  @override
  String get businessReviewTargetProduct => 'Product';

  @override
  String get businessReviewTargetService => 'Service';

  @override
  String get businessReviewTargetBusinessScope => 'Business scope';

  @override
  String get businessReviewStatusDraft => 'Draft';

  @override
  String get businessReviewStatusPendingModeration => 'Pending moderation';

  @override
  String get businessReviewStatusPublished => 'Published';

  @override
  String get businessReviewStatusRejected => 'Rejected';

  @override
  String get businessReviewStatusHidden => 'Hidden';

  @override
  String get businessReviewEmptyBody => 'No reviews.';

  @override
  String businessReviewCardLine(
    String target,
    String type,
    String rating,
    String status,
  ) {
    return '$target · $type · $rating★ · $status';
  }

  @override
  String businessReviewProvenanceLine(String evidence, String reviewer) {
    return 'Evidence: $evidence · Reviewer: $reviewer';
  }

  @override
  String get businessReviewSyntheticBadge => 'Synthetic demo review.';

  @override
  String get businessReviewHistoryAction => 'History';

  @override
  String businessReviewHistoryLine(String from, String to, String timestamp) {
    return '$from → $to at $timestamp';
  }

  @override
  String get businessReviewActionSubmitModeration => 'Submit moderation';

  @override
  String get businessReviewActionPublish => 'Publish';

  @override
  String get businessReviewActionReject => 'Reject';

  @override
  String get businessReviewActionHide => 'Hide';

  @override
  String get businessReviewCreateDialogTitle => 'Create demo review';

  @override
  String get businessReviewSyntheticEvidenceNote => 'Synthetic evidence only.';

  @override
  String get businessReviewTargetTypeField => 'Target type';

  @override
  String get businessReviewTargetIdField => 'Target ID';

  @override
  String get businessReviewRatingField => 'Rating';

  @override
  String get businessReviewTitleField => 'Title';

  @override
  String get businessReviewTextField => 'Text';

  @override
  String get businessReviewCheckEligibilityAction => 'Check eligibility';

  @override
  String get businessReviewDialogCancel => 'Cancel';

  @override
  String get businessReviewDialogSave => 'Save';

  @override
  String get businessReviewDialogConfirm => 'Confirm';

  @override
  String get businessReviewSaveError => 'Could not save.';

  @override
  String get businessReviewCreateIneligible => 'Not eligible.';

  @override
  String get businessReviewValidationError => 'Invalid fields.';

  @override
  String get businessReviewModerationReasonTitle => 'Moderation note';

  @override
  String get businessReviewModerationReasonLabel => 'Reason';

  @override
  String get businessReviewEligibilityEligible => 'Eligible (demo).';

  @override
  String get businessReviewEligibilityEvidenceNotFound => 'Evidence not found.';

  @override
  String get businessReviewEligibilityIncomplete => 'Transaction incomplete.';

  @override
  String get businessReviewEligibilityScopeMismatch => 'Scope mismatch.';

  @override
  String get businessReviewEligibilityTargetMismatch =>
      'Target/reviewer mismatch.';

  @override
  String get businessReviewEligibilityDuplicate => 'Duplicate review.';

  @override
  String get businessCenterComplaintsDisputesTitle => 'Жалобы и споры';

  @override
  String get businessCenterComplaintsDisputesBody =>
      'Демо управление кейсами (preview).';

  @override
  String get businessComplaintDisputeListTitle => 'Жалобы и споры';

  @override
  String get businessComplaintDisputeDemoDisclaimer =>
      'Demo complaints and disputes only — synthetic cases and evidence; no real customer cases.';

  @override
  String get businessComplaintDisputeDemoResolutionNote =>
      'Решение демо-кейса не является реальным юридическим исходом.';

  @override
  String get businessComplaintTab => 'Жалобы';

  @override
  String get businessDisputeTab => 'Споры';

  @override
  String get businessComplaintCategoryFilter => 'Категория';

  @override
  String get businessComplaintAllCategories => 'Все категории';

  @override
  String get businessComplaintCategoryProductQuality => 'Качество товара';

  @override
  String get businessComplaintCategoryServiceIssue => 'Сервис';

  @override
  String get businessComplaintCategoryBilling => 'Оплата';

  @override
  String get businessComplaintCategoryDelivery => 'Доставка';

  @override
  String get businessComplaintCategoryOther => 'Другое';

  @override
  String get businessComplaintStatusSubmitted => 'Submitted';

  @override
  String get businessComplaintStatusUnderReview => 'Under review';

  @override
  String get businessComplaintStatusResolved => 'Resolved';

  @override
  String get businessComplaintStatusDismissed => 'Dismissed';

  @override
  String get businessDisputeStatusFiled => 'Filed';

  @override
  String get businessDisputeStatusUnderReview => 'Under review';

  @override
  String get businessDisputeStatusResolvedBusiness => 'Resolved (business)';

  @override
  String get businessDisputeStatusResolvedReporter => 'Resolved (reporter)';

  @override
  String get businessDisputeStatusDismissed => 'Dismissed';

  @override
  String get businessComplaintEmptyBody => 'Нет жалоб по фильтру.';

  @override
  String get businessDisputeEmptyBody => 'Нет споров по фильтру.';

  @override
  String businessComplaintCardLine(
    String target,
    String category,
    String status,
  ) {
    return '$target · $category · $status';
  }

  @override
  String businessDisputeCardLine(String complaintId, String status) {
    return 'Complaint $complaintId · $status';
  }

  @override
  String businessComplaintEvidenceLine(String refs, String reporter) {
    return 'Evidence: $refs · Reporter: $reporter';
  }

  @override
  String businessComplaintLinkedDispute(String disputeId) {
    return 'Спор: $disputeId';
  }

  @override
  String get businessComplaintNoDispute => 'Спор не подан.';

  @override
  String get businessComplaintCreateDemoAction => 'Demo complaint';

  @override
  String get businessDisputeCreateDemoAction => 'Demo dispute';

  @override
  String get businessComplaintActionBeginReview => 'Begin review';

  @override
  String get businessComplaintActionResolve => 'Resolve';

  @override
  String get businessComplaintActionDismiss => 'Dismiss';

  @override
  String get businessDisputeActionBeginReview => 'Begin review';

  @override
  String get businessDisputeActionResolveBusiness => 'For business';

  @override
  String get businessDisputeActionResolveReporter => 'For reporter';

  @override
  String get businessDisputeActionDismiss => 'Dismiss';

  @override
  String get businessComplaintHistoryAction => 'History';

  @override
  String get businessDisputeHistoryAction => 'History';

  @override
  String businessComplaintHistoryLine(
    String from,
    String to,
    String timestamp,
  ) {
    return '$from → $to · $timestamp';
  }

  @override
  String businessDisputeHistoryLine(String from, String to, String timestamp) {
    return '$from → $to · $timestamp';
  }

  @override
  String get businessComplaintSyntheticBadge => 'Synthetic demo case.';

  @override
  String get businessComplaintClearFilters => 'Clear filters';

  @override
  String get businessComplaintSaveError => 'Could not save complaint.';

  @override
  String get businessDisputeSaveError => 'Could not save dispute.';

  @override
  String get businessDisputeDuplicateError => 'Dispute already exists.';

  @override
  String get businessComplaintCreateDialogTitle => 'Demo complaint';

  @override
  String get businessDisputeCreateDialogTitle => 'Demo dispute';

  @override
  String get businessComplaintDescriptionField => 'Description';

  @override
  String get businessDisputeSummaryField => 'Summary';

  @override
  String get businessComplaintSelectComplaintField => 'Complaint';

  @override
  String get businessComplaintSyntheticEvidenceNote =>
      'Synthetic evidence only.';

  @override
  String get businessCenterReputationEventsTitle => 'Reputation events';

  @override
  String get businessCenterReputationEventsBody =>
      'Demo signal timeline (preview).';

  @override
  String get businessReputationEventsTitle => 'Reputation events';

  @override
  String get businessReputationEventsDemoDisclaimer =>
      'Demo reputation events only — synthetic signals; no production Trust Score is calculated.';

  @override
  String get businessReputationEventsInformationalNote =>
      'Informational signals only.';

  @override
  String get businessReputationEventSourceFilter => 'Source';

  @override
  String get businessReputationEventAllSources => 'All sources';

  @override
  String get businessReputationEventSourceReview => 'Review';

  @override
  String get businessReputationEventSourceComplaint => 'Complaint';

  @override
  String get businessReputationEventSourceDispute => 'Dispute';

  @override
  String get businessReputationEventTypeFilter => 'Event type';

  @override
  String get businessReputationEventAllTypes => 'All types';

  @override
  String get businessReputationEventTypeReviewPublished => 'Review published';

  @override
  String get businessReputationEventTypeReviewRejected => 'Review rejected';

  @override
  String get businessReputationEventTypeReviewHidden => 'Review hidden';

  @override
  String get businessReputationEventTypeComplaintCreated => 'Complaint created';

  @override
  String get businessReputationEventTypeComplaintStatusChanged =>
      'Complaint status changed';

  @override
  String get businessReputationEventTypeDisputeOpened => 'Dispute opened';

  @override
  String get businessReputationEventTypeDisputeStatusChanged =>
      'Dispute status changed';

  @override
  String get businessReputationEventsEmptyBody => 'No events.';

  @override
  String businessReputationEventCardLine(
    String type,
    String source,
    String sourceId,
  ) {
    return '$type · $source · $sourceId';
  }

  @override
  String businessReputationEventTargetLine(String targetType, String targetId) {
    return 'Target: $targetType · $targetId';
  }

  @override
  String businessReputationEventStatusLine(String from, String to) {
    return '$from → $to';
  }

  @override
  String businessReputationEventTimestampsLine(
    String occurred,
    String recorded,
  ) {
    return '$occurred · $recorded';
  }

  @override
  String businessReputationEventProvenanceLine(String correlation) {
    return 'Correlation: $correlation';
  }

  @override
  String get businessReputationEventSyntheticBadge => 'Synthetic demo signal.';

  @override
  String get notificationInboxTitle => 'Уведомления';

  @override
  String get notificationInboxDemoDisclaimer =>
      'Только демо-уведомления — данные в памяти; реальные push, SMS и email не отправляются.';

  @override
  String notificationInboxUnreadCount(int count) {
    return 'Непрочитано: $count';
  }

  @override
  String get notificationInboxOpenTooltip => 'Открыть уведомления';

  @override
  String get notificationFilterAll => 'Все';

  @override
  String get notificationFilterUnread => 'Непрочитанные';

  @override
  String get notificationCategoryFilter => 'Категория';

  @override
  String get notificationCategoryAll => 'Все категории';

  @override
  String get notificationClearFilters => 'Сбросить фильтры';

  @override
  String get notificationCategoryOrders => 'Заказы';

  @override
  String get notificationCategoryBookings => 'Бронирования';

  @override
  String get notificationCategoryDelivery => 'Доставка';

  @override
  String get notificationCategoryWalletPayments => 'Кошелёк и платежи';

  @override
  String get notificationCategoryAiAlerts => 'AI-оповещения';

  @override
  String get notificationCategoryLocation => 'Локация';

  @override
  String get notificationCategoryBusiness => 'Бизнес';

  @override
  String get notificationCategoryTrustReviews => 'Доверие и отзывы';

  @override
  String get notificationCategorySecurity => 'Безопасность';

  @override
  String get notificationCategoryPromotions => 'Акции';

  @override
  String get notificationChannelInApp => 'В приложении';

  @override
  String get notificationChannelPushPreview => 'Push (превью)';

  @override
  String get notificationChannelSmsPreview => 'SMS (превью)';

  @override
  String get notificationChannelEmailPreview => 'Email (превью)';

  @override
  String get notificationPriorityLow => 'Низкий';

  @override
  String get notificationPriorityNormal => 'Обычный';

  @override
  String get notificationPriorityHigh => 'Высокий';

  @override
  String get notificationPriorityUrgent => 'Срочный';

  @override
  String get notificationInboxEmptyBody =>
      'Нет уведомлений по выбранным фильтрам.';

  @override
  String get notificationMarkReadAction => 'Отметить прочитанным';

  @override
  String get notificationMarkAllReadAction => 'Прочитать все';

  @override
  String get notificationMarkReadSuccess => 'Уведомление отмечено прочитанным.';

  @override
  String get notificationMarkReadAlready => 'Уведомление уже прочитано.';

  @override
  String get notificationMarkReadNotFound => 'Уведомление не найдено.';

  @override
  String get notificationMarkReadInvalid =>
      'Недопустимый идентификатор уведомления.';

  @override
  String get notificationMarkReadFailure =>
      'Не удалось отметить уведомление прочитанным.';

  @override
  String get notificationMarkAllReadSuccess =>
      'Все уведомления отмечены прочитанными.';

  @override
  String get notificationMarkAllReadFailure =>
      'Не удалось отметить все уведомления прочитанными.';

  @override
  String get notificationStatusUnread => 'Непрочитано';

  @override
  String get notificationStatusRead => 'Прочитано';

  @override
  String notificationCardMetaLine(
    String category,
    String timestamp,
    String status,
  ) {
    return '$category · $timestamp · $status';
  }

  @override
  String get notificationSyntheticBadge =>
      'Синтетическое демо-уведомление — не реальное сообщение.';

  @override
  String get notificationOpenLinkedRouteAction =>
      'Нажмите, чтобы открыть связанный экран';

  @override
  String get profileNotificationsTitle => 'Уведомления';

  @override
  String profileNotificationsUnreadCount(int count) {
    return 'Непрочитано в демо-ящике: $count';
  }

  @override
  String get notificationPreferencesTitle => 'Настройки уведомлений';

  @override
  String get notificationPreferencesOpenTooltip => 'Настройки уведомлений';

  @override
  String get notificationPreferencesDemoDisclaimer =>
      'Только демо-настройки — данные в памяти; реальные push, SMS и email не отправляются.';

  @override
  String get notificationPreferencesInMemoryNote =>
      'Изменения действуют только в этой сессии и не синхронизируются с сервером.';

  @override
  String get notificationPreferencesCategoriesSection => 'Категории';

  @override
  String get notificationPreferencesChannelsSection => 'Каналы';

  @override
  String get notificationChannelPreviewNote =>
      'Канал-превью — не подключён к реальному провайдеру.';

  @override
  String get notificationPromotionalConsentTitle =>
      'Согласие на маркетинг и акции';

  @override
  String get notificationPromotionalConsentBody =>
      'Для промо-уведомлений нужно отдельное согласие помимо категории «Акции».';

  @override
  String get notificationQuietHoursSection => 'Тихие часы';

  @override
  String get notificationQuietHoursEnabled => 'Включить тихие часы';

  @override
  String get notificationQuietHoursLocalTimeNote =>
      'Для демо используется локальное время устройства.';

  @override
  String get notificationQuietHoursStart => 'Начало тихих часов';

  @override
  String get notificationQuietHoursEnd => 'Конец тихих часов';

  @override
  String get notificationPreferencesRestoreDefaults =>
      'Восстановить демо-настройки';

  @override
  String get notificationPreferenceSaveSuccess => 'Настройки обновлены.';

  @override
  String get notificationPreferenceSaveInvalid =>
      'Не удалось сохранить — недопустимые значения.';

  @override
  String get notificationPreferenceSaveFailure =>
      'Не удалось сохранить настройки. Попробуйте снова.';

  @override
  String get notificationPreferenceRestoreSuccess =>
      'Демо-настройки восстановлены.';

  @override
  String get notificationEligibilityPreviewSection =>
      'Гипотетическая проверка доставки';

  @override
  String get notificationPreferencesPreviewChannel => 'Канал для превью';

  @override
  String get notificationPreferencesPreviewPriority => 'Приоритет для превью';

  @override
  String get notificationEligibilityPreviewTime =>
      'Оценить по локальному времени';

  @override
  String get notificationEligibilityPreviewAction => 'Проверить допустимость';

  @override
  String get notificationEligibilityPreviewEligible =>
      'Допустимо (гипотетически)';

  @override
  String get notificationEligibilityPreviewSuppressed =>
      'Подавлено (гипотетически)';

  @override
  String get notificationEligibilityReasonEligible =>
      'Все настроенные правила разрешают доставку.';

  @override
  String get notificationEligibilityReasonCategoryDisabled =>
      'Категория отключена в настройках.';

  @override
  String get notificationEligibilityReasonChannelDisabled =>
      'Канал отключён в настройках.';

  @override
  String get notificationEligibilityReasonPromoConsentDisabled =>
      'Согласие на маркетинг выключено.';

  @override
  String get notificationEligibilityReasonQuietHours =>
      'Заблокировано тихими часами для некритичных уведомлений.';

  @override
  String get notificationEligibilityReasonInvalid =>
      'Недопустимый сценарий превью.';

  @override
  String get notificationDispatchDiagnosticsTitle => 'Диагностика доставки';

  @override
  String get notificationDispatchDiagnosticsOpenTooltip =>
      'Диагностика доставки';

  @override
  String get notificationDispatchDemoDisclaimer =>
      'Только демо-dispatch — результаты каналов симулированы; реальные Push, SMS и email не отправляются.';

  @override
  String get notificationDispatchScenariosSection =>
      'Синтетические сценарии dispatch';

  @override
  String get notificationDispatchScenarioOrderMidday => 'Заказ (день, in-app)';

  @override
  String get notificationDispatchScenarioOrderQuiet => 'Заказ (тихие часы)';

  @override
  String get notificationDispatchScenarioPromotion =>
      'Акция (проверка согласия)';

  @override
  String get notificationDispatchScenarioSecurityQuiet =>
      'Безопасность (обход тихих часов)';

  @override
  String get notificationDispatchLastResultTitle =>
      'Последний результат dispatch';

  @override
  String get notificationDispatchOutcomeFilter => 'Исход';

  @override
  String get notificationDispatchFilterAll => 'Все';

  @override
  String get notificationDispatchAuditSection => 'Журнал аудита доставки';

  @override
  String get notificationDispatchAuditEmpty =>
      'Записей аудита dispatch пока нет.';

  @override
  String notificationDispatchAuditMetaLine(
    String outcome,
    String category,
    String channel,
    String timestamp,
  ) {
    return '$outcome · $category · $channel · $timestamp';
  }

  @override
  String notificationDispatchInboxLinkLine(String notificationId) {
    return 'In-app уведомление: $notificationId';
  }

  @override
  String get notificationDispatchOutcomeDeliveredInbox =>
      'Доставлено во in-app inbox';

  @override
  String get notificationDispatchOutcomeSimulatedChannel =>
      'Симулированная доставка по каналу';

  @override
  String get notificationDispatchOutcomeSuppressed => 'Подавлено политикой';

  @override
  String get notificationDispatchOutcomeDuplicate => 'Дубликат idempotency';

  @override
  String get notificationDispatchOutcomeValidationFailed => 'Ошибка валидации';

  @override
  String get notificationDispatchOutcomeChannelFailure =>
      'Симулированный сбой канала';

  @override
  String get notificationDispatchOutcomeInboxFailure =>
      'Не удалось сохранить в inbox';

  @override
  String get notificationDispatchOutcomeCoordinatorFailure =>
      'Сбой координатора dispatch';

  @override
  String get notificationDispatchSourceDiagnostics => 'Диагностика';

  @override
  String get notificationDispatchSourceOrderScenario => 'Сценарий заказа';

  @override
  String get notificationDispatchSourcePromotionScenario => 'Сценарий акции';

  @override
  String get notificationDispatchSourceSecurityScenario =>
      'Сценарий безопасности';

  @override
  String get notificationDispatchSourceTemplatePreview =>
      'Предпросмотр шаблона';

  @override
  String get notificationDispatchTemplatesSection =>
      'Отправка по шаблону (демо)';

  @override
  String get notificationDispatchTemplateSimulateAction =>
      'Симулировать отправку с отрендеренным шаблоном';

  @override
  String get notificationDispatchTemplateRenderFailed =>
      'Ошибка рендера шаблона — отправка не выполнялась.';

  @override
  String get notificationTemplatesTitle => 'Шаблоны уведомлений';

  @override
  String get notificationTemplatesDemoDisclaimer =>
      'Только демо-шаблоны — предпросмотры синтетические; реальные сообщения не отправляются.';

  @override
  String get notificationTemplatesFiltersSection => 'Фильтры';

  @override
  String get notificationTemplatesClearFilters => 'Сбросить фильтры';

  @override
  String get notificationTemplatesLocaleSection => 'Локаль предпросмотра';

  @override
  String notificationTemplatesLocaleFallbackLine(
    String requested,
    String resolved,
  ) {
    return 'Запрошено $requested — используется запасная $resolved.';
  }

  @override
  String notificationTemplatesLocaleExactLine(String locale) {
    return 'Локаль $locale (без запасной).';
  }

  @override
  String get notificationTemplatesCatalogSection =>
      'Синтетический каталог шаблонов';

  @override
  String get notificationTemplatesEmpty => 'Нет шаблонов по текущим фильтрам.';

  @override
  String get notificationTemplatesPreviewSection => 'Рендер (демо-переменные)';

  @override
  String notificationTemplatesMetaLine(
    String category,
    String channel,
    String status,
    String locale,
  ) {
    return '$category · $channel · $status · $locale';
  }

  @override
  String get notificationTemplateStatusFilter => 'Статус шаблона';

  @override
  String get notificationTemplateStatusDraft => 'Черновик';

  @override
  String get notificationTemplateStatusActive => 'Активный';

  @override
  String get notificationTemplateStatusArchived => 'Архив';

  @override
  String get notificationTemplateLocaleEnglish => 'Английский';

  @override
  String get notificationTemplateLocaleRussian => 'Русский';

  @override
  String get notificationTemplateLocaleUzbek => 'Узбекский';

  @override
  String get notificationTemplateErrorInactive =>
      'Шаблон не активен — предпросмотр и отправка заблокированы.';

  @override
  String notificationTemplateErrorMissingVariables(String names) {
    return 'Не хватает обязательных переменных: $names.';
  }

  @override
  String get notificationTemplateErrorUndeclaredPlaceholder =>
      'В шаблоне есть необъявленные плейсхолдеры.';

  @override
  String get notificationTemplateErrorMalformedPlaceholder =>
      'Некорректный синтаксис плейсхолдера.';

  @override
  String get notificationTemplateErrorSensitiveValue =>
      'Значение похоже на чувствительные данные и отклонено.';

  @override
  String get notificationTemplateErrorUnresolvedPlaceholder =>
      'В тексте остались неразрешённые плейсхолдеры.';

  @override
  String get notificationTemplateErrorIncompatibleChannel =>
      'Сочетание категории и канала недопустимо.';

  @override
  String get notificationTemplateErrorGeneric =>
      'Не удалось отрендерить шаблон.';

  @override
  String get businessCenterNotificationTemplatesTitle => 'Шаблоны уведомлений';

  @override
  String get businessCenterNotificationTemplatesBody =>
      'Предпросмотр локализованных синтетических шаблонов (демо).';

  @override
  String get systemMessagesFeedTitle => 'Системные сообщения';

  @override
  String get systemMessagesDemoDisclaimer =>
      'Только демо — синтетические объявления; не официальные и не живые сервисные уведомления.';

  @override
  String get systemMessagesOpenTooltip => 'Открыть системные сообщения';

  @override
  String get systemMessagesFeedEmpty =>
      'Сейчас нет видимых опубликованных объявлений.';

  @override
  String systemMessageUnreadCount(int count) {
    return 'Непрочитано: $count';
  }

  @override
  String get systemMessageCategoryFilter => 'Категория сообщения';

  @override
  String get systemMessageCategoryGeneral => 'Общее объявление';

  @override
  String get systemMessageCategoryMaintenance => 'Техобслуживание';

  @override
  String get systemMessageCategoryServiceUpdate => 'Обновление сервиса';

  @override
  String get systemMessageCategoryPolicy => 'Политика';

  @override
  String get systemMessageLifecycleDraft => 'Черновик';

  @override
  String get systemMessageLifecyclePublished => 'Опубликовано';

  @override
  String get systemMessageLifecycleWithdrawn => 'Отозвано';

  @override
  String get systemMessageLifecycleArchived => 'Архив';

  @override
  String get systemMessageMarkReadAction => 'Отметить прочитанным';

  @override
  String get systemMessageMarkAllReadAction => 'Отметить все прочитанными';

  @override
  String get systemMessageMarkReadSuccess => 'Сообщение отмечено прочитанным.';

  @override
  String get systemMessageMarkReadAlready => 'Сообщение уже было прочитано.';

  @override
  String get systemMessageMarkAllReadSuccess =>
      'Все видимые сообщения отмечены прочитанными.';

  @override
  String get systemMessageOpenAction => 'Открыть связанный экран';

  @override
  String get systemMessageSimulateNotificationAction =>
      'Симулировать in-app уведомление (демо)';

  @override
  String systemMessageMetaLine(String category, String publishedAt) {
    return '$category · $publishedAt';
  }

  @override
  String get systemMessageContentUnavailable =>
      'Локализованный контент недоступен.';

  @override
  String get systemMessagesDemoLifecycleTitle => 'Жизненный цикл (демо)';

  @override
  String get systemMessagesDemoLifecycleTooltip =>
      'Демо-управление жизненным циклом';

  @override
  String get systemMessagesDemoLifecycleDisclaimer =>
      'Только демо publish/withdraw/archive — в памяти, без сохранения.';

  @override
  String get systemMessagePublishAction => 'Опубликовать';

  @override
  String get systemMessageWithdrawAction => 'Отозвать';

  @override
  String get systemMessageArchiveAction => 'Архивировать';

  @override
  String get systemMessageMutationSuccess => 'OK';

  @override
  String get systemMessageMutationInvalidTransition =>
      'Переход жизненного цикла недопустим.';

  @override
  String get systemMessageMutationValidationFailed =>
      'Ошибка валидации — изменения не сохранены.';

  @override
  String get systemMessageMutationNotFound => 'Сообщение не найдено.';

  @override
  String get demoConversationsListTitle => 'Сообщения';

  @override
  String get demoConversationsDisclaimer =>
      'Только демо — сообщения в памяти; реального общения с клиентами или поддержкой нет.';

  @override
  String get demoConversationsEmpty => 'Нет демо-диалогов для этого участника.';

  @override
  String get demoConversationDetailTitle => 'Диалог';

  @override
  String get demoConversationNotFound => 'Диалог не найден или недоступен.';

  @override
  String demoConversationListMetaLine(String state, String preview) {
    return '$state · $preview';
  }

  @override
  String get demoConversationTypeCustomerBusiness => 'Клиент ↔ бизнес (демо)';

  @override
  String get demoConversationTypeSupportDemo => 'Демо поддержки';

  @override
  String get demoConversationStateOpen => 'Открыт';

  @override
  String get demoConversationStateClosed => 'Закрыт';

  @override
  String get demoConversationStateArchived => 'Архив';

  @override
  String get demoConversationRoleCustomer => 'Демо-клиент';

  @override
  String get demoConversationRoleBusinessAgent => 'Демо-агент бизнеса';

  @override
  String get demoConversationRoleSupportAgent => 'Демо-поддержка';

  @override
  String get demoConversationComposerHint => 'Текстовое сообщение';

  @override
  String get demoConversationComposerDisabledClosed =>
      'Диалог закрыт или в архиве — отправка отключена.';

  @override
  String get demoConversationSendAction => 'Отправить';

  @override
  String get demoConversationSendValidationError =>
      'Введите корректное текстовое сообщение.';

  @override
  String get demoConversationSendNotOpen =>
      'Нельзя отправить, пока диалог не открыт.';

  @override
  String get demoConversationSendUnsafeContent =>
      'Содержимое отклонено по соображениям безопасности.';

  @override
  String get demoConversationSendFailure => 'Сообщение не отправлено.';

  @override
  String get profileDemoConversationsTitle => 'Демо-сообщения';

  @override
  String get profileDemoConversationsSubtitle =>
      'Диалоги в памяти (граница чата)';

  @override
  String get platformAdminRolesTitle => 'Роли платформенного админа';

  @override
  String get platformAdminGovernanceDisclaimer =>
      'Только демо управления — роли и права в памяти; производственная авторизация не применяется.';

  @override
  String get platformAdminHighRiskBoundaryNotice =>
      'Права на финансы, кошелёк, секреты и неограниченный доступ к личным данным намеренно отсутствуют в этом демо-каталоге.';

  @override
  String get platformAdminIdentitiesSectionTitle => 'Демо-идентичности админов';

  @override
  String get platformAdminIdentitiesEmpty => 'Демо-админы не загружены.';

  @override
  String get platformAdminRolesSectionTitle => 'Роли и права';

  @override
  String get platformAdminRolesEmpty => 'Роли платформы не определены.';

  @override
  String get platformAdminRoleDetailTitle => 'Права роли';

  @override
  String get platformAdminPermissionCountLabel => 'прав';

  @override
  String get platformAdminAuthPreviewTitle =>
      'Предпросмотр авторизации (только чтение)';

  @override
  String get platformAdminAuthPreviewHint =>
      'Только демо-политика — действия не выполняются и аудит не сохраняется.';

  @override
  String get platformAdminAuthPreviewPermissionLabel => 'Требуемое право';

  @override
  String get platformAdminAuthPreviewScopeKindLabel => 'Область ресурса';

  @override
  String get platformAdminAuthPreviewBusinessRefLabel => 'Ссылка на бизнес';

  @override
  String get platformAdminAuthPreviewBranchRefLabel => 'Ссылка на филиал';

  @override
  String get platformAdminAuthPreviewActionLabel => 'Метка действия';

  @override
  String get platformAdminAuthPreviewSelectAdmin =>
      'Выберите админа для предпросмотра.';

  @override
  String get platformAdminAuthPreviewError => 'Не удалось оценить авторизацию.';

  @override
  String get platformAdminAuthDecisionAllowed => 'Разрешено (демо-политика)';

  @override
  String get platformAdminAuthDecisionDenied => 'Отказано (демо-политика)';

  @override
  String platformAdminAuthMatchedRole(String roleId) {
    return 'Совпавшая роль: $roleId';
  }

  @override
  String get platformAdminSuspendedNotice =>
      'Приостановленные админы отклоняются независимо от ролей.';

  @override
  String get platformAdminStatusActive => 'Активен';

  @override
  String get platformAdminStatusSuspended => 'Приостановлен';

  @override
  String get platformRoleStatusEnabled => 'Включена';

  @override
  String get platformRoleStatusDisabled => 'Отключена';

  @override
  String get platformScopeKindPlatform => 'Вся платформа';

  @override
  String get platformScopeKindBusiness => 'Назначенный бизнес';

  @override
  String get platformScopeKindBranch => 'Назначенный филиал';

  @override
  String get profilePlatformAdminGovernanceTitle => 'Демо админ платформы';

  @override
  String get profilePlatformAdminGovernanceSubtitle =>
      'Роли, права и предпросмотр политики (в памяти)';

  @override
  String get platformRoleViewerName => 'Наблюдатель платформы';

  @override
  String get platformRoleViewerPurpose =>
      'Только чтение демо-панели и записей аудита.';

  @override
  String get platformRoleVerificationReviewerName =>
      'Ревьюер верификации бизнеса';

  @override
  String get platformRoleVerificationReviewerPurpose =>
      'Проверка синтетических заявок в назначенной области.';

  @override
  String get platformRoleModeratorName => 'Модератор контента';

  @override
  String get platformRoleModeratorPurpose =>
      'Очереди модерации и разрешённые демо-действия.';

  @override
  String get platformRoleSupportAgentName => 'Агент поддержки';

  @override
  String get platformRoleSupportAgentPurpose =>
      'Демо-кейсы поддержки в назначенном бизнесе или филиале.';

  @override
  String get platformRoleOperationsAdminName => 'Админ операций платформы';

  @override
  String get platformRoleOperationsAdminPurpose =>
      'Просмотр конфигурации и низкорисковые демо-настройки.';

  @override
  String get platformRoleDisabledAuditName => 'Отключённая роль аудита (демо)';

  @override
  String get platformRoleDisabledAuditPurpose =>
      'Роль отключена для проверки отказа.';

  @override
  String get platformPermissionViewDashboard => 'Просмотр панели админа';

  @override
  String get platformPermissionViewVerificationQueue =>
      'Очередь верификации бизнеса';

  @override
  String get platformPermissionReviewVerification => 'Ревью заявок верификации';

  @override
  String get platformPermissionViewModerationQueue => 'Очередь модерации';

  @override
  String get platformPermissionPerformModeration =>
      'Разрешённые действия модерации';

  @override
  String get platformPermissionViewSupportCases => 'Просмотр кейсов поддержки';

  @override
  String get platformPermissionRespondSupportCases => 'Ответы в поддержке';

  @override
  String get platformPermissionViewConfiguration => 'Просмотр конфигурации';

  @override
  String get platformPermissionManageLowRiskConfiguration =>
      'Низкорисковая конфигурация';

  @override
  String get platformPermissionViewAuditRecords => 'Просмотр записей аудита';

  @override
  String get platformAuthReasonAllowedExplicitGrant =>
      'Разрешено явным правом на включённой роли.';

  @override
  String get platformAuthReasonDeniedInvalidInput =>
      'Отказ — неверные входные данные.';

  @override
  String get platformAuthReasonDeniedAdminSuspended =>
      'Отказ — админ приостановлен.';

  @override
  String get platformAuthReasonDeniedAdminNotFound =>
      'Отказ — админ не найден.';

  @override
  String get platformAuthReasonDeniedNoEnabledRoles =>
      'Отказ — нет включённых ролей.';

  @override
  String get platformAuthReasonDeniedRoleDisabled => 'Отказ — роль отключена.';

  @override
  String get platformAuthReasonDeniedPermissionNotGranted =>
      'Отказ — право не назначено.';

  @override
  String get platformAuthReasonDeniedScopePlatformWideRequired =>
      'Отказ — нужна область всей платформы.';

  @override
  String get platformAuthReasonDeniedScopeBusinessReferenceRequired =>
      'Отказ — нужна ссылка на бизнес.';

  @override
  String get platformAuthReasonDeniedScopeBranchReferenceRequired =>
      'Отказ — нужна ссылка на филиал.';

  @override
  String get platformAuthReasonDeniedCrossBusinessAccess =>
      'Отказ — доступ к другому бизнесу запрещён.';

  @override
  String get platformAuthReasonDeniedCrossBranchAccess =>
      'Отказ — доступ к другому филиалу запрещён.';

  @override
  String get platformAuthReasonDeniedBusinessAssignmentRequired =>
      'Отказ — нужны назначения бизнеса.';

  @override
  String get platformAuthReasonDeniedBranchAssignmentRequired =>
      'Отказ — нужны назначения филиала.';

  @override
  String get platformGovernanceWorkflowDisclaimer =>
      'Только демо — реальная верификация, модерация и поддержка не выполняются.';

  @override
  String get platformBusinessVerificationTitle => 'Очередь верификации бизнеса';

  @override
  String get platformModerationTitle => 'Очередь модерации';

  @override
  String get platformSupportCasesTitle => 'Кейсы поддержки';

  @override
  String get platformWorkflowActiveAdminLabel => 'Демо-админ';

  @override
  String get platformWorkflowHistoryTitle => 'История';

  @override
  String get platformWorkflowOutcomeSuccess =>
      'Демо-действие сохранено в памяти.';

  @override
  String get platformWorkflowOutcomeAuthorizationDenied =>
      'Отказано демо-политикой авторизации.';

  @override
  String get platformWorkflowOutcomeInvalidTransition =>
      'Недопустимый переход статуса.';

  @override
  String get platformWorkflowOutcomeInvalidInput => 'Неверные данные.';

  @override
  String get platformWorkflowOutcomeNotFound => 'Запись не найдена.';

  @override
  String get platformWorkflowOutcomeFailure =>
      'Ошибка репозитория — без изменений.';

  @override
  String get platformAdminNavBusinessVerification => 'Верификация бизнеса';

  @override
  String get platformAdminNavModeration => 'Модерация';

  @override
  String get platformAdminNavSupportCases => 'Поддержка';

  @override
  String get platformBverStatusPending => 'Ожидает';

  @override
  String get platformBverStatusUnderReview => 'На проверке';

  @override
  String get platformBverStatusApproved => 'Одобрено (демо)';

  @override
  String get platformBverStatusRejected => 'Отклонено (демо)';

  @override
  String get platformBverStatusNeedsInfo => 'Нужна информация';

  @override
  String get platformBverActionBeginReview => 'Начать проверку';

  @override
  String get platformBverActionApprove => 'Одобрить (демо)';

  @override
  String get platformBverActionReject => 'Отклонить (демо)';

  @override
  String get platformModStatusPending => 'Ожидает';

  @override
  String get platformModStatusUnderReview => 'На проверке';

  @override
  String get platformModStatusActionProposed => 'Действие предложено';

  @override
  String get platformModStatusResolved => 'Решено (демо)';

  @override
  String get platformModStatusDismissed => 'Отклонено (демо)';

  @override
  String get platformModActionBeginReview => 'Начать проверку';

  @override
  String get platformSupportStatusOpen => 'Открыт';

  @override
  String get platformSupportStatusAssigned => 'Назначен';

  @override
  String get platformSupportStatusInProgress => 'В работе';

  @override
  String get platformSupportStatusResolved => 'Решён';

  @override
  String get platformSupportStatusClosed => 'Закрыт';

  @override
  String get platformSupportNoteHint => 'Внутренняя заметка';

  @override
  String get platformSupportAddNoteAction => 'Добавить заметку (демо)';

  @override
  String get platformSupportAssignAction => 'Назначить роль (демо)';

  @override
  String get platformGovernancePhase15Disclaimer =>
      'Только демо управления платформой — конфигурация, аудит и согласования в памяти; производственные действия не выполняются.';

  @override
  String get platformGovernanceAuditTitle => 'Журнал аудита платформы';

  @override
  String get platformGovernanceConfigurationTitle => 'Конфигурация платформы';

  @override
  String get platformGovernanceApprovalsTitle => 'Запросы на согласование';

  @override
  String get platformGovernanceOperationsTitle => 'Операционная панель';

  @override
  String get platformGovernanceAuditEmpty =>
      'Нет событий аудита по текущим фильтрам.';

  @override
  String get platformGovernanceAccessDenied =>
      'Доступ запрещён демо-политикой авторизации.';

  @override
  String get platformGovernanceSeedBadge => 'Seed';

  @override
  String get platformConfigRestrictedNotice =>
      'Ограничено — нужно согласование; в этом демо не редактируется.';

  @override
  String platformConfigRevisionLabel(int revision) {
    return 'Ревизия $revision';
  }

  @override
  String get platformGovernanceApprovalNoExecutionNotice =>
      'Согласование меняет только демо-запрос. Кошелёк, платежи и безопасность не выполняются.';

  @override
  String get platformGovernanceApprovalCreateAction =>
      'Создать демо-предложение';

  @override
  String get platformGovernanceApprovalApproveAction =>
      'Одобрить (только демо)';

  @override
  String get platformGovernanceApprovalRejectAction =>
      'Отклонить (только демо)';

  @override
  String get platformGovernanceOperationsSyntheticNotice =>
      'Счётчики из демо-репозиториев в памяти — не KPI продакшена.';

  @override
  String get platformGovernanceOperationsRefresh => 'Обновить сводку';

  @override
  String get platformGovernanceOperationsEmpty => 'Сводка недоступна.';

  @override
  String get platformGovernanceOperationsAsOf => 'На момент (UTC)';

  @override
  String get platformGovernanceOperationsPendingApprovals =>
      'Ожидающие согласования';

  @override
  String get platformGovernanceOperationsConfigRevisions =>
      'Записи ревизий конфигурации';

  @override
  String get platformGovernanceOperationsVerificationSection =>
      'Заявки верификации';

  @override
  String get platformGovernanceOperationsModerationSection => 'Кейсы модерации';

  @override
  String get platformAdminNavAudit => 'Журнал аудита';

  @override
  String get platformAdminNavConfiguration => 'Конфигурация платформы';

  @override
  String get platformAdminNavApprovals => 'Согласования';

  @override
  String get platformAdminNavOperations => 'Операционная панель';

  @override
  String get platformPermissionSubmitApprovalProposal =>
      'Создать предложение высокого риска (демо)';

  @override
  String get platformPermissionDecideApprovalProposal =>
      'Решить по предложению высокого риска (демo)';

  @override
  String get platformRoleGovernanceApproverName => 'Согласующий governance';

  @override
  String get platformRoleGovernanceApproverPurpose =>
      'Второе лицо для гипотетических предложений — без других привилегий.';

  @override
  String get platformWorkflowOutcomeAuditPersistFailure =>
      'Изменение могло сохраниться, но запись аудита не удалась (ограничение демо в памяти).';
}
