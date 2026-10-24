import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';

enum QoshniLocationFailureReason {
  permissionDenied,
  permissionPermanentlyDenied,
  locationServicesDisabled,
  timeout,
  positionUnavailable,
  unknown,
}

class QoshniLocationFailure {
  const QoshniLocationFailure({
    required this.reason,
    this.permissionStatus,
  });

  final QoshniLocationFailureReason reason;
  final QoshniLocationPermissionStatus? permissionStatus;
}
