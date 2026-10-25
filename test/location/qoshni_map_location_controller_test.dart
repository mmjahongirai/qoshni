import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/location/application/qoshni_location_service.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/data/fake_qoshni_location_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_location_failure.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';

void main() {
  late FakeQoshniLocationProvider provider;
  late QoshniMapLocationController controller;

  setUp(() {
    provider = FakeQoshniLocationProvider();
    controller = QoshniMapLocationController(QoshniLocationService(provider));
  });

  test('shows default map label until device fix', () {
    expect(controller.showDefaultMapViewLabel, isTrue);
  });

  test('explicit request acquires location and hides default label', () async {
    provider.checkPermissionResult = QoshniLocationPermissionStatus.denied;
    provider.requestPermissionResult = QoshniLocationPermissionStatus.granted;
    await controller.requestDeviceLocation();

    expect(controller.phase, QoshniMapLocationUiPhase.deviceFixReady);
    expect(controller.showDefaultMapViewLabel, isFalse);
    expect(provider.requestPermissionCalls, 1);
    expect(provider.getCurrentPositionCalls, 1);
  });

  test('retry increments attempts after failure', () async {
    provider.checkPermissionResult = QoshniLocationPermissionStatus.denied;
    provider.requestPermissionResult = QoshniLocationPermissionStatus.denied;

    await controller.requestDeviceLocation();
    expect(controller.phase, QoshniMapLocationUiPhase.failed);
    expect(
      controller.lastFailure!.reason,
      QoshniLocationFailureReason.permissionDenied,
    );

    provider.requestPermissionResult = QoshniLocationPermissionStatus.granted;
    await controller.retry();
    expect(controller.acquireAttempts, 2);
    expect(controller.phase, QoshniMapLocationUiPhase.deviceFixReady);
  });

  test('open settings only via explicit controller method', () async {
    await controller.openAppSettingsFromUserChoice();
    expect(provider.openAppSettingsCalls, 1);
  });

  test('parallel explicit requests share one in-flight acquire', () async {
    provider.checkPermissionResult = QoshniLocationPermissionStatus.granted;

    await Future.wait([
      controller.requestDeviceLocation(),
      controller.requestDeviceLocation(),
    ]);

    expect(provider.getCurrentPositionCalls, 1);
  });
}
