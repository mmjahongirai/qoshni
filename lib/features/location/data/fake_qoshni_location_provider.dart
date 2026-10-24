import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_location_kind.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';
import 'package:qoshni/features/location/domain/qoshni_location_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_location_source.dart';

class FakeQoshniLocationProvider implements QoshniLocationProvider {
  bool locationServiceEnabled = true;
  QoshniLocationPermissionStatus checkPermissionResult =
      QoshniLocationPermissionStatus.notYetRequested;
  QoshniLocationPermissionStatus requestPermissionResult =
      QoshniLocationPermissionStatus.granted;

  int checkPermissionCalls = 0;
  int requestPermissionCalls = 0;
  int getCurrentPositionCalls = 0;

  QoshniGeoCoordinates? nextPosition;
  Duration? positionDelay;
  Object? positionError;

  bool openAppSettingsResult = true;
  int openAppSettingsCalls = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => locationServiceEnabled;

  @override
  Future<QoshniLocationPermissionStatus> checkPermission() async {
    checkPermissionCalls += 1;
    return checkPermissionResult;
  }

  @override
  Future<QoshniLocationPermissionStatus> requestPermission() async {
    requestPermissionCalls += 1;
    checkPermissionResult = requestPermissionResult;
    return requestPermissionResult;
  }

  @override
  Future<QoshniCurrentLocationSnapshot> getCurrentPosition({
    required Duration timeout,
  }) async {
    getCurrentPositionCalls += 1;
    if (positionDelay != null) {
      await Future<void>.delayed(positionDelay!);
    }
    if (positionError != null) {
      final error = positionError!;
      if (error is Exception) {
        throw error;
      }
      throw Exception(error);
    }
    final coordinates = nextPosition ??
        QoshniGeoCoordinates.create(latitude: 41.3111, longitude: 69.2797);
    return QoshniCurrentLocationSnapshot(
      coordinates: coordinates,
      kind: QoshniLocationKind.deviceCurrent,
      source: QoshniLocationSource.gps,
      acquiredAt: DateTime.utc(2026, 1, 1),
      accuracyMeters: 42,
    );
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls += 1;
    return openAppSettingsResult;
  }
}
