import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_option_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_catalog_product_option_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_option_repository.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/catalog_product_options_section.dart';

Widget _app(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

Finder _dialogFields() {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextFormField),
  );
}

Future<void> _openNewGroupDialog(WidgetTester tester) async {
  final add = find.text('Add option group');
  await tester.scrollUntilVisible(add, 120);
  await tester.tap(add);
  await tester.pumpAndSettle();
}

Future<void> _tapDialogCancel(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AlertDialog).first,
      matching: find.text('Cancel'),
    ),
  );
  await tester.pumpAndSettle();
}

void _setLargeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _tapDialogSave(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AlertDialog).first,
      matching: find.text('Save'),
    ),
  );
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

  testWidgets('new option group discard keep editing preserves draft', (tester) async {
    _setLargeSurface(tester);
    await tester.pumpWidget(
      _app(
        const CatalogProductOptionsSection(
          productId: kDemoCatalogProductPlovId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _openNewGroupDialog(tester);

    expect(find.text('New option group'), findsOneWidget);
    await tester.enterText(_dialogFields().at(2), 'Spice level draft');
    await _tapDialogCancel(tester);

    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();

    expect(find.text('New option group'), findsOneWidget);
    expect(find.text('Spice level draft'), findsOneWidget);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('new option group discard confirm does not persist to repository', (tester) async {
    _setLargeSurface(tester);
    final repo = getIt<BusinessCatalogProductOptionRepository>();
    expect(repo.groupsForProduct(kDemoCatalogProductPlovId), isEmpty);

    await tester.pumpWidget(
      _app(
        const CatalogProductOptionsSection(
          productId: kDemoCatalogProductPlovId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _openNewGroupDialog(tester);

    await tester.enterText(_dialogFields().at(2), 'Lost group');
    await _tapDialogCancel(tester);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.text('New option group'), findsNothing);
    expect(repo.groupsForProduct(kDemoCatalogProductPlovId), isEmpty);
  });

  testWidgets('edit option group discard keeps saved repository values', (tester) async {
    _setLargeSurface(tester);
    final repo = getIt<BusinessCatalogProductOptionRepository>();

    await tester.pumpWidget(
      _app(
        const CatalogProductOptionsSection(
          productId: kDemoCatalogProductBreadId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit option group'), findsOneWidget);

    await tester.enterText(_dialogFields().at(2), 'Mutated bread size');
    await _tapDialogCancel(tester);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.text('Edit option group'), findsNothing);
    expect(find.text('Bread size'), findsOneWidget);
    final group = repo.findGroupById(kDemoCatalogOptionGroupBreadSizeId)!;
    expect(group.localized.nameEn, 'Bread size');
  });

  testWidgets('edit option discard keeps saved option name', (tester) async {
    _setLargeSurface(tester);
    final repo = getIt<BusinessCatalogProductOptionRepository>();

    await tester.pumpWidget(
      _app(
        const CatalogProductOptionsSection(
          productId: kDemoCatalogProductBreadId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Edit option'), findsOneWidget);

    await tester.enterText(_dialogFields().at(2), 'Mutated small');
    await _tapDialogCancel(tester);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.text('Small'), findsOneWidget);
    final option = repo.findOptionById('demo-catalog-option-bread-small')!;
    expect(option.localized.nameEn, 'Small');
  });

  testWidgets('option group save failure keeps dialog open for retry', (tester) async {
    _setLargeSurface(tester);
    final repo = getIt<BusinessCatalogProductOptionRepository>()
        as InMemoryBusinessCatalogProductOptionRepository;
    repo.failNextSave = true;

    await tester.pumpWidget(
      _app(
        const CatalogProductOptionsSection(
          productId: kDemoCatalogProductPlovId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _openNewGroupDialog(tester);

    await tester.enterText(_dialogFields().at(2), 'Retry group');
    await _tapDialogSave(tester);

    expect(find.text('Could not save option group.'), findsOneWidget);
    expect(find.text('New option group'), findsOneWidget);
    expect(find.text('Retry group'), findsOneWidget);
    expect(repo.groupsForProduct(kDemoCatalogProductPlovId), isEmpty);

    await _tapDialogSave(tester);
    expect(find.text('New option group'), findsNothing);
    expect(repo.groupsForProduct(kDemoCatalogProductPlovId).length, 1);
    expect(
      repo.groupsForProduct(kDemoCatalogProductPlovId).single.localized.nameEn,
      'Retry group',
    );
  });

  testWidgets('option save failure keeps dialog open then succeeds on retry', (tester) async {
    _setLargeSurface(tester);
    final repo = getIt<BusinessCatalogProductOptionRepository>()
        as InMemoryBusinessCatalogProductOptionRepository;
    repo.failNextSave = true;

    await tester.pumpWidget(
      _app(
        const CatalogProductOptionsSection(
          productId: kDemoCatalogProductBreadId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add option'));
    await tester.pumpAndSettle();
    expect(find.text('New option'), findsOneWidget);

    await tester.enterText(_dialogFields().at(2), 'Extra crust');
    await _tapDialogSave(tester);

    expect(find.text('Could not save option.'), findsOneWidget);
    expect(find.text('New option'), findsOneWidget);
    final before = repo.findGroupById(kDemoCatalogOptionGroupBreadSizeId)!.options.length;

    await _tapDialogSave(tester);
    expect(find.text('New option'), findsNothing);
    final after = repo.findGroupById(kDemoCatalogOptionGroupBreadSizeId)!.options.length;
    expect(after, before + 1);
    expect(
      repo.findGroupById(kDemoCatalogOptionGroupBreadSizeId)!.options.last.localized.nameEn,
      'Extra crust',
    );
  });
}
