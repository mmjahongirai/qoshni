import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_coordinator.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/features/home/presentation/pages/search_page.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_service.dart';
import 'package:qoshni/features/search/data/remote_qoshni_search_data_source.dart';
import 'package:qoshni/features/search/domain/qoshni_search_page_result.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_understanding.dart';
import 'package:qoshni/features/search/domain/qoshni_search_request.dart';

class _StubSearchExecutionCoordinator extends QoshniSearchExecutionCoordinator {
  _StubSearchExecutionCoordinator({
    required QoshniSearchPageResult result,
    required super.config,
    required super.demoExecutionService,
    required super.remoteDataSource,
    required super.authController,
  }) : _result = result;

  final QoshniSearchPageResult _result;

  @override
  Future<QoshniSearchPageResult> execute({
    required QoshniSearchRequest request,
    required List<SearchCatalogEntry> catalog,
    QoshniSearchQueryUnderstanding? understanding,
  }) async {
    return _result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppConfig remoteConfig;

  setUp(() async {
    remoteConfig = AppConfig(
      environment: AppEnvironment.development,
      appName: 'Test',
      apiBaseUrl: 'http://example.test',
      enableLogging: false,
      enableBusinessProfileSamples: true,
      enableBusinessOfferingSamples: true,
      enableRemoteSearchDiscovery: true,
    );
    await configureDependencies(remoteConfig);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpSearch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchPage(),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();
  }

  void replaceCoordinator(QoshniSearchPageResult result) {
    final demo = getIt<QoshniSearchExecutionService>();
    final remote = getIt<RemoteQoshniSearchDataSource>();
    final auth = getIt<AuthController>();
    if (getIt.isRegistered<QoshniSearchExecutionCoordinator>()) {
      getIt.unregister<QoshniSearchExecutionCoordinator>();
    }
    getIt.registerSingleton<QoshniSearchExecutionCoordinator>(
      _StubSearchExecutionCoordinator(
        result: result,
        config: remoteConfig,
        demoExecutionService: demo,
        remoteDataSource: remote,
        authController: auth,
      ),
    );
  }

  testWidgets('remoteUnauthorized shows dedicated empty state', (tester) async {
    replaceCoordinator(
      const QoshniSearchPageResult(
        status: QoshniSearchExecutionStatus.remoteUnauthorized,
        items: [],
      ),
    );
    await pumpSearch(tester);
    await tester.enterText(find.byType(TextField), 'apteka');
    await tester.pumpAndSettle();

    expect(find.text('Sign in to search'), findsOneWidget);
    expect(find.text('No results found'), findsNothing);
  });

  testWidgets('remoteUnavailable shows dedicated empty state', (tester) async {
    replaceCoordinator(
      const QoshniSearchPageResult(
        status: QoshniSearchExecutionStatus.remoteUnavailable,
        items: [],
      ),
    );
    await pumpSearch(tester);
    await tester.enterText(find.byType(TextField), 'apteka');
    await tester.pumpAndSettle();

    expect(find.text('Search is temporarily unavailable'), findsOneWidget);
    expect(find.text('No results found'), findsNothing);
  });

  testWidgets('successful empty search keeps standard empty state', (tester) async {
    replaceCoordinator(
      const QoshniSearchPageResult(
        status: QoshniSearchExecutionStatus.success,
        items: [],
      ),
    );
    await pumpSearch(tester);
    await tester.enterText(find.byType(TextField), 'zzzznotfound');
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
    expect(find.text('Sign in to search'), findsNothing);
    expect(find.text('Search is temporarily unavailable'), findsNothing);
  });
}
