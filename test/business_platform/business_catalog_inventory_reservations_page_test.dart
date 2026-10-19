import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_inventory_reservation_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_reservation_repository.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_inventory_reservations_page.dart';

Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
    getIt<LocaleController>().setLocale(const Locale('en'));
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows demo disclaimer and empty state', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogInventoryReservationsPage()));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('not connected to live checkout'),
      findsOneWidget,
    );
    expect(find.text('No reservations in this preview session yet.'), findsOneWidget);
  });

  testWidgets('reserve dialog validation keeps dialog open', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogInventoryReservationsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reserve stock'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reserve'));
    await tester.pumpAndSettle();

    expect(find.text('Create demo reservation'), findsOneWidget);
    expect(find.text('Select an inventory row.'), findsOneWidget);
  });

  testWidgets('save error from repository keeps reserve dialog open', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    (getIt<BusinessCatalogInventoryReservationRepository>()
            as InMemoryBusinessCatalogInventoryReservationRepository)
        .failNextOperation = true;

    await tester.pumpWidget(_app(const BusinessCatalogInventoryReservationsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reserve stock'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Fresh bread').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '1');
    await tester.enterText(find.byType(TextField).at(1), '60');
    await tester.tap(find.text('Reserve'));
    await tester.pumpAndSettle();

    expect(find.text('Create demo reservation'), findsOneWidget);
    expect(find.text('Could not save reservation. Try again.'), findsOneWidget);
  });
}
