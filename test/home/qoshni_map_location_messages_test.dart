import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_location_messages.dart';
import 'package:qoshni/features/location/application/qoshni_location_service.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/data/fake_qoshni_location_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('home preview status reflects location phase', () async {
    final provider = FakeQoshniLocationProvider();
    provider.checkPermissionResult = QoshniLocationPermissionStatus.granted;
    final controller =
        QoshniMapLocationController(QoshniLocationService(provider));

    expect(
      qoshniHomeMapPreviewStatusMessage(
        l10n,
        mapboxConfigured: true,
        location: controller,
      ),
      l10n.homeMapPreviewStatusConfigured,
    );

    await controller.requestDeviceLocation();
    expect(
      qoshniHomeMapPreviewStatusMessage(
        l10n,
        mapboxConfigured: true,
        location: controller,
      ),
      l10n.homeMapPreviewStatusLocated,
    );
  });
}
