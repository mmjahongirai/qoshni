import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';

/// Platform location adapter — replaceable for tests (no GPS/network in unit tests).
abstract class QoshniLocationProvider {
  Future<bool> isLocationServiceEnabled();

  Future<QoshniLocationPermissionStatus> checkPermission();

  Future<QoshniLocationPermissionStatus> requestPermission();

  Future<QoshniCurrentLocationSnapshot> getCurrentPosition({
    required Duration timeout,
  });

  Future<bool> openAppSettings();
}
