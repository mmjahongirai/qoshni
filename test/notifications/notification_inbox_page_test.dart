import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/notifications/presentation/pages/notification_inbox_page.dart';

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

  testWidgets('shows demo disclaimer, seeded items, and unread styling', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const NotificationInboxPage()));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(
      find.text(
        'Demo notifications only — in-memory data; no real push, SMS or email is sent.',
      ),
      findsOneWidget,
    );
    expect(find.text('Demo order update'), findsOneWidget);
    expect(find.text('Mark as read'), findsWidgets);
  });

  testWidgets('unread filter can produce empty state after mark all read', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const NotificationInboxPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();

    expect(find.text('No notifications match your filters.'), findsOneWidget);
  });
}
