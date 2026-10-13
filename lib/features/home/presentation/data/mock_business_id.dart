/// Stable mock business identifiers for routing and lookup (not localized).
enum MockBusinessId {
  barakaMarket('baraka-market'),
  samarkandCafe('samarkand-cafe'),
  shifoPlus('shifo-plus'),
  sampleTechCorner('sample-tech-corner'),
  sampleStyleShop('sample-style-shop'),
  samplePipeFix('sample-pipe-fix'),
  sampleElectricHelp('sample-electric-help'),
  sampleApartmentHub('sample-apartment-hub'),
  sampleCarRent('sample-car-rent');

  const MockBusinessId(this.routeParam);

  final String routeParam;
}

MockBusinessId? tryParseMockBusinessId(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  for (final id in MockBusinessId.values) {
    if (id.routeParam == raw) {
      return id;
    }
  }
  return null;
}
