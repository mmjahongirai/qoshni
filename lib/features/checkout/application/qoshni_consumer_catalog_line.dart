import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/home/presentation/data/business_catalog_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

/// Resolved consumer-catalog row used for demo pricing (not Business Center owner catalog).
class QoshniConsumerCatalogLine {
  const QoshniConsumerCatalogLine({
    required this.catalogItem,
    required this.businessName,
    required this.unitPriceSom,
  });

  final BusinessCatalogItem catalogItem;
  final String businessName;
  final int unitPriceSom;
}

enum QoshniConsumerCatalogResolveStatus {
  found,
  notFound,
  noPrice,
}

class QoshniConsumerCatalogResolveResult {
  const QoshniConsumerCatalogResolveResult.found(this.line)
      : status = QoshniConsumerCatalogResolveStatus.found;

  const QoshniConsumerCatalogResolveResult.notFound()
      : status = QoshniConsumerCatalogResolveStatus.notFound,
        line = null;

  const QoshniConsumerCatalogResolveResult.noPrice()
      : status = QoshniConsumerCatalogResolveStatus.noPrice,
        line = null;

  final QoshniConsumerCatalogResolveStatus status;
  final QoshniConsumerCatalogLine? line;
}

QoshniConsumerCatalogResolveResult resolveConsumerCatalogLine({
  required AppLocalizations l10n,
  required ColorScheme colorScheme,
  required MockBusinessId businessId,
  required MockCatalogItemId catalogItemId,
}) {
  final catalogItem = findCatalogItemForBusiness(
    l10n: l10n,
    businessId: businessId,
    catalogItemId: catalogItemId,
  );
  if (catalogItem == null) {
    return const QoshniConsumerCatalogResolveResult.notFound();
  }
  final price = catalogItem.samplePriceUzs;
  if (price == null || price < 0) {
    return const QoshniConsumerCatalogResolveResult.noPrice();
  }
  final business = findMockBusinessById(l10n, colorScheme, businessId);
  if (business == null) {
    return const QoshniConsumerCatalogResolveResult.notFound();
  }
  return QoshniConsumerCatalogResolveResult.found(
    QoshniConsumerCatalogLine(
      catalogItem: catalogItem,
      businessName: business.name,
      unitPriceSom: price,
    ),
  );
}
