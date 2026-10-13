/// Stable catalog item identifiers for routing and lookup (not localized).
enum MockCatalogItemId {
  barakaFreshBread('baraka-fresh-bread'),
  barakaDailyBasket('baraka-daily-basket'),
  samarkandPlov('samarkand-plov'),
  samarkandGreenTea('samarkand-green-tea'),
  shifoVitaminC('shifo-vitamin-c'),
  shifoFirstAidKit('shifo-first-aid-kit'),
  techUsbHub('tech-usb-hub'),
  techPhoneCase('tech-phone-case'),
  styleCottonTee('style-cotton-tee'),
  pipeLeakVisit('pipe-leak-visit'),
  pipeTapInstall('pipe-tap-install'),
  electricSocketCheck('electric-socket-check'),
  rentStudioNight('rent-studio-night'),
  rentSedanDay('rent-sedan-day');

  const MockCatalogItemId(this.routeParam);

  final String routeParam;
}

MockCatalogItemId? tryParseMockCatalogItemId(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  for (final id in MockCatalogItemId.values) {
    if (id.routeParam == raw) {
      return id;
    }
  }
  return null;
}
