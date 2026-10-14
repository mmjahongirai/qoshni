import 'package:flutter/foundation.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/data/business_offering_sample_data.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_pricing_unit.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_offering_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_profile_repository.dart';

/// Orchestrates owner offerings for user business profile drafts.
class BusinessOfferingsController extends ChangeNotifier {
  BusinessOfferingsController({
    required this.profileRepository,
    required this.offeringRepository,
    required this.inventoryRepository,
    required this.config,
  });

  final BusinessProfileRepository profileRepository;
  final BusinessOfferingRepository offeringRepository;
  final BusinessInventoryRepository inventoryRepository;
  final AppConfig config;

  List<BusinessProfileOffering> sampleOfferingsForProfile(
    AppLocalizations l10n,
    String businessProfileId,
  ) =>
      buildSampleOfferingsForProfile(l10n, businessProfileId, config);

  List<BusinessProfileOffering> offeringsForProfile(String businessProfileId) {
    return offeringRepository.offeringsForProfile(businessProfileId);
  }

  BusinessProfileOffering? offeringById({
    required String businessProfileId,
    required String offeringId,
  }) {
    return offeringRepository.offeringById(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
    );
  }

  bool _isEditableProfile(String businessProfileId) {
    final draft = profileRepository.userDraftById(businessProfileId);
    return draft != null && draft.isEditable;
  }

  String? addOffering({
    required String businessProfileId,
    required BusinessOfferingKind kind,
    required String name,
    required String description,
    required BusinessPricingUnit pricingUnit,
    int? samplePriceUzs,
    int? demoDepositUzs,
  }) {
    if (!_isEditableProfile(businessProfileId)) {
      return null;
    }

    final id = offeringRepository.addOffering(
      businessProfileId: businessProfileId,
      kind: kind,
      name: name,
      description: description,
      pricingUnit: pricingUnit,
      samplePriceUzs: samplePriceUzs,
      demoDepositUzs: demoDepositUzs,
    );
    if (id != null) {
      notifyListeners();
    }
    return id;
  }

  bool updateOffering({
    required String businessProfileId,
    required String offeringId,
    required BusinessOfferingKind kind,
    required String name,
    required String description,
    required BusinessPricingUnit pricingUnit,
    int? samplePriceUzs,
    int? demoDepositUzs,
  }) {
    if (!_isEditableProfile(businessProfileId)) {
      return false;
    }

    final result = offeringRepository.updateOffering(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
      kind: kind,
      name: name,
      description: description,
      pricingUnit: pricingUnit,
      samplePriceUzs: samplePriceUzs,
      demoDepositUzs: demoDepositUzs,
    );
    if (!result.success) {
      return false;
    }
    if (result.kindChanged) {
      inventoryRepository.removeForOffering(
        businessProfileId: businessProfileId,
        offeringId: offeringId,
      );
    }
    notifyListeners();
    return true;
  }

  bool removeOffering({
    required String businessProfileId,
    required String offeringId,
  }) {
    if (!_isEditableProfile(businessProfileId)) {
      return false;
    }

    final removed = offeringRepository.removeOffering(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
    );
    if (!removed) {
      return false;
    }
    inventoryRepository.removeForOffering(
      businessProfileId: businessProfileId,
      offeringId: offeringId,
    );
    notifyListeners();
    return true;
  }
}
