import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_route_intent.dart';
import 'package:qoshni/features/home/presentation/pages/map_placeholder_page.dart';
import 'package:qoshni/features/location/application/qoshni_location_service.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/data/fake_qoshni_location_provider.dart';
import 'package:qoshni/features/location/domain/qoshni_location_permission_status.dart';
import 'package:qoshni/features/location/domain/qoshni_location_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeQoshniLocationProvider fakeProvider;

  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
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

  Widget wrap(Widget child) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => child,
          ),
        ],
      ),
    );
  }

  testWidgets('map open does not request permission or GPS', (tester) async {
    await tester.pumpWidget(wrap(const MapPlaceholderPage()));
    await tester.pumpAndSettle();

    expect(fakeProvider.requestPermissionCalls, 0);
    expect(fakeProvider.getCurrentPositionCalls, 0);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Mapbox access token required'), findsOneWidget);
  });

  testWidgets('map remains usable when permission denied', (tester) async {
    fakeProvider.checkPermissionResult = QoshniLocationPermissionStatus.denied;
    fakeProvider.requestPermissionResult = QoshniLocationPermissionStatus.denied;

    await tester.pumpWidget(wrap(const MapPlaceholderPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('My location'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Location permission is off'),
      findsOneWidget,
    );
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Mapbox access token required'), findsOneWidget);
  });

  testWidgets('open with intent requests device location once', (tester) async {
    fakeProvider.checkPermissionResult = QoshniLocationPermissionStatus.granted;

    await tester.pumpWidget(
      wrap(
        const MapPlaceholderPage(
          intent: QoshniMapRouteIntent(requestDeviceLocationOnOpen: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(fakeProvider.getCurrentPositionCalls, 1);
  });

  testWidgets('rebuild does not repeat permission prompts', (tester) async {
    fakeProvider.checkPermissionResult = QoshniLocationPermissionStatus.granted;

    await tester.pumpWidget(wrap(const MapPlaceholderPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('My location'));
    await tester.pumpAndSettle();

    final callsAfterFirst = fakeProvider.requestPermissionCalls;

    await tester.pumpWidget(wrap(const MapPlaceholderPage()));
    await tester.pumpAndSettle();

    expect(fakeProvider.requestPermissionCalls, callsAfterFirst);
  });
}
