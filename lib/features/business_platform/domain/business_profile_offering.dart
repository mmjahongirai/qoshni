import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_pricing_unit.dart';

/// Owner-managed offering (not consumer [BusinessCatalogItem]).
class BusinessProfileOffering {
  BusinessProfileOffering({
    required this.id,
    required this.businessProfileId,
    required this.kind,
    required this.name,
    required this.description,
    required this.pricingUnit,
    this.samplePriceUzs,
    this.demoDepositUzs,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String businessProfileId;
  final BusinessOfferingKind kind;
  final String name;
  final String description;
  final BusinessPricingUnit pricingUnit;
  final int? samplePriceUzs;
  final int? demoDepositUzs;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessProfileOffering copyWith({
    BusinessOfferingKind? kind,
    String? name,
    String? description,
    BusinessPricingUnit? pricingUnit,
    int? samplePriceUzs,
    bool clearSamplePrice = false,
    int? demoDepositUzs,
    bool clearDemoDeposit = false,
    DateTime? updatedAt,
  }) {
    return BusinessProfileOffering(
      id: id,
      businessProfileId: businessProfileId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      description: description ?? this.description,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      samplePriceUzs: clearSamplePrice
          ? null
          : (samplePriceUzs ?? this.samplePriceUzs),
      demoDepositUzs:
          clearDemoDeposit ? null : (demoDepositUzs ?? this.demoDepositUzs),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
