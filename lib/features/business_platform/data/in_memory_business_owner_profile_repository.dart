import 'package:qoshni/features/business_platform/data/business_owner_profile_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';

class InMemoryBusinessOwnerProfileRepository
    implements BusinessOwnerProfileRepository {
  BusinessOwnerProfile? _profile;

  /// Test-only: next save returns [BusinessOwnerProfileSaveResult.failure].
  bool failNextSave = false;

  @override
  BusinessOwnerProfile? get sessionProfile => _profile;

  @override
  BusinessOwnerProfile ensureSessionProfile() {
    _profile ??= buildDemoOwnerProfile();
    return _profile!;
  }

  @override
  BusinessOwnerProfileSaveResult saveSessionProfile(
    BusinessOwnerProfileInput input,
  ) {
    if (failNextSave) {
      failNextSave = false;
      return BusinessOwnerProfileSaveResult.failure;
    }

    final existing = ensureSessionProfile();
    final now = DateTime.now();
    _profile = existing.copyWith(
      dataSource: BusinessOwnerProfileDataSource.userSession,
      legalBusinessName: input.legalBusinessName.trim(),
      displayName: input.displayName.trim(),
      description: input.description.trim(),
      categoryId: input.categoryId,
      contactPhone: _normalizeOptional(input.contactPhone),
      contactEmail: _normalizeOptional(input.contactEmail),
      websiteUrl: _normalizeOptional(input.websiteUrl),
      visibility: input.visibility,
      clearContactPhone: input.contactPhone == null ||
          input.contactPhone!.trim().isEmpty,
      clearContactEmail: input.contactEmail == null ||
          input.contactEmail!.trim().isEmpty,
      clearWebsiteUrl:
          input.websiteUrl == null || input.websiteUrl!.trim().isEmpty,
      updatedAt: now,
    );
    return BusinessOwnerProfileSaveResult.success;
  }

  @override
  void resetSessionToDemoSeed() {
    _profile = buildDemoOwnerProfile();
  }

  String? _normalizeOptional(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
