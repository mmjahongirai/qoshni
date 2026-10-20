import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_delivery_task_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_delivery_task_page.dart';

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

  testWidgets('shows disclaimer and seed references', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessDeliveryTaskPage()));
    await tester.pumpAndSettle();

    expect(find.text('Delivery tasks'), findsOneWidget);
    expect(
      find.text(
        'Demo delivery tasks only — not connected to live orders, couriers or tracking.',
      ),
      findsOneWidget,
    );
    expect(find.text('DT-001'), findsOneWidget);
  });

  testWidgets('transition action updates created task', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessDeliveryTaskPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark ready for pickup').first);
    await tester.pumpAndSettle();

    final repo = getIt<BusinessDeliveryTaskRepository>()
        as InMemoryBusinessDeliveryTaskRepository;
    final task = repo.findById(kDemoDeliveryTaskCreatedId)!;
    expect(task.status, BusinessDeliveryTaskStatus.readyForPickup);
  });

  testWidgets('save error shows banner and keeps status', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    (getIt<BusinessDeliveryTaskRepository>()
            as InMemoryBusinessDeliveryTaskRepository)
        .failNextSave = true;

    await tester.pumpWidget(_app(const BusinessDeliveryTaskPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark ready for pickup').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not save'), findsOneWidget);
    final repo = getIt<BusinessDeliveryTaskRepository>()
        as InMemoryBusinessDeliveryTaskRepository;
    expect(
      repo.findById(kDemoDeliveryTaskCreatedId)!.status,
      BusinessDeliveryTaskStatus.created,
    );
  });

  testWidgets('failure reason required for mark failed', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const BusinessDeliveryTaskPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark failed').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm failure'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Enter a failure reason'), findsOneWidget);
  });
}
