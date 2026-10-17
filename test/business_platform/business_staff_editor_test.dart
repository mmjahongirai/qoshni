import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_staff_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_branch_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_staff_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_staff_controller.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_staff_editor_page.dart';

Widget _staffEditorApp(Widget home) {
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
    getIt.unregister<BusinessStaffRepository>();
    getIt.registerLazySingleton<BusinessStaffRepository>(
      () => InMemoryBusinessStaffRepository(
        getIt<BusinessOwnerProfileRepository>(),
        getIt<BusinessBranchRepository>(),
      ),
    );
    getIt.unregister<BusinessStaffController>();
    getIt.registerLazySingleton<BusinessStaffController>(
      () => BusinessStaffController(getIt<BusinessStaffRepository>()),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('save failure keeps edited first name', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = getIt<BusinessStaffRepository>()
        as InMemoryBusinessStaffRepository;
    repo.failNextSave = true;

    await tester.pumpWidget(
      _staffEditorApp(
        const BusinessStaffEditorPage(staffId: 'demo-staff-branch-manager'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Edited');
    await _tapWhenVisible(tester, find.text('Save staff member'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not save. Your edits are still in the form.'),
      findsOneWidget,
    );
    expect(find.text('Edited'), findsOneWidget);
  });
}
