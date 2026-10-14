import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_kind.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_profile_repository.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

class InMemoryBusinessProfileRepository implements BusinessProfileRepository {
  final List<BusinessProfileDraft> _userDrafts = [];

  @override
  List<BusinessProfileDraft> listUserDrafts() =>
      List<BusinessProfileDraft>.unmodifiable(_userDrafts);

  @override
  BusinessProfileDraft? userDraftById(String id) {
    for (final draft in _userDrafts) {
      if (draft.id == id) {
        return draft;
      }
    }
    return null;
  }

  @override
  String createDraft({
    required String businessName,
    required ServiceCategoryId categoryId,
    required String description,
    required String addressDescription,
    required String workingHours,
    String? contactPhone,
  }) {
    final now = DateTime.now();
    final id =
        'draft-${now.toUtc().millisecondsSinceEpoch.toRadixString(36)}';

    _userDrafts.insert(
      0,
      BusinessProfileDraft(
        id: id,
        kind: BusinessProfileKind.userDraft,
        businessName: businessName.trim(),
        categoryId: categoryId,
        description: description.trim(),
        addressDescription: addressDescription.trim(),
        workingHours: workingHours.trim(),
        contactPhone: _normalizePhone(contactPhone),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  @override
  bool updateDraft({
    required String id,
    required String businessName,
    required ServiceCategoryId categoryId,
    required String description,
    required String addressDescription,
    required String workingHours,
    String? contactPhone,
  }) {
    final index = _userDrafts.indexWhere((d) => d.id == id);
    if (index < 0) {
      return false;
    }
    final existing = _userDrafts[index];
    if (!existing.isEditable) {
      return false;
    }

    _userDrafts[index] = existing.copyWith(
      businessName: businessName.trim(),
      categoryId: categoryId,
      description: description.trim(),
      addressDescription: addressDescription.trim(),
      workingHours: workingHours.trim(),
      contactPhone: _normalizePhone(contactPhone),
      clearContactPhone: contactPhone == null || contactPhone.trim().isEmpty,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  String? _normalizePhone(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
