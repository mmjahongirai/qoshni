import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/conversations/presentation/pages/demo_conversations_list_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows disclaimer and demo conversations', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const DemoConversationsListPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsOneWidget);
    expect(
      find.text(
        'Demo conversations only — messages are stored in memory; no real customer or support communication occurs.',
      ),
      findsOneWidget,
    );
    expect(find.text('Demo Cafe'), findsWidgets);
  });
}
