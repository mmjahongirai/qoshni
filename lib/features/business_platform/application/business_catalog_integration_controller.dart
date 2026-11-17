import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_failure.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_repository.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog_repository.dart';

/// The signed-in access token. [ApiClient] does not attach this itself.
abstract class AccessTokenReader {
  String? get accessToken;
}

class AuthAccessTokenReader implements AccessTokenReader {
  AuthAccessTokenReader(this._authController);

  final AuthController _authController;

  @override
  String? get accessToken => _authController.accessToken;
}

/// Reads verified onboarding applications. Local business profile ids are not
/// accepted.
abstract class VerifiedApplicationLookup {
  Future<List<String>> verifiedApplicationIds({required String accessToken});
}

class OnboardingVerifiedApplicationLookup implements VerifiedApplicationLookup {
  OnboardingVerifiedApplicationLookup(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<List<String>> verifiedApplicationIds({
    required String accessToken,
  }) async {
    final applications = await _repository.listApplications(
      accessToken: accessToken,
    );
    return [
      for (final application in applications)
        if (application.verificationStatus == 'verified' &&
            authoritativeApplicationIdPattern.hasMatch(
              application.applicationId,
            ))
          application.applicationId,
    ];
  }
}

enum BusinessCatalogLinkPhase { idle, loading, ready, unavailable }

enum BusinessCatalogLinkBlocker {
  apiNotConfigured,
  signedOut,
  sessionExpired,
  noVerifiedApplication,
  ambiguousApplication,
  forbidden,
  lookupFailed,
}

/// Links the signed-in owner to one verified onboarding application.
///
/// Demo catalogs stay on their own repositories. A failed live call returns
/// null and never substitutes sample offerings.
class BusinessCatalogIntegrationController extends ChangeNotifier {
  BusinessCatalogIntegrationController({
    required this.config,
    required this.accessTokenReader,
    required this.applications,
    required this.catalog,
  });

  final AppConfig config;
  final AccessTokenReader accessTokenReader;
  final VerifiedApplicationLookup applications;
  final AuthoritativeCatalogRepository catalog;

  BusinessCatalogLinkPhase phase = BusinessCatalogLinkPhase.idle;
  BusinessCatalogLinkBlocker? blocker;
  AuthoritativeCatalogFailure? lastFailure;
  String? applicationId;

  bool get isLiveCatalogReady =>
      phase == BusinessCatalogLinkPhase.ready &&
      applicationId != null &&
      authoritativeApplicationIdPattern.hasMatch(applicationId!) &&
      (accessTokenReader.accessToken?.isNotEmpty ?? false);

  Future<void>? _linkRefresh;

  Future<void> refresh() {
    final existing = _linkRefresh;
    if (existing != null) {
      return existing;
    }
    final gate = Completer<void>();
    _linkRefresh = gate.future;
    _refreshUnlocked()
        .then(
          (_) {
            if (!gate.isCompleted) {
              gate.complete();
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!gate.isCompleted) {
              gate.completeError(error, stackTrace);
            }
          },
        )
        .whenComplete(() {
          if (identical(_linkRefresh, gate.future)) {
            _linkRefresh = null;
          }
        });
    return gate.future;
  }

  Future<void> _refreshUnlocked() async {
    phase = BusinessCatalogLinkPhase.loading;
    blocker = null;
    applicationId = null;
    lastFailure = null;
    notifyListeners();

    if (!config.apiConfigured) {
      phase = BusinessCatalogLinkPhase.unavailable;
      blocker = BusinessCatalogLinkBlocker.apiNotConfigured;
      notifyListeners();
      return;
    }
    final token = accessTokenReader.accessToken;
    if (token == null || token.isEmpty) {
      phase = BusinessCatalogLinkPhase.unavailable;
      blocker = BusinessCatalogLinkBlocker.signedOut;
      notifyListeners();
      return;
    }
    try {
      final ids = await applications.verifiedApplicationIds(accessToken: token);
      if (ids.length == 1) {
        applicationId = ids.single;
        phase = BusinessCatalogLinkPhase.ready;
      } else {
        phase = BusinessCatalogLinkPhase.unavailable;
        blocker = ids.isEmpty
            ? BusinessCatalogLinkBlocker.noVerifiedApplication
            : BusinessCatalogLinkBlocker.ambiguousApplication;
      }
    } on OnboardingFailure catch (failure) {
      phase = BusinessCatalogLinkPhase.unavailable;
      blocker = switch (failure.code) {
        OnboardingErrorCode.authenticationRequired =>
          BusinessCatalogLinkBlocker.sessionExpired,
        OnboardingErrorCode.forbidden => BusinessCatalogLinkBlocker.forbidden,
        _ => BusinessCatalogLinkBlocker.lookupFailed,
      };
    } on AuthoritativeCatalogFailure catch (failure) {
      _capture(failure);
    }
    notifyListeners();
  }

  Future<List<AuthoritativeCatalogItem>?> listItems() {
    return _live((token, applicationId) {
      return catalog.listItems(
        accessToken: token,
        applicationId: applicationId,
      );
    });
  }

  Future<AuthoritativeCatalogItem?> createItem({
    required String catalogItemStableId,
    required AuthoritativeOfferingKind offeringKind,
    required String title,
    required int unitPriceMinor,
  }) {
    return _live((token, applicationId) {
      return catalog.createItem(
        accessToken: token,
        applicationId: applicationId,
        catalogItemStableId: catalogItemStableId,
        offeringKind: offeringKind,
        title: title,
        unitPriceMinor: unitPriceMinor,
      );
    });
  }

  Future<AuthoritativeCatalogItem?> updatePrice({
    required String catalogItemId,
    required int unitPriceMinor,
  }) {
    return _live((token, applicationId) {
      return catalog.updatePrice(
        accessToken: token,
        applicationId: applicationId,
        catalogItemId: catalogItemId,
        unitPriceMinor: unitPriceMinor,
      );
    });
  }

  Future<AuthoritativeCatalogItem?> updateStatus({
    required String catalogItemId,
    required AuthoritativeCatalogItemStatus status,
  }) {
    return _live((token, applicationId) {
      return catalog.updateStatus(
        accessToken: token,
        applicationId: applicationId,
        catalogItemId: catalogItemId,
        status: status,
      );
    });
  }

  Future<AuthoritativeInventoryBalance?> getInventory({
    required String catalogItemId,
  }) {
    return _live((token, applicationId) {
      return catalog.getInventory(
        accessToken: token,
        applicationId: applicationId,
        catalogItemId: catalogItemId,
      );
    });
  }

  Future<AuthoritativeInventoryBalance?> openInventory({
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) {
    return _live((token, applicationId) {
      return catalog.openInventory(
        accessToken: token,
        applicationId: applicationId,
        catalogItemId: catalogItemId,
        quantityOnHand: quantityOnHand,
        reason: reason,
      );
    });
  }

  Future<AuthoritativeInventoryBalance?> replenishInventory({
    required String catalogItemId,
    required int quantity,
    required String reason,
  }) {
    return _live((token, applicationId) {
      return catalog.replenishInventory(
        accessToken: token,
        applicationId: applicationId,
        catalogItemId: catalogItemId,
        quantity: quantity,
        reason: reason,
      );
    });
  }

  Future<AuthoritativeInventoryBalance?> correctInventoryCount({
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) {
    return _live((token, applicationId) {
      return catalog.correctInventoryCount(
        accessToken: token,
        applicationId: applicationId,
        catalogItemId: catalogItemId,
        quantityOnHand: quantityOnHand,
        reason: reason,
      );
    });
  }

  Future<List<AuthoritativeInventoryEvent>?> listInventoryEvents({
    required String catalogItemId,
  }) {
    return _live((token, applicationId) {
      return catalog.listInventoryEvents(
        accessToken: token,
        applicationId: applicationId,
        catalogItemId: catalogItemId,
      );
    });
  }

  Future<T?> _live<T>(
    Future<T> Function(String token, String applicationId) action,
  ) async {
    if (!isLiveCatalogReady) {
      return null;
    }
    try {
      final value = await action(
        accessTokenReader.accessToken!,
        applicationId!,
      );
      lastFailure = null;
      notifyListeners();
      return value;
    } on AuthoritativeCatalogFailure catch (failure) {
      _capture(failure);
      notifyListeners();
      return null;
    }
  }

  void _capture(AuthoritativeCatalogFailure failure) {
    lastFailure = failure;
    switch (failure.code) {
      case AuthoritativeCatalogErrorCode.authenticationRequired:
        phase = BusinessCatalogLinkPhase.unavailable;
        applicationId = null;
        blocker = BusinessCatalogLinkBlocker.sessionExpired;
      case AuthoritativeCatalogErrorCode.forbidden:
        phase = BusinessCatalogLinkPhase.unavailable;
        blocker = BusinessCatalogLinkBlocker.forbidden;
      case AuthoritativeCatalogErrorCode.apiNotConfigured:
        phase = BusinessCatalogLinkPhase.unavailable;
        blocker = BusinessCatalogLinkBlocker.apiNotConfigured;
      case AuthoritativeCatalogErrorCode.catalogUnavailable:
        phase = BusinessCatalogLinkPhase.unavailable;
        blocker = BusinessCatalogLinkBlocker.lookupFailed;
      case AuthoritativeCatalogErrorCode.notFound:
      case AuthoritativeCatalogErrorCode.conflict:
      case AuthoritativeCatalogErrorCode.validationFailed:
      case AuthoritativeCatalogErrorCode.invalidApplicationId:
      case AuthoritativeCatalogErrorCode.network:
      case AuthoritativeCatalogErrorCode.malformedResponse:
      case AuthoritativeCatalogErrorCode.unknown:
        break;
    }
  }
}
