import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile_status.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

/// Isolated demo seed — not tied to onboarding or public catalog data.
BusinessOwnerProfile buildDemoOwnerProfile({DateTime? now}) {
  final timestamp = now ?? DateTime.now();
  return BusinessOwnerProfile(
    sessionProfileId: 'session-owner-profile-demo',
    dataSource: BusinessOwnerProfileDataSource.demoSeed,
    lifecycleStatus: BusinessOwnerProfileLifecycleStatus.previewDraft,
    legalBusinessName: 'Demo Services LLC',
    displayName: 'Demo Services',
    description:
        'Preview business profile for layout and editing. Not published or verified.',
    categoryId: ServiceCategoryId.masters,
    contactPhone: '+998901112233',
    contactEmail: 'preview@example.invalid',
    websiteUrl: 'https://example.invalid',
    visibility: BusinessOwnerProfileVisibility.hiddenPreview,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
