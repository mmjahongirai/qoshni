import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/data/business_profile_sample_data.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_pricing_unit.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';

const String kSampleOfferingPerforatorId = 'sample-offering-perforator';

List<BusinessProfileOffering> buildSampleOfferingsForProfile(
  AppLocalizations l10n,
  String businessProfileId,
  AppConfig config,
) {
  if (!config.enableBusinessOfferingSamples ||
      !config.enableBusinessProfileSamples ||
      businessProfileId != kSampleRentalToolsProfileId) {
    return const [];
  }

  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  return [
    BusinessProfileOffering(
      id: kSampleOfferingPerforatorId,
      businessProfileId: kSampleRentalToolsProfileId,
      kind: BusinessOfferingKind.rental,
      name: l10n.businessSampleOfferingPerforatorName,
      description: l10n.businessSampleOfferingPerforatorDesc,
      pricingUnit: BusinessPricingUnit.perDay,
      samplePriceUzs: 85000,
      demoDepositUzs: 200000,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
