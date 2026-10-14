import 'package:flutter/foundation.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/data/business_profile_sample_data.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_profile_repository.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

/// Orchestrates user business profile drafts and read-only sample resolution.
class BusinessProfileController extends ChangeNotifier {
  BusinessProfileController(this._repository, this._config);

  final BusinessProfileRepository _repository;
  final AppConfig _config;

  List<BusinessProfileDraft> get userDrafts => _repository.listUserDrafts();

  int get userDraftCount => userDrafts.length;

  BusinessProfileDraft? userDraftById(String id) =>
      _repository.userDraftById(id);

  /// Resolves a profile from session drafts or the isolated sample source.
  BusinessProfileDraft? resolveProfile(AppLocalizations l10n, String profileId) {
    final user = userDraftById(profileId);
    if (user != null) {
      return user;
    }
    return findBusinessProfileSample(l10n, profileId, _config);
  }

  List<BusinessProfileDraft> sampleProfiles(AppLocalizations l10n) =>
      buildBusinessProfileSamples(l10n, _config);

  String createDraft({
    required String businessName,
    required ServiceCategoryId categoryId,
    required String description,
    required String addressDescription,
    required String workingHours,
    String? contactPhone,
  }) {
    final id = _repository.createDraft(
      businessName: businessName,
      categoryId: categoryId,
      description: description,
      addressDescription: addressDescription,
      workingHours: workingHours,
      contactPhone: contactPhone,
    );
    notifyListeners();
    return id;
  }

  bool updateDraft({
    required String id,
    required String businessName,
    required ServiceCategoryId categoryId,
    required String description,
    required String addressDescription,
    required String workingHours,
    String? contactPhone,
  }) {
    final updated = _repository.updateDraft(
      id: id,
      businessName: businessName,
      categoryId: categoryId,
      description: description,
      addressDescription: addressDescription,
      workingHours: workingHours,
      contactPhone: contactPhone,
    );
    if (updated) {
      notifyListeners();
    }
    return updated;
  }
}
