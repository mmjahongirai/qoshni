import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

/// User-owned business profile drafts (API-backed implementations later).
abstract class BusinessProfileRepository {
  List<BusinessProfileDraft> listUserDrafts();

  BusinessProfileDraft? userDraftById(String id);

  String createDraft({
    required String businessName,
    required ServiceCategoryId categoryId,
    required String description,
    required String addressDescription,
    required String workingHours,
    String? contactPhone,
  });

  bool updateDraft({
    required String id,
    required String businessName,
    required ServiceCategoryId categoryId,
    required String description,
    required String addressDescription,
    required String workingHours,
    String? contactPhone,
  });
}
