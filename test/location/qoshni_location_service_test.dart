import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/location/application/qoshni_location_service.dart';
import 'package:qoshni/features/location/data/fake_qoshni_location_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_location_failure.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';

void main() {
  late FakeQoshniLocationProvider provider;
  late QoshniLocationService service;

  setUp(() {
    provider = FakeQoshniLocationProvider();
    service = QoshniLocationService(provider);
  });

  test('permission not yet requested before explicit prompt', () async {
    provider.checkPermissionResult = QoshniLocationPermissionStatus.denied;
    final status = await service.permissionStatus(
      permissionPromptRequestedThisSession: false,
    );
    expect(status, QoshniLocationPermissionStatus.notYetRequested);
  });

  test('granted permission acquires device snapshot', () async {
    provider.requestPermissionResult = QoshniLocationPermissionStatus.granted;
    provider.checkPermissionResult = QoshniLocationPermissionStatus.granted;

    final result = await service.acquireDeviceLocation(
      allowPermissionRequest: true,
    );

    expect(result.isSuccess, isTrue);
    expect(result.snapshot!.isDeviceDerived, isTrue);
    expect(provider.requestPermissionCalls, 0);
    expect(provider.getCurrentPositionCalls, 1);
  });

  test('denied permission without request flag fails closed', () async {
    provider.checkPermissionResult = QoshniLocationPermissionStatus.denied;

    final result = await service.acquireDeviceLocation(
      allowPermissionRequest: false,
    );

    expect(result.failure!.reason, QoshniLocationFailureReason.permissionDenied);
    expect(provider.requestPermissionCalls, 0);
  });

  test('permanently denied after request', () async {
    provider.checkPermissionResult = QoshniLocationPermissionStatus.denied;
    provider.requestPermissionResult =
        QoshniLocationPermissionStatus.permanentlyDenied;

    final result = await service.acquireDeviceLocation(
      allowPermissionRequest: true,
    );

    expect(
      result.failure!.reason,
      QoshniLocationFailureReason.permissionPermanentlyDenied,
    );
  });

  test('location services disabled', () async {
    provider.locationServiceEnabled = false;

    final result = await service.acquireDeviceLocation(
      allowPermissionRequest: true,
    );

    expect(
      result.failure!.reason,
      QoshniLocationFailureReason.locationServicesDisabled,
    );
  });

  test('timeout surfaces typed failure', () async {
    provider.checkPermissionResult = QoshniLocationPermissionStatus.granted;
    provider.positionError = QoshniLocationPositionTimeoutException();

    final result = await service.acquireDeviceLocation(
      allowPermissionRequest: true,
    );

    expect(result.failure!.reason, QoshniLocationFailureReason.timeout);
  });

  test('unavailable position', () async {
    provider.checkPermissionResult = QoshniLocationPermissionStatus.granted;
    provider.positionError = QoshniLocationPositionUnavailableException();

    final result = await service.acquireDeviceLocation(
      allowPermissionRequest: true,
    );

    expect(
      result.failure!.reason,
      QoshniLocationFailureReason.positionUnavailable,
    );
  });
}
