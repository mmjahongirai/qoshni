import 'package:flutter/foundation.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/location/data/in_memory_qoshni_saved_place_repository.dart';
import 'package:qoshni/features/location/data/remote_qoshni_saved_place_repository.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_geocoding_suggestion.dart';
import 'package:qoshni/features/location/domain/qoshni_saved_place.dart';
import 'package:qoshni/features/location/domain/repositories/qoshni_saved_place_repository.dart';
import 'package:qoshni/core/network/api_client.dart';

enum QoshniSavedPlacesPhase {
  idle,
  loading,
  ready,
  error,
}

/// User-initiated saved-place CRUD — never fed by silent GPS.
class QoshniSavedPlacesController extends ChangeNotifier {
  QoshniSavedPlacesController({
    required AppConfig config,
    required AuthController authController,
    required ApiClient apiClient,
  })  : _config = config,
        _authController = authController,
        _apiClient = apiClient;

  final AppConfig _config;
  final AuthController _authController;
  final ApiClient _apiClient;

  QoshniSavedPlacesPhase phase = QoshniSavedPlacesPhase.idle;
  List<QoshniSavedPlace> places = const [];
  String? lastErrorMessage;

  QoshniSavedPlaceRepository? _repository;

  bool get canUseRemote =>
      _config.apiConfigured &&
      _authController.accessToken != null &&
      _authController.userId != null;

  Future<void> refresh() async {
    phase = QoshniSavedPlacesPhase.loading;
    lastErrorMessage = null;
    notifyListeners();
    try {
      final repo = _repositoryForSession();
      places = await repo.listForCurrentUser();
      phase = QoshniSavedPlacesPhase.ready;
    } catch (_) {
      phase = QoshniSavedPlacesPhase.error;
      lastErrorMessage = 'saved_places_load_failed';
    }
    notifyListeners();
  }

  Future<QoshniSavedPlace?> saveFromUserConfirmation({
    required String label,
    required QoshniGeoCoordinates coordinates,
    String? addressDescription,
    QoshniGeocodingSuggestion? fromSuggestion,
  }) async {
    final description = addressDescription ??
        (fromSuggestion != null ? fromSuggestion.displayLabel : null);
    final repo = _repositoryForSession();
    final created = await repo.create(
      label: label,
      coordinates: coordinates,
      addressDescription: description,
    );
    places = [...places, created];
    notifyListeners();
    return created;
  }

  Future<void> deletePlace(String placeId) async {
    final repo = _repositoryForSession();
    await repo.delete(placeId: placeId);
    places = places.where((p) => p.id != placeId).toList(growable: false);
    notifyListeners();
  }

  QoshniSavedPlaceRepository _repositoryForSession() {
    final cached = _repository;
    final userId = _authController.userId;
    if (cached != null) {
      return cached;
    }
    if (canUseRemote && userId != null) {
      _repository = RemoteQoshniSavedPlaceRepository(
        apiClient: _apiClient,
        ownerUserId: userId,
        accessTokenProvider: () async => _authController.accessToken,
      );
    } else {
      _repository = InMemoryQoshniSavedPlaceRepository(
        ownerUserId: userId ?? 'guest',
      );
    }
    return _repository!;
  }

  void resetSessionRepository() {
    _repository = null;
    places = const [];
    phase = QoshniSavedPlacesPhase.idle;
    notifyListeners();
  }
}
