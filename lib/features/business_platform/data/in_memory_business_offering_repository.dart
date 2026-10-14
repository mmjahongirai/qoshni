import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_pricing_unit.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_offering_repository.dart';

class InMemoryBusinessOfferingRepository implements BusinessOfferingRepository {
  final List<BusinessProfileOffering> _offerings = [];

  @override
  List<BusinessProfileOffering> offeringsForProfile(String businessProfileId) {
    return _offerings
        .where((o) => o.businessProfileId == businessProfileId)
        .toList(growable: false);
  }

  @override
  BusinessProfileOffering? offeringById({
    required String businessProfileId,
    required String offeringId,
  }) {
    for (final offering in _offerings) {
      if (offering.id == offeringId &&
          offering.businessProfileId == businessProfileId) {
        return offering;
      }
    }
    return null;
  }

  @override
  String? addOffering({
    required String businessProfileId,
    required BusinessOfferingKind kind,
    required String name,
    required String description,
    required BusinessPricingUnit pricingUnit,
    int? samplePriceUzs,
    int? demoDepositUzs,
  }) {
    final now = DateTime.now();
    final id =
        'offering-${now.toUtc().millisecondsSinceEpoch.toRadixString(36)}';

    _offerings.insert(
      0,
      BusinessProfileOffering(
        id: id,
        businessProfileId: businessProfileId,
        kind: kind,
        name: name.trim(),
        description: description.trim(),
        pricingUnit: pricingUnit,
        samplePriceUzs: samplePriceUzs,
        demoDepositUzs:
            kind == BusinessOfferingKind.rental ? demoDepositUzs : null,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  @override
  BusinessOfferingUpdateResult updateOffering({
    required String businessProfileId,
    required String offeringId,
    required BusinessOfferingKind kind,
    required String name,
    required String description,
    required BusinessPricingUnit pricingUnit,
    int? samplePriceUzs,
    int? demoDepositUzs,
  }) {
    final index = _offerings.indexWhere(
      (o) => o.id == offeringId && o.businessProfileId == businessProfileId,
    );
    if (index < 0) {
      return const BusinessOfferingUpdateResult(success: false);
    }

    final previousKind = _offerings[index].kind;
    _offerings[index] = _offerings[index].copyWith(
      kind: kind,
      name: name.trim(),
      description: description.trim(),
      pricingUnit: pricingUnit,
      samplePriceUzs: samplePriceUzs,
      clearSamplePrice: samplePriceUzs == null,
      demoDepositUzs:
          kind == BusinessOfferingKind.rental ? demoDepositUzs : null,
      clearDemoDeposit:
          kind != BusinessOfferingKind.rental || demoDepositUzs == null,
      updatedAt: DateTime.now(),
    );

    return BusinessOfferingUpdateResult(
      success: true,
      previousKind: previousKind,
      updatedKind: kind,
    );
  }

  @override
  bool removeOffering({
    required String businessProfileId,
    required String offeringId,
  }) {
    final before = _offerings.length;
    _offerings.removeWhere(
      (o) => o.id == offeringId && o.businessProfileId == businessProfileId,
    );
    return _offerings.length < before;
  }
}
