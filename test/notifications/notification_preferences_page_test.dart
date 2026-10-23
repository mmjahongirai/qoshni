import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/presentation/pages/notification_preferences_page.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_preference_controller.dart';

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

  testWidgets('shows demo disclaimer and category toggles', (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const NotificationPreferencesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Notification preferences'), findsOneWidget);
    expect(
      find.text(
        'Demo notification preferences only — settings are in memory; no real push, SMS or email delivery occurs.',
      ),
      findsOneWidget,
    );
    expect(find.text('Orders'), findsWidgets);
  });

  testWidgets('preference toggle updates controller and preview section is shown', (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = getIt<QoshniNotificationPreferenceController>();

    await tester.pumpWidget(_app(const NotificationPreferencesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Hypothetical delivery preview'), findsOneWidget);

    final ordersSwitch = find.widgetWithText(
      SwitchListTile,
      'Orders',
    );
    expect(ordersSwitch, findsOneWidget);
    await tester.tap(ordersSwitch);
    await tester.pumpAndSettle();

    expect(
      controller.preferences.isCategoryEnabled(QoshniNotificationCategory.orders),
      isFalse,
    );

    final preview = controller.evaluateHypothetical(
      scenario: const QoshniNotificationEligibilityInput(
        category: QoshniNotificationCategory.orders,
        channel: QoshniNotificationChannel.inApp,
        priority: QoshniNotificationPriority.normal,
      ),
      evaluationLocalDateTime: DateTime(2025, 4, 10, 23, 30),
    );
    expect(
      preview.reason,
      QoshniNotificationEligibilityReason.suppressedCategoryDisabled,
    );
  });
}
