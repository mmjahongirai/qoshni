import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_route_intent.dart';
import 'package:qoshni/features/home/presentation/widgets/map_preview_card.dart';
import 'package:qoshni/features/location/application/qoshni_location_service.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/data/fake_qoshni_location_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';
import 'package:qoshni/features/location/domain/qoshni_location_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeQoshniLocationProvider fakeProvider;
  late AppLocalizations l10n;

  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
    fakeProvider = FakeQoshniLocationProvider();
    await getIt.unregister<QoshniMapLocationController>();
    await getIt.unregister<QoshniLocationService>();
    await getIt.unregister<QoshniLocationProvider>();
    getIt.registerLazySingleton<QoshniLocationProvider>(() => fakeProvider);
    getIt.registerLazySingleton<QoshniLocationService>(
      () => QoshniLocationService(fakeProvider),
    );
    getIt.registerLazySingleton<QoshniMapLocationController>(
      () => QoshniMapLocationController(getIt<QoshniLocationService>()),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('home preview does not request GPS until explicit action',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MapPreviewCard(
            l10n: l10n,
            onOpenMap: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(fakeProvider.requestPermissionCalls, 0);
    expect(fakeProvider.getCurrentPositionCalls, 0);
  });

  testWidgets('my location on home preview requests permission once',
      (tester) async {
    fakeProvider.checkPermissionResult = QoshniLocationPermissionStatus.denied;
    fakeProvider.requestPermissionResult =
        QoshniLocationPermissionStatus.granted;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MapPreviewCard(
            l10n: l10n,
            onOpenMap: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('My location'));
    await tester.pumpAndSettle();

    expect(fakeProvider.requestPermissionCalls, 1);
    expect(fakeProvider.getCurrentPositionCalls, 1);
  });

  testWidgets('open map passes locate intent and starts acquisition',
      (tester) async {
    fakeProvider.checkPermissionResult = QoshniLocationPermissionStatus.granted;
    QoshniMapRouteIntent? captured;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MapPreviewCard(
            l10n: l10n,
            onOpenMap: (intent) => captured = intent,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open map'));
    await tester.pump();

    expect(captured?.requestDeviceLocationOnOpen, isTrue);
    expect(fakeProvider.getCurrentPositionCalls, 1);
  });
}
