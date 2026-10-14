import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_pricing_unit.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';

class BusinessOfferingUpdateResult {
  const BusinessOfferingUpdateResult({
    required this.success,
    this.previousKind,
    this.updatedKind,
  });

  final bool success;
  final BusinessOfferingKind? previousKind;
  final BusinessOfferingKind? updatedKind;

  bool get kindChanged =>
      success &&
      previousKind != null &&
      updatedKind != null &&
      previousKind != updatedKind;
}

/// Owner-managed offerings for user business profile drafts.
abstract class BusinessOfferingRepository {
  List<BusinessProfileOffering> offeringsForProfile(String businessProfileId);

  BusinessProfileOffering? offeringById({
    required String businessProfileId,
    required String offeringId,
  });

  String? addOffering({
    required String businessProfileId,
    required BusinessOfferingKind kind,
    required String name,
    required String description,
    required BusinessPricingUnit pricingUnit,
    int? samplePriceUzs,
    int? demoDepositUzs,
  });

  BusinessOfferingUpdateResult updateOffering({
    required String businessProfileId,
    required String offeringId,
    required BusinessOfferingKind kind,
    required String name,
    required String description,
    required BusinessPricingUnit pricingUnit,
    int? samplePriceUzs,
    int? demoDepositUzs,
  });

  bool removeOffering({
    required String businessProfileId,
    required String offeringId,
  });
}
