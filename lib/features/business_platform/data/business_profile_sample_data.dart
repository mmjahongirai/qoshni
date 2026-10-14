import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_kind.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

/// Stable ID for the rental tools sample (not a [MockBusinessId]).
const String kSampleRentalToolsProfileId = 'sample-rental-tools';

List<BusinessProfileDraft> buildBusinessProfileSamples(
  AppLocalizations l10n,
  AppConfig config,
) {
  if (!config.enableBusinessProfileSamples) {
    return const [];
  }

  final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  return [
    BusinessProfileDraft(
      id: kSampleRentalToolsProfileId,
      kind: BusinessProfileKind.sampleDemo,
      businessName: l10n.businessSampleRentalName,
      categoryId: ServiceCategoryId.rent,
      description: l10n.businessSampleRentalDescription,
      addressDescription: l10n.businessSampleRentalAddress,
      workingHours: l10n.businessSampleRentalHours,
      contactPhone: l10n.businessSampleRentalPhone,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

BusinessProfileDraft? findBusinessProfileSample(
  AppLocalizations l10n,
  String profileId,
  AppConfig config,
) {
  for (final sample in buildBusinessProfileSamples(l10n, config)) {
    if (sample.id == profileId) {
      return sample;
    }
  }
  return null;
}

BusinessProfileFormSeed sampleRentalToolsFormSeed(AppLocalizations l10n) {
  return BusinessProfileFormSeed(
    businessName: l10n.businessSampleRentalName,
    categoryId: ServiceCategoryId.rent,
    description: l10n.businessSampleRentalDescription,
    addressDescription: l10n.businessSampleRentalAddress,
    workingHours: l10n.businessSampleRentalHours,
    contactPhone: l10n.businessSampleRentalPhone,
  );
}
