import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/routing/app_router.dart';
import 'package:qoshni/routing/route_paths.dart';

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

  Future<void> expectRouteResolves(
    WidgetTester tester,
    String path,
  ) async {
    final router = getIt<AppRouter>().router;
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    router.go(path);
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  }

  testWidgets('governance audit route resolves', (tester) async {
    await expectRouteResolves(tester, RoutePaths.platformAdminGovernanceAudit);
  });

  testWidgets('governance configuration route resolves', (tester) async {
    await expectRouteResolves(
      tester,
      RoutePaths.platformAdminGovernanceConfiguration,
    );
  });

  testWidgets('governance approvals route resolves', (tester) async {
    await expectRouteResolves(
      tester,
      RoutePaths.platformAdminGovernanceApprovals,
    );
  });

  testWidgets('governance operations route resolves', (tester) async {
    await expectRouteResolves(
      tester,
      RoutePaths.platformAdminGovernanceOperations,
    );
  });
}
