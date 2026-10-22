import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';

const String kBusinessCatalogPriceCurrencyUzs = 'UZS';

const Set<String> kBusinessCatalogSupportedPriceCurrencies = {
  kBusinessCatalogPriceCurrencyUzs,
};

class BusinessCatalogPrice {
  const BusinessCatalogPrice({
    required this.priceId,
    required this.businessScopeId,
    required this.branchId,
    required this.listingKind,
    required this.listingId,
    this.variantId,
    required this.amountSom,
    required this.currencyCode,
    required this.status,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.revision,
    required this.dataSource,
    required this.createdAt,
    required this.updatedAt,
  });

  final String priceId;
  final String businessScopeId;
  final String branchId;
  final BusinessCatalogListingKind listingKind;
  final String listingId;
  final String? variantId;
  final int amountSom;
  final String currencyCode;
  final BusinessCatalogPriceStatus status;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final int revision;
  final BusinessCatalogProductDataSource dataSource;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  bool get isVariantSpecific =>
      listingKind == BusinessCatalogListingKind.product &&
      variantId != null &&
      variantId!.trim().isNotEmpty;

  BusinessCatalogPrice copyWith({
    String? branchId,
    BusinessCatalogListingKind? listingKind,
    String? listingId,
    String? variantId,
    bool clearVariantId = false,
    int? amountSom,
    String? currencyCode,
    BusinessCatalogPriceStatus? status,
    DateTime? effectiveFrom,
    DateTime? effectiveUntil,
    bool clearEffectiveUntil = false,
    int? revision,
    DateTime? updatedAt,
  }) {
    return BusinessCatalogPrice(
      priceId: priceId,
      businessScopeId: businessScopeId,
      branchId: branchId ?? this.branchId,
      listingKind: listingKind ?? this.listingKind,
      listingId: listingId ?? this.listingId,
      variantId: clearVariantId ? null : (variantId ?? this.variantId),
      amountSom: amountSom ?? this.amountSom,
      currencyCode: currencyCode ?? this.currencyCode,
      status: status ?? this.status,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveUntil:
          clearEffectiveUntil ? null : (effectiveUntil ?? this.effectiveUntil),
      revision: revision ?? this.revision,
      dataSource: dataSource,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessCatalogPriceInput {
  const BusinessCatalogPriceInput({
    required this.listingKind,
    required this.listingId,
    this.variantId,
    required this.branchId,
    required this.amountSom,
    required this.currencyCode,
    required this.effectiveFrom,
    this.effectiveUntil,
  });

  final BusinessCatalogListingKind listingKind;
  final String listingId;
  final String? variantId;
  final String branchId;
  final int amountSom;
  final String currencyCode;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
}
