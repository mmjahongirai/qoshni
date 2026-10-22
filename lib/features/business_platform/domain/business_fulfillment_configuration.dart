import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';

class BusinessFulfillmentConfiguration {
  const BusinessFulfillmentConfiguration({
    required this.configurationId,
    required this.businessScopeId,
    required this.branchId,
    required this.targetScope,
    this.listingId,
    required this.supportedFulfillmentTypes,
    required this.status,
    required this.revision,
    required this.dataSource,
    required this.createdAt,
    required this.updatedAt,
  });

  final String configurationId;
  final String businessScopeId;
  final String branchId;
  final BusinessFulfillmentTargetScope targetScope;
  final String? listingId;
  final List<BusinessFulfillmentType> supportedFulfillmentTypes;
  final BusinessCatalogPriceStatus status;
  final int revision;
  final BusinessCatalogProductDataSource dataSource;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  BusinessFulfillmentConfiguration copyWith({
    String? branchId,
    BusinessFulfillmentTargetScope? targetScope,
    String? listingId,
    bool clearListingId = false,
    List<BusinessFulfillmentType>? supportedFulfillmentTypes,
    BusinessCatalogPriceStatus? status,
    int? revision,
    DateTime? updatedAt,
  }) {
    return BusinessFulfillmentConfiguration(
      configurationId: configurationId,
      businessScopeId: businessScopeId,
      branchId: branchId ?? this.branchId,
      targetScope: targetScope ?? this.targetScope,
      listingId: clearListingId ? null : (listingId ?? this.listingId),
      supportedFulfillmentTypes:
          supportedFulfillmentTypes ?? this.supportedFulfillmentTypes,
      status: status ?? this.status,
      revision: revision ?? this.revision,
      dataSource: dataSource,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessFulfillmentConfigurationInput {
  const BusinessFulfillmentConfigurationInput({
    required this.branchId,
    required this.targetScope,
    this.listingId,
    required this.supportedFulfillmentTypes,
  });

  final String branchId;
  final BusinessFulfillmentTargetScope targetScope;
  final String? listingId;
  final List<BusinessFulfillmentType> supportedFulfillmentTypes;
}
