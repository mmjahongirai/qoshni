import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

enum CatalogPriceResolutionStatus {
  found,
  notFound,
  ambiguous,
}

class CatalogPriceResolution {
  const CatalogPriceResolution._({
    required this.status,
    this.price,
    this.candidatePriceIds = const [],
  });

  const CatalogPriceResolution.found(BusinessCatalogPrice price)
      : this._(
          status: CatalogPriceResolutionStatus.found,
          price: price,
        );

  const CatalogPriceResolution.notFound()
      : this._(status: CatalogPriceResolutionStatus.notFound);

  const CatalogPriceResolution.ambiguous(List<String> candidatePriceIds)
      : this._(
          status: CatalogPriceResolutionStatus.ambiguous,
          candidatePriceIds: candidatePriceIds,
        );

  final CatalogPriceResolutionStatus status;
  final BusinessCatalogPrice? price;
  final List<String> candidatePriceIds;
}

CatalogPriceResolution resolveCatalogPrice({
  required Iterable<BusinessCatalogPrice> prices,
  required BusinessCatalogListingKind listingKind,
  required String listingId,
  required String branchId,
  String? variantId,
  required DateTime asOf,
}) {
  final branch = branchId.trim();
  final listing = listingId.trim();
  final variant = variantId?.trim();

  bool matchesTarget(BusinessCatalogPrice p) {
    if (p.status != BusinessCatalogPriceStatus.active) {
      return false;
    }
    if (p.branchId != branch ||
        p.listingKind != listingKind ||
        p.listingId != listing) {
      return false;
    }
    if (!catalogPriceEffectiveAt(
      effectiveFrom: p.effectiveFrom,
      effectiveUntil: p.effectiveUntil,
      asOf: asOf,
    )) {
      return false;
    }
    return true;
  }

  final active = prices.where(matchesTarget).toList();

  if (listingKind == BusinessCatalogListingKind.product &&
      variant != null &&
      variant.isNotEmpty) {
    final variantMatches = active
        .where((p) => p.variantId == variant)
        .toList(growable: false);
    if (variantMatches.length > 1) {
      final ids = variantMatches.map((p) => p.priceId).toList()..sort();
      return CatalogPriceResolution.ambiguous(ids);
    }
    if (variantMatches.length == 1) {
      return CatalogPriceResolution.found(variantMatches.single);
    }

    final baseMatches = active
        .where((p) => p.variantId == null || p.variantId!.trim().isEmpty)
        .toList(growable: false);
    if (baseMatches.length > 1) {
      final ids = baseMatches.map((p) => p.priceId).toList()..sort();
      return CatalogPriceResolution.ambiguous(ids);
    }
    if (baseMatches.length == 1) {
      return CatalogPriceResolution.found(baseMatches.single);
    }
    return const CatalogPriceResolution.notFound();
  }

  final baseMatches = active
      .where((p) => p.variantId == null || p.variantId!.trim().isEmpty)
      .toList(growable: false);
  if (baseMatches.length > 1) {
    final ids = baseMatches.map((p) => p.priceId).toList()..sort();
    return CatalogPriceResolution.ambiguous(ids);
  }
  if (baseMatches.length == 1) {
    return CatalogPriceResolution.found(baseMatches.single);
  }
  return const CatalogPriceResolution.notFound();
}
