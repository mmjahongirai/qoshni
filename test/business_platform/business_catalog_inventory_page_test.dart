import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_availability.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_inventory_page.dart';

Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  );
}

Future<void> _selectDropdownValue(
  WidgetTester tester,
  Finder dropdown,
  String label,
) async {
  await tester.scrollUntilVisible(
    dropdown,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
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

  testWidgets('shows demo inventory rows and disclaimer', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogInventoryPage()));
    await tester.pumpAndSettle();

    expect(find.text('Inventory'), findsOneWidget);
    expect(
      find.textContaining('not connected to live inventory'),
      findsWidgets,
    );
    expect(find.text('Showing 4 of 4'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('Plov'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Daily basket'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Daily basket'), findsOneWidget);
  });

  testWidgets('availability filter limits visible rows', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogInventoryPage()));
    await tester.pumpAndSettle();

    await _selectDropdownValue(
      tester,
      find.byType(DropdownButtonFormField<BusinessCatalogInventoryAvailability?>),
      'Out of stock',
    );

    expect(find.text('Fresh bread'), findsNothing);
    expect(find.text('Showing 1 of 4'), findsOneWidget);
  });

  testWidgets('adjustment dialog shows validation and stays open on error', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogInventoryPage()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Adjust stock').first,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Adjust stock').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '-100');
    await tester.enterText(find.byType(TextField).last, 'damage');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Stock adjustment'), findsOneWidget);
    expect(find.textContaining('invalid'), findsOneWidget);
  });

  testWidgets('successful adjustment closes dialog', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogInventoryPage()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Adjust stock').first,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Adjust stock').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '1');
    await tester.enterText(find.byType(TextField).last, 'Cycle count');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Stock adjustment'), findsNothing);
    expect(find.text('Stock updated for this preview session.'), findsOneWidget);
  });

  testWidgets('load error state with retry', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = getIt<BusinessCatalogInventoryRepository>()
        as InMemoryBusinessCatalogInventoryRepository;
    repo.failNextList = true;

    await tester.pumpWidget(_app(const BusinessCatalogInventoryPage()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load inventory'), findsOneWidget);
    repo.failNextList = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Fresh bread'), findsWidgets);
  });
}
