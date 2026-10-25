import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/domain/qoshni_location_failure.dart';

String? qoshniMapLocationFailureMessage(
  AppLocalizations l10n,
  QoshniLocationFailure? failure,
) {
  if (failure == null) {
    return null;
  }
  switch (failure.reason) {
    case QoshniLocationFailureReason.permissionDenied:
      return l10n.mapLocationPermissionDenied;
    case QoshniLocationFailureReason.permissionPermanentlyDenied:
      return l10n.mapLocationPermissionDeniedForever;
    case QoshniLocationFailureReason.locationServicesDisabled:
      return l10n.mapLocationServicesDisabled;
    case QoshniLocationFailureReason.timeout:
      return l10n.mapLocationTimeout;
    case QoshniLocationFailureReason.positionUnavailable:
      return l10n.mapLocationUnavailable;
    case QoshniLocationFailureReason.unknown:
      return l10n.mapLocationUnavailable;
  }
}

String qoshniHomeMapPreviewStatusMessage(
  AppLocalizations l10n, {
  required bool mapboxConfigured,
  required QoshniMapLocationController location,
}) {
  if (!mapboxConfigured) {
    return l10n.homeMapPreviewStatusNotConfigured;
  }
  switch (location.phase) {
    case QoshniMapLocationUiPhase.idle:
      return l10n.homeMapPreviewStatusConfigured;
    case QoshniMapLocationUiPhase.acquiring:
      return l10n.mapLocationAcquiring;
    case QoshniMapLocationUiPhase.deviceFixReady:
      return l10n.homeMapPreviewStatusLocated;
    case QoshniMapLocationUiPhase.failed:
      return qoshniMapLocationFailureMessage(l10n, location.lastFailure) ??
          l10n.mapLocationUnavailable;
  }
}
