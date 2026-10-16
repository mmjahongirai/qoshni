import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_branch_editor_page.dart';

Widget _branchEditorApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
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
    getIt.unregister<BusinessBranchRepository>();
    getIt.registerLazySingleton<BusinessBranchRepository>(
      () => InMemoryBusinessBranchRepository(
        getIt<BusinessOwnerProfileRepository>(),
      ),
    );
    getIt.unregister<BusinessBranchController>();
    getIt.registerLazySingleton<BusinessBranchController>(
      () => BusinessBranchController(getIt<BusinessBranchRepository>()),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('invalid submit blocks empty branch name', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _branchEditorApp(const BusinessBranchEditorPage()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '');
    await _tapWhenVisible(tester, find.text('Save branch'));
    expect(find.text('Enter a branch name'), findsOneWidget);
  });

  testWidgets('save failure keeps edited branch name', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = getIt<BusinessBranchRepository>()
        as InMemoryBusinessBranchRepository;
    repo.failNextSave = true;

    await tester.pumpWidget(
      _branchEditorApp(
        const BusinessBranchEditorPage(
          branchId: 'demo-branch-tashkent-center',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Edited name');
    await _tapWhenVisible(tester, find.text('Save branch'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not save. Your edits are still in the form.'),
      findsOneWidget,
    );
    expect(find.text('Edited name'), findsOneWidget);
  });

  testWidgets('cancel with dirty form asks for confirmation', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _branchEditorApp(
        const BusinessBranchEditorPage(
          branchId: 'demo-branch-tashkent-center',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Dirty');
    await _tapWhenVisible(tester, find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
  });
}
