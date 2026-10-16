import 'package:qoshni/features/business_platform/domain/business_owner_profile_status.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

/// Business-level owner profile (Phase 08). Branch/staff fields live elsewhere.
class BusinessOwnerProfile {
  const BusinessOwnerProfile({
    required this.sessionProfileId,
    required this.dataSource,
    required this.lifecycleStatus,
    required this.legalBusinessName,
    required this.displayName,
    required this.description,
    required this.categoryId,
    this.contactPhone,
    this.contactEmail,
    this.websiteUrl,
    this.visibility = BusinessOwnerProfileVisibility.hiddenPreview,
    required this.createdAt,
    required this.updatedAt,
  });

  final String sessionProfileId;
  final BusinessOwnerProfileDataSource dataSource;
  final BusinessOwnerProfileLifecycleStatus lifecycleStatus;
  final String legalBusinessName;
  final String displayName;
  final String description;
  final ServiceCategoryId categoryId;
  final String? contactPhone;
  final String? contactEmail;

  /// Demo-only field until a backend website field exists.
  final String? websiteUrl;
  final BusinessOwnerProfileVisibility visibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDemoSeed => dataSource == BusinessOwnerProfileDataSource.demoSeed;

  bool get isVerified => false;

  /// 0.0–1.0 completeness for UX (client-side only).
  double get completenessFraction {
    var filled = 0;
    const total = 7;
    if (legalBusinessName.trim().isNotEmpty) filled++;
    if (displayName.trim().isNotEmpty) filled++;
    if (description.trim().isNotEmpty) filled++;
    if (contactPhone != null && contactPhone!.trim().isNotEmpty) filled++;
    if (contactEmail != null && contactEmail!.trim().isNotEmpty) filled++;
    if (websiteUrl != null && websiteUrl!.trim().isNotEmpty) filled++;
    filled++;
    return filled / total;
  }

  BusinessOwnerProfile copyWith({
    BusinessOwnerProfileDataSource? dataSource,
    String? legalBusinessName,
    String? displayName,
    String? description,
    ServiceCategoryId? categoryId,
    String? contactPhone,
    String? contactEmail,
    String? websiteUrl,
    BusinessOwnerProfileVisibility? visibility,
    bool clearContactPhone = false,
    bool clearContactEmail = false,
    bool clearWebsiteUrl = false,
    DateTime? updatedAt,
  }) {
    return BusinessOwnerProfile(
      sessionProfileId: sessionProfileId,
      dataSource: dataSource ?? this.dataSource,
      lifecycleStatus: lifecycleStatus,
      legalBusinessName: legalBusinessName ?? this.legalBusinessName,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      contactPhone: clearContactPhone ? null : (contactPhone ?? this.contactPhone),
      contactEmail: clearContactEmail ? null : (contactEmail ?? this.contactEmail),
      websiteUrl: clearWebsiteUrl ? null : (websiteUrl ?? this.websiteUrl),
      visibility: visibility ?? this.visibility,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Input for create/update in the session repository.
class BusinessOwnerProfileInput {
  const BusinessOwnerProfileInput({
    required this.legalBusinessName,
    required this.displayName,
    required this.description,
    required this.categoryId,
    this.contactPhone,
    this.contactEmail,
    this.websiteUrl,
    this.visibility = BusinessOwnerProfileVisibility.hiddenPreview,
  });

  final String legalBusinessName;
  final String displayName;
  final String description;
  final ServiceCategoryId categoryId;
  final String? contactPhone;
  final String? contactEmail;
  final String? websiteUrl;
  final BusinessOwnerProfileVisibility visibility;
}
