import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_location_failure.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';
import 'package:qoshni/features/location/domain/qoshni_location_provider.dart';

class QoshniLocationAcquireResult {
  const QoshniLocationAcquireResult.success(this.snapshot)
      : failure = null;

  const QoshniLocationAcquireResult.failure(this.failure)
      : snapshot = null;

  final QoshniCurrentLocationSnapshot? snapshot;
  final QoshniLocationFailure? failure;

  bool get isSuccess => snapshot != null;
}

/// Permission-aware device location acquisition (no background tracking).
class QoshniLocationService {
  QoshniLocationService(this._provider);

  final QoshniLocationProvider _provider;

  static const Duration defaultAcquireTimeout = Duration(seconds: 15);

  Future<QoshniLocationPermissionStatus> permissionStatus({
    required bool permissionPromptRequestedThisSession,
  }) async {
    final platform = await _provider.checkPermission();
    if (!permissionPromptRequestedThisSession &&
        (platform == QoshniLocationPermissionStatus.denied ||
            platform == QoshniLocationPermissionStatus.notYetRequested)) {
      return QoshniLocationPermissionStatus.notYetRequested;
    }
    return platform;
  }

  Future<QoshniLocationAcquireResult> acquireDeviceLocation({
    required bool allowPermissionRequest,
    Duration timeout = defaultAcquireTimeout,
  }) async {
    if (!await _provider.isLocationServiceEnabled()) {
      return QoshniLocationAcquireResult.failure(
        const QoshniLocationFailure(
          reason: QoshniLocationFailureReason.locationServicesDisabled,
        ),
      );
    }

    var permission = await _provider.checkPermission();
    if (permission != QoshniLocationPermissionStatus.granted &&
        permission != QoshniLocationPermissionStatus.limited) {
      if (!allowPermissionRequest) {
        return QoshniLocationAcquireResult.failure(
          QoshniLocationFailure(
            reason: _failureForPermission(permission),
            permissionStatus: permission,
          ),
        );
      }
      permission = await _provider.requestPermission();
    }

    if (permission == QoshniLocationPermissionStatus.permanentlyDenied) {
      return QoshniLocationAcquireResult.failure(
        QoshniLocationFailure(
          reason: QoshniLocationFailureReason.permissionPermanentlyDenied,
          permissionStatus: permission,
        ),
      );
    }
    if (permission != QoshniLocationPermissionStatus.granted &&
        permission != QoshniLocationPermissionStatus.limited) {
      return QoshniLocationAcquireResult.failure(
        QoshniLocationFailure(
          reason: _failureForPermission(permission),
          permissionStatus: permission,
        ),
      );
    }

    try {
      final snapshot = await _provider.getCurrentPosition(timeout: timeout);
      return QoshniLocationAcquireResult.success(snapshot);
    } on QoshniLocationPositionTimeoutException {
      return const QoshniLocationAcquireResult.failure(
        QoshniLocationFailure(reason: QoshniLocationFailureReason.timeout),
      );
    } on QoshniLocationPositionUnavailableException {
      return const QoshniLocationAcquireResult.failure(
        QoshniLocationFailure(
          reason: QoshniLocationFailureReason.positionUnavailable,
        ),
      );
    } catch (_) {
      return const QoshniLocationAcquireResult.failure(
        QoshniLocationFailure(reason: QoshniLocationFailureReason.unknown),
      );
    }
  }

  Future<bool> openAppSettings() => _provider.openAppSettings();

  QoshniLocationFailureReason _failureForPermission(
    QoshniLocationPermissionStatus permission,
  ) {
    switch (permission) {
      case QoshniLocationPermissionStatus.permanentlyDenied:
        return QoshniLocationFailureReason.permissionPermanentlyDenied;
      case QoshniLocationPermissionStatus.denied:
      case QoshniLocationPermissionStatus.notYetRequested:
        return QoshniLocationFailureReason.permissionDenied;
      case QoshniLocationPermissionStatus.granted:
      case QoshniLocationPermissionStatus.limited:
        return QoshniLocationFailureReason.unknown;
    }
  }
}

/// Thrown by [QoshniLocationProvider] implementations for typed failures.
class QoshniLocationPositionTimeoutException implements Exception {}

class QoshniLocationPositionUnavailableException implements Exception {}
