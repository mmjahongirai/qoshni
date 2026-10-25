import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:qoshni/features/location/application/qoshni_location_service.dart';
import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_location_kind.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';
import 'package:qoshni/features/location/domain/qoshni_location_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_location_source.dart';

class GeolocatorQoshniLocationProvider implements QoshniLocationProvider {
  @override
  Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<QoshniLocationPermissionStatus> checkPermission() async {
    final status = await Geolocator.checkPermission();
    return _mapPermission(status);
  }

  @override
  Future<QoshniLocationPermissionStatus> requestPermission() async {
    final status = await Geolocator.requestPermission();
    return _mapPermission(status);
  }

  @override
  Future<QoshniCurrentLocationSnapshot> getCurrentPosition({
    required Duration timeout,
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: timeout,
        ),
      );
      final coordinates = QoshniGeoCoordinates.tryCreate(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (coordinates == null) {
        throw QoshniLocationPositionUnavailableException();
      }
      return QoshniCurrentLocationSnapshot(
        coordinates: coordinates,
        kind: QoshniLocationKind.deviceCurrent,
        source: _mapSource(position),
        acquiredAt: position.timestamp,
        accuracyMeters: position.accuracy,
      );
    } on LocationServiceDisabledException {
      throw QoshniLocationPositionUnavailableException();
    } on PermissionDeniedException {
      throw QoshniLocationPositionUnavailableException();
    } on TimeoutException {
      throw QoshniLocationPositionTimeoutException();
    }
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  QoshniLocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return QoshniLocationPermissionStatus.granted;
      case LocationPermission.denied:
        return QoshniLocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return QoshniLocationPermissionStatus.permanentlyDenied;
      case LocationPermission.unableToDetermine:
        return QoshniLocationPermissionStatus.notYetRequested;
    }
  }

  QoshniLocationSource _mapSource(Position position) {
    // Geolocator exposes isMocked on some platforms; no reliable GPS vs network split.
    if (position.isMocked) {
      return QoshniLocationSource.unknown;
    }
    return QoshniLocationSource.fused;
  }
}
