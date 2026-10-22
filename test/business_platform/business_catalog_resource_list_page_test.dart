import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_resource_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_resource_repository.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_resource_list_page.dart';

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

  testWidgets('shows demo resources and disclaimer', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessCatalogResourceListPage()));
    await tester.pumpAndSettle();

    expect(find.text('Resources'), findsOneWidget);
    expect(find.textContaining('not connected to live bookings'), findsOneWidget);
    expect(find.text('Demo bakery oven'), findsOneWidget);
  });

  testWidgets('save error keeps editor dialog open', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    (getIt<BusinessCatalogResourceRepository>()
            as InMemoryBusinessCatalogResourceRepository)
        .failNextSave = true;

    await tester.pumpWidget(_app(const BusinessCatalogResourceListPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add resource'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demo — Tashkent Center').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Test resource');
    await tester.enterText(find.byType(TextField).at(2), '2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('New resource'), findsOneWidget);
    expect(find.text('Could not save. Check your entries.'), findsOneWidget);
  });
}
