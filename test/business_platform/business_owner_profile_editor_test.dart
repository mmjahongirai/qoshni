import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_owner_profile_controller.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_owner_profile_editor_page.dart';

Widget _editorTestApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  );
}

Finder _textFormFieldAt(int index) {
  return find.byType(TextFormField).at(index);
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
    getIt.unregister<BusinessOwnerProfileRepository>();
    getIt.registerLazySingleton<BusinessOwnerProfileRepository>(
      InMemoryBusinessOwnerProfileRepository.new,
    );
    getIt.unregister<BusinessOwnerProfileController>();
    getIt.registerLazySingleton<BusinessOwnerProfileController>(
      () => BusinessOwnerProfileController(getIt<BusinessOwnerProfileRepository>()),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('invalid submit shows validation errors', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _editorTestApp(const BusinessOwnerProfileEditorPage()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormFieldAt(0), '');
    await _tapWhenVisible(tester, find.text('Save changes'));

    expect(find.text('Enter the legal business name'), findsOneWidget);
  });

  testWidgets('save failure keeps edited display name in form', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = getIt<BusinessOwnerProfileRepository>()
        as InMemoryBusinessOwnerProfileRepository;
    repo.failNextSave = true;

    await tester.pumpWidget(
      _editorTestApp(const BusinessOwnerProfileEditorPage()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormFieldAt(1), 'Persisted edit');
    await _tapWhenVisible(tester, find.text('Save changes'));

    expect(
      find.text('Could not save. Your edits are still in the form.'),
      findsOneWidget,
    );
    expect(find.text('Persisted edit'), findsOneWidget);
  });

  testWidgets('cancel with dirty form asks for confirmation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _editorTestApp(const BusinessOwnerProfileEditorPage()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_textFormFieldAt(1), 'Dirty');
    await _tapWhenVisible(tester, find.text('Cancel'));

    expect(find.text('Discard changes?'), findsOneWidget);
  });
}
