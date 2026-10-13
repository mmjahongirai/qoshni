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
}
