import 'package:flutter/foundation.dart';
import 'package:qoshni/features/location/application/qoshni_location_service.dart';
import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_location_failure.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';

enum QoshniMapLocationUiPhase {
  idle,
  acquiring,
  deviceFixReady,
  failed,
}

/// Map-screen session state for explicit “my location” actions only.
class QoshniMapLocationController extends ChangeNotifier {
  QoshniMapLocationController(this._locationService);

  final QoshniLocationService _locationService;

  QoshniMapLocationUiPhase phase = QoshniMapLocationUiPhase.idle;
  QoshniCurrentLocationSnapshot? deviceSnapshot;
  QoshniLocationFailure? lastFailure;
  bool permissionPromptRequestedThisSession = false;
  int acquireAttempts = 0;
  Future<void>? _acquireInFlight;

  bool get showDefaultMapViewLabel =>
      deviceSnapshot == null || !deviceSnapshot!.isDeviceDerived;

  bool get isAcquiring => phase == QoshniMapLocationUiPhase.acquiring;

  /// User tapped “my location” — may request permission once per explicit action.
  Future<void> requestDeviceLocation() async {
    if (_acquireInFlight != null) {
      return _acquireInFlight!;
    }
    permissionPromptRequestedThisSession = true;
    _acquireInFlight = _acquire(allowPermissionRequest: true)
        .whenComplete(() => _acquireInFlight = null);
    await _acquireInFlight;
  }

  Future<void> retry() async {
    if (_acquireInFlight != null) {
      return _acquireInFlight!;
    }
    _acquireInFlight = _acquire(allowPermissionRequest: true)
        .whenComplete(() => _acquireInFlight = null);
    await _acquireInFlight;
  }

  Future<void> openAppSettingsFromUserChoice() async {
    await _locationService.openAppSettings();
  }

  Future<QoshniLocationPermissionStatus> currentPermissionStatus() {
    return _locationService.permissionStatus(
      permissionPromptRequestedThisSession: permissionPromptRequestedThisSession,
    );
  }

  Future<void> _acquire({required bool allowPermissionRequest}) async {
    phase = QoshniMapLocationUiPhase.acquiring;
    lastFailure = null;
    acquireAttempts += 1;
    notifyListeners();

    final result = await _locationService.acquireDeviceLocation(
      allowPermissionRequest: allowPermissionRequest,
    );

    if (result.isSuccess) {
      deviceSnapshot = result.snapshot;
      phase = QoshniMapLocationUiPhase.deviceFixReady;
      lastFailure = null;
    } else {
      deviceSnapshot = null;
      phase = QoshniMapLocationUiPhase.failed;
      lastFailure = result.failure;
    }
    notifyListeners();
  }
}
