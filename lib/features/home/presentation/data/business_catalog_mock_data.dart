import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

enum CatalogItemKind { product, service }

class BusinessCatalogItem {
  const BusinessCatalogItem({
    required this.id,
    required this.businessId,
    required this.kind,
    required this.name,
    required this.description,
    required this.icon,
    this.samplePriceUzs,
  });

  final MockCatalogItemId id;
  final MockBusinessId businessId;
  final CatalogItemKind kind;
  final String name;
  final String description;
  final IconData icon;
  final int? samplePriceUzs;
}

List<BusinessCatalogItem> buildAllCatalogItems(AppLocalizations l10n) {
  return [
    BusinessCatalogItem(
      id: MockCatalogItemId.barakaFreshBread,
      businessId: MockBusinessId.barakaMarket,
      kind: CatalogItemKind.product,
      name: l10n.catalogBarakaFreshBreadName,
      description: l10n.catalogBarakaFreshBreadDesc,
      icon: Icons.bakery_dining_outlined,
      samplePriceUzs: 8000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.barakaDailyBasket,
      businessId: MockBusinessId.barakaMarket,
      kind: CatalogItemKind.product,
      name: l10n.catalogBarakaDailyBasketName,
      description: l10n.catalogBarakaDailyBasketDesc,
      icon: Icons.shopping_basket_outlined,
      samplePriceUzs: 45000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.samarkandPlov,
      businessId: MockBusinessId.samarkandCafe,
      kind: CatalogItemKind.product,
      name: l10n.catalogSamarkandPlovName,
      description: l10n.catalogSamarkandPlovDesc,
      icon: Icons.ramen_dining_outlined,
      samplePriceUzs: 38000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.samarkandGreenTea,
      businessId: MockBusinessId.samarkandCafe,
      kind: CatalogItemKind.product,
      name: l10n.catalogSamarkandGreenTeaName,
      description: l10n.catalogSamarkandGreenTeaDesc,
      icon: Icons.emoji_food_beverage_outlined,
      samplePriceUzs: 12000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.shifoVitaminC,
      businessId: MockBusinessId.shifoPlus,
      kind: CatalogItemKind.product,
      name: l10n.catalogShifoVitaminCName,
      description: l10n.catalogShifoVitaminCDesc,
      icon: Icons.medication_outlined,
      samplePriceUzs: 65000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.shifoFirstAidKit,
      businessId: MockBusinessId.shifoPlus,
      kind: CatalogItemKind.product,
      name: l10n.catalogShifoFirstAidKitName,
      description: l10n.catalogShifoFirstAidKitDesc,
      icon: Icons.medical_services_outlined,
      samplePriceUzs: 89000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.techUsbHub,
      businessId: MockBusinessId.sampleTechCorner,
      kind: CatalogItemKind.product,
      name: l10n.catalogTechUsbHubName,
      description: l10n.catalogTechUsbHubDesc,
      icon: Icons.usb_outlined,
      samplePriceUzs: 120000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.techPhoneCase,
      businessId: MockBusinessId.sampleTechCorner,
      kind: CatalogItemKind.product,
      name: l10n.catalogTechPhoneCaseName,
      description: l10n.catalogTechPhoneCaseDesc,
      icon: Icons.smartphone_outlined,
      samplePriceUzs: 75000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.styleCottonTee,
      businessId: MockBusinessId.sampleStyleShop,
      kind: CatalogItemKind.product,
      name: l10n.catalogStyleCottonTeeName,
      description: l10n.catalogStyleCottonTeeDesc,
      icon: Icons.checkroom_outlined,
      samplePriceUzs: 99000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.pipeLeakVisit,
      businessId: MockBusinessId.samplePipeFix,
      kind: CatalogItemKind.service,
      name: l10n.catalogPipeLeakVisitName,
      description: l10n.catalogPipeLeakVisitDesc,
      icon: Icons.plumbing_outlined,
      samplePriceUzs: 150000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.pipeTapInstall,
      businessId: MockBusinessId.samplePipeFix,
      kind: CatalogItemKind.service,
      name: l10n.catalogPipeTapInstallName,
      description: l10n.catalogPipeTapInstallDesc,
      icon: Icons.water_drop_outlined,
      samplePriceUzs: 95000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.electricSocketCheck,
      businessId: MockBusinessId.sampleElectricHelp,
      kind: CatalogItemKind.service,
      name: l10n.catalogElectricSocketCheckName,
      description: l10n.catalogElectricSocketCheckDesc,
      icon: Icons.electrical_services_outlined,
      samplePriceUzs: 80000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.rentStudioNight,
      businessId: MockBusinessId.sampleApartmentHub,
      kind: CatalogItemKind.service,
      name: l10n.catalogRentStudioNightName,
      description: l10n.catalogRentStudioNightDesc,
      icon: Icons.apartment_outlined,
      samplePriceUzs: 320000,
    ),
    BusinessCatalogItem(
      id: MockCatalogItemId.rentSedanDay,
      businessId: MockBusinessId.sampleCarRent,
      kind: CatalogItemKind.service,
      name: l10n.catalogRentSedanDayName,
      description: l10n.catalogRentSedanDayDesc,
      icon: Icons.directions_car_outlined,
      samplePriceUzs: 450000,
    ),
  ];
}

List<BusinessCatalogItem> catalogItemsForBusiness(
  AppLocalizations l10n,
  MockBusinessId businessId,
) {
  return buildAllCatalogItems(l10n)
      .where((item) => item.businessId == businessId)
      .toList(growable: false);
}

BusinessCatalogItem? findCatalogItemForBusiness({
  required AppLocalizations l10n,
  required MockBusinessId businessId,
  required MockCatalogItemId catalogItemId,
}) {
  for (final item in buildAllCatalogItems(l10n)) {
    if (item.id == catalogItemId && item.businessId == businessId) {
      return item;
    }
  }
  return null;
}

String catalogItemKindLabel(CatalogItemKind kind, AppLocalizations l10n) {
  return switch (kind) {
    CatalogItemKind.product => l10n.catalogItemTypeProduct,
    CatalogItemKind.service => l10n.catalogItemTypeService,
  };
}

String formatCatalogSamplePrice(int priceUzs, AppLocalizations l10n) {
  return l10n.catalogSamplePriceDemo(priceUzs);
}
