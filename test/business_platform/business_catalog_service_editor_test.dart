import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_service_repository.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_service_editor_page.dart';

Widget _editorRouter(Widget editor, {String initialLocation = '/edit'}) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    routerConfig: GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => context.push('/edit'),
                child: const Text('Open editor'),
              ),
            ),
          ),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => editor,
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _tapWhenVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(finder);
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

  testWidgets('cancel without edits does not show discard dialog', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _editorRouter(
        const BusinessCatalogServiceEditorPage(
          serviceId: kDemoCatalogServicePackingId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapWhenVisible(tester, find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Open editor'), findsOneWidget);
  });

  testWidgets('cancel with dirty form shows discard dialog', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _editorRouter(
        const BusinessCatalogServiceEditorPage(
          serviceId: kDemoCatalogServicePackingId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Dirty service name');
    await _tapWhenVisible(tester, find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
  });

  testWidgets('keep editing preserves form values', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _editorRouter(
        const BusinessCatalogServiceEditorPage(
          serviceId: kDemoCatalogServicePackingId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Still editing');
    await _tapWhenVisible(tester, find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();

    expect(find.text('Still editing'), findsOneWidget);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('confirm discard closes editor', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _editorRouter(
        const BusinessCatalogServiceEditorPage(
          serviceId: kDemoCatalogServicePackingId,
        ),
        initialLocation: '/',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Discard me');
    await _tapWhenVisible(tester, find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.text('Open editor'), findsOneWidget);
    expect(find.text('Edit service'), findsNothing);
  });

  testWidgets('save failure keeps form values', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = getIt<BusinessCatalogServiceRepository>()
        as InMemoryBusinessCatalogServiceRepository;
    repo.failNextSave = true;

    await tester.pumpWidget(
      _editorRouter(
        const BusinessCatalogServiceEditorPage(
          serviceId: kDemoCatalogServicePackingId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Failed save name');
    await _tapWhenVisible(tester, find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save. Your entries are still on screen.'), findsOneWidget);
    expect(find.text('Failed save name'), findsOneWidget);
  });
}
