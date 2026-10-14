import 'package:qoshni/features/business_platform/domain/business_profile_kind.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

/// Local business profile draft (not the consumer [NearbyBusinessItem] catalog).
class BusinessProfileDraft {
  BusinessProfileDraft({
    required this.id,
    required this.kind,
    required this.businessName,
    required this.categoryId,
    required this.description,
    required this.addressDescription,
    required this.workingHours,
    this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final BusinessProfileKind kind;
  final String businessName;
  final ServiceCategoryId categoryId;
  final String description;
  final String addressDescription;
  final String workingHours;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isEditable => kind == BusinessProfileKind.userDraft;

  BusinessProfileDraft copyWith({
    String? businessName,
    ServiceCategoryId? categoryId,
    String? description,
    String? addressDescription,
    String? workingHours,
    String? contactPhone,
    bool clearContactPhone = false,
    DateTime? updatedAt,
  }) {
    return BusinessProfileDraft(
      id: id,
      kind: kind,
      businessName: businessName ?? this.businessName,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      addressDescription: addressDescription ?? this.addressDescription,
      workingHours: workingHours ?? this.workingHours,
      contactPhone:
          clearContactPhone ? null : (contactPhone ?? this.contactPhone),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Values copied from a sample profile into a new user draft form.
class BusinessProfileFormSeed {
  const BusinessProfileFormSeed({
    required this.businessName,
    required this.categoryId,
    required this.description,
    required this.addressDescription,
    required this.workingHours,
    this.contactPhone,
  });

  final String businessName;
  final ServiceCategoryId categoryId;
  final String description;
  final String addressDescription;
  final String workingHours;
  final String? contactPhone;
}
