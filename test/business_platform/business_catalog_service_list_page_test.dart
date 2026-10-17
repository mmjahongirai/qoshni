import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_category_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_service_list_page.dart';

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

  testWidgets('shows all demo services by default', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogServiceListPage()));
    await tester.pumpAndSettle();

    expect(find.text('Packing service'), findsOneWidget);
    expect(find.text('Delivery (draft)'), findsOneWidget);
    expect(find.text('Showing 2 of 2'), findsOneWidget);
  });

  testWidgets('search filters services by name', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogServiceListPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Packing');
    await tester.pumpAndSettle();

    expect(find.text('Packing service'), findsOneWidget);
    expect(find.text('Delivery (draft)'), findsNothing);
    expect(find.text('Showing 1 of 2'), findsOneWidget);
  });

  testWidgets('status filter shows draft services only', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogServiceListPage()));
    await tester.pumpAndSettle();

    await _selectDropdownValue(
      tester,
      find.byType(DropdownButtonFormField<BusinessCatalogListingStatus?>),
      'Draft',
    );

    expect(find.text('Delivery (draft)'), findsOneWidget);
    expect(find.text('Packing service'), findsNothing);
  });

  testWidgets('clear filters restores full list', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogServiceListPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Packing');
    await tester.pumpAndSettle();
    expect(find.text('Clear filters'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('Packing service'), findsOneWidget);
    expect(find.text('Delivery (draft)'), findsOneWidget);
    expect(find.text('Clear filters'), findsNothing);
  });

  testWidgets('no matches shows empty state', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogServiceListPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzz-no-match');
    await tester.pumpAndSettle();

    expect(find.text('No services match your filters.'), findsOneWidget);
    expect(find.text('Showing 0 of 2'), findsOneWidget);
  });

  testWidgets('category filter limits services', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        BusinessCatalogServiceListPage(
          initialCategoryId: kDemoCatalogCategoryInStoreServicesId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Packing service'), findsOneWidget);
    expect(find.text('Delivery (draft)'), findsOneWidget);
    expect(find.text('Showing 2 of 2'), findsOneWidget);
  });
}
