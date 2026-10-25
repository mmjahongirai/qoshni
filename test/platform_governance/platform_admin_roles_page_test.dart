import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/platform_governance/presentation/pages/platform_admin_roles_page.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';

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

  testWidgets('shows disclaimer and demo admin identities', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const PlatformAdminRolesPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Demo admin governance only'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Demo Platform Viewer'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Demo Platform Viewer'), findsOneWidget);
  });

  test('authorization preview denies suspended admin via controller', () {
    final controller = getIt<QoshniPlatformGovernanceController>();
    controller.selectAdmin('admin-demo-suspended');
    final decision = controller.previewAuthorizationForSelectedAdmin();
    expect(decision, isNotNull);
    expect(decision!.isAllowed, isFalse);
    expect(decision.reason,
        QoshniPlatformAuthorizationReason.deniedAdminSuspended);
  });
}
