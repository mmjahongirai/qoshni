import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/localization/locale_controller.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';
import 'package:qoshni/features/notifications/presentation/pages/notification_templates_page.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_template_controller.dart';

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

  testWidgets('shows disclaimer and filters templates', (tester) async {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const NotificationTemplatesPage()));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Demo notification templates only — previews are synthetic; no real messages are sent.',
      ),
      findsOneWidget,
    );
    expect(find.text('demo.order.confirmation'), findsWidgets);

    getIt<QoshniNotificationTemplateController>().setStatusFilter(
      QoshniNotificationTemplateStatus.archived,
    );
    await tester.pumpAndSettle();
    expect(find.text('demo.archived.promotion'), findsOneWidget);
  });
}
