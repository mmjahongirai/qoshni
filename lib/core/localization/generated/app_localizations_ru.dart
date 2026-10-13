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
}
