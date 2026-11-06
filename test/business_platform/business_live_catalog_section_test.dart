import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/application/business_catalog_integration_controller.dart';
import 'package:qoshni/features/business_platform/application/business_live_catalog_controller.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog_repository.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_live_catalog_section.dart';

const _applicationId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const _itemId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
const _profileId = 'sample-rental-tools';
const _demoTitle = 'Fresh bread';

const _configured = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: 'https://api.example.test',
  enableLogging: false,
  enableBusinessProfileSamples: true,
  enableBusinessOfferingSamples: true,
  enableRemoteSearchDiscovery: false,
);

class _Token implements AccessTokenReader {
  @override
  String? get accessToken => 'session-token';
}

class _Applications implements VerifiedApplicationLookup {
  _Applications(this.ids);

  final List<String> ids;

  @override
  Future<List<String>> verifiedApplicationIds({
    required String accessToken,
  }) async {
    return ids;
  }
}

class _Catalog implements AuthoritativeCatalogRepository {
  int listCalls = 0;
  int createCalls = 0;
  int priceCalls = 0;
  int statusCalls = 0;
  int inventoryCalls = 0;
  String? lastApplicationId;
  int? lastPrice;
  String? lastStableId;
  String? lastTitle;
  AuthoritativeOfferingKind? lastKind;
  AuthoritativeCatalogItemStatus? lastStatus;
  bool priceIncludedRevision = false;
  AuthoritativeCatalogFailure? listFailure;
  AuthoritativeCatalogFailure? priceFailure;
  AuthoritativeCatalogFailure? statusFailure;
  List<AuthoritativeCatalogItem> listResult = const [];
  AuthoritativeCatalogItem? created;
  AuthoritativeCatalogItem? priced;
  AuthoritativeCatalogItem? statusUpdated;
  Completer<List<AuthoritativeCatalogItem>>? listGate;

  @override
  Future<List<AuthoritativeCatalogItem>> listItems({
    required String accessToken,
    required String applicationId,
  }) {
    listCalls += 1;
    lastApplicationId = applicationId;
    final gate = listGate;
    if (gate != null) {
      return gate.future;
    }
    final failure = listFailure;
    if (failure != null) {
      throw failure;
    }
    return Future.value(listResult);
  }

  @override
  Future<AuthoritativeCatalogItem> createItem({
    required String accessToken,
    required String applicationId,
    required String catalogItemStableId,
    required AuthoritativeOfferingKind offeringKind,
    required int unitPriceMinor,
    required String title,
  }) async {
    createCalls += 1;
    lastApplicationId = applicationId;
    lastStableId = catalogItemStableId;
    lastKind = offeringKind;
    lastTitle = title;
    lastPrice = unitPriceMinor;
    return created ?? (throw StateError('missing create response'));
  }

  @override
  Future<AuthoritativeCatalogItem> updatePrice({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int unitPriceMinor,
  }) async {
    priceCalls += 1;
    lastApplicationId = applicationId;
    lastPrice = unitPriceMinor;
    final failure = priceFailure;
    if (failure != null) {
      throw failure;
    }
    return priced ?? (throw StateError('missing price response'));
  }

  @override
  Future<AuthoritativeCatalogItem> updateStatus({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required AuthoritativeCatalogItemStatus status,
  }) async {
    statusCalls += 1;
    lastApplicationId = applicationId;
    lastStatus = status;
    final failure = statusFailure;
    if (failure != null) {
      throw failure;
    }
    return statusUpdated ?? (throw StateError('missing status response'));
  }

  @override
  Future<AuthoritativeCatalogItem> getItem({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) {
    throw StateError('detail is not used by the catalog section');
  }

  @override
  Future<AuthoritativeInventoryBalance> openInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) {
    inventoryCalls += 1;
    throw StateError('inventory is outside WP4-B');
  }

  @override
  Future<AuthoritativeInventoryBalance> replenishInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantity,
    required String reason,
  }) {
    inventoryCalls += 1;
    throw StateError('inventory is outside WP4-B');
  }

  @override
  Future<AuthoritativeInventoryBalance> correctInventoryCount({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) {
    inventoryCalls += 1;
    throw StateError('inventory is outside WP4-B');
  }

  @override
  Future<AuthoritativeInventoryBalance> getInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) {
    inventoryCalls += 1;
    lastApplicationId = applicationId;
    throw const AuthoritativeCatalogFailure(
      code: AuthoritativeCatalogErrorCode.conflict,
      message: 'Inventory has not been opened.',
      serverCode: 'inventory_not_open',
    );
  }

  @override
  Future<List<AuthoritativeInventoryEvent>> listInventoryEvents({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) async {
    inventoryCalls += 1;
    lastApplicationId = applicationId;
    return const [];
  }
}

AuthoritativeCatalogItem _item({
  String title = 'Server bread',
  int price = 8000,
  int revision = 1,
  AuthoritativeCatalogItemStatus status = AuthoritativeCatalogItemStatus.active,
  String stableId = 'bread',
}) {
  return AuthoritativeCatalogItem(
    catalogItemId: _itemId,
    businessApplicationId: _applicationId,
    catalogItemStableId: stableId,
    offeringKind: AuthoritativeOfferingKind.product,
    title: title,
    unitPriceMinor: price,
    currencyCode: 'UZS',
    pricingRevision: revision,
    status: status,
    createdAt: DateTime.utc(2026, 11, 4),
    updatedAt: DateTime.utc(2026, 11, 4),
  );
}

BusinessLiveCatalogController _controller(_Catalog catalog) {
  return BusinessLiveCatalogController(
    BusinessCatalogIntegrationController(
      config: _configured,
      accessTokenReader: _Token(),
      applications: _Applications(const [_applicationId]),
      catalog: catalog,
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  BusinessLiveCatalogController catalog, {
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(900, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: BusinessLiveCatalogSection(catalog: catalog),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('catalog list uses the live repository', (tester) async {
    final repository = _Catalog()..listResult = [_item()];
    await _pump(tester, _controller(repository));

    expect(repository.listCalls, 1);
    expect(repository.lastApplicationId, _applicationId);
    expect(repository.lastApplicationId, isNot(_profileId));
    expect(find.text('Server bread'), findsOneWidget);
    expect(find.text('Product'), findsOneWidget);
    expect(find.textContaining('8 000 UZS'), findsOneWidget);
    expect(find.textContaining('Currency: UZS'), findsOneWidget);
    expect(find.textContaining('Pricing revision 1'), findsOneWidget);
    expect(find.textContaining('Stable ID: bread'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text(_demoTitle), findsNothing);
    expect(repository.inventoryCalls, greaterThan(0));
    expect(repository.lastApplicationId, _applicationId);
  });

  testWidgets('empty catalog', (tester) async {
    final repository = _Catalog();
    await _pump(tester, _controller(repository));

    expect(repository.listCalls, 1);
    expect(find.byKey(const Key('live-catalog-empty')), findsOneWidget);
    expect(find.text('The live catalog is empty'), findsOneWidget);
    expect(find.text(_demoTitle), findsNothing);
    expect(find.byKey(const Key('live-catalog-add')), findsOneWidget);
  });

  testWidgets('catalog loading', (tester) async {
    final gate = Completer<List<AuthoritativeCatalogItem>>();
    final repository = _Catalog()..listGate = gate;
    await _pump(tester, _controller(repository), settle: false);
    for (var attempt = 0; attempt < 8; attempt++) {
      await tester.pump();
      if (find.byKey(const Key('live-catalog-loading')).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.byKey(const Key('live-catalog-loading')), findsOneWidget);
    expect(find.text(_demoTitle), findsNothing);
    expect(repository.listCalls, 1);
    gate.complete([_item()]);
    await tester.pumpAndSettle();
    expect(find.text('Server bread'), findsOneWidget);
    expect(find.byKey(const Key('live-catalog-loading')), findsNothing);
  });

  testWidgets('create item keeps the server response', (tester) async {
    final repository = _Catalog()
      ..created = _item(title: 'Server Non', price: 15000, stableId: 'non');
    await _pump(tester, _controller(repository));

    await tester.tap(find.byKey(const Key('live-catalog-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('live-catalog-stable-id')),
      'non',
    );
    await tester.enterText(
      find.byKey(const Key('live-catalog-title')),
      'Typed Non',
    );
    await tester.enterText(
      find.byKey(const Key('live-catalog-price-field')),
      '15000',
    );
    await tester.tap(find.byKey(const Key('live-catalog-save')));
    await tester.pumpAndSettle();

    expect(repository.createCalls, 1);
    expect(repository.lastApplicationId, _applicationId);
    expect(repository.lastStableId, 'non');
    expect(repository.lastKind, AuthoritativeOfferingKind.product);
    expect(repository.lastTitle, 'Typed Non');
    expect(repository.lastPrice, 15000);
    expect(find.text('Server Non'), findsOneWidget);
    expect(find.text('Typed Non'), findsNothing);
    expect(find.textContaining('15 000 UZS'), findsOneWidget);
    expect(find.textContaining('Pricing revision 1'), findsOneWidget);
    expect(find.text(_demoTitle), findsNothing);
    expect(repository.lastApplicationId, _applicationId);
  });

  testWidgets('price update stores the server revision', (tester) async {
    final repository = _Catalog()
      ..listResult = [_item(price: 8000, revision: 1)]
      ..priced = _item(price: 12000, revision: 7);
    await _pump(tester, _controller(repository));

    await tester.tap(find.byKey(Key('live-catalog-price-$_itemId')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('live-catalog-price-field')),
      '12000',
    );
    await tester.tap(find.byKey(const Key('live-catalog-save')));
    await tester.pumpAndSettle();

    expect(repository.priceCalls, 1);
    expect(repository.lastPrice, 12000);
    expect(repository.priceIncludedRevision, isFalse);
    expect(repository.lastApplicationId, _applicationId);
    expect(find.textContaining('12 000 UZS'), findsOneWidget);
    expect(find.textContaining('8 000'), findsNothing);
    expect(find.textContaining('Pricing revision 7'), findsOneWidget);
    expect(find.textContaining('Pricing revision 2'), findsNothing);
  });

  testWidgets('status update uses the server item', (tester) async {
    final repository = _Catalog()
      ..listResult = [_item()]
      ..statusUpdated = _item(
        status: AuthoritativeCatalogItemStatus.archived,
        revision: 1,
      );
    await _pump(tester, _controller(repository));

    await tester.tap(find.byKey(Key('live-catalog-status-$_itemId-archived')));
    await tester.pumpAndSettle();

    expect(repository.statusCalls, 1);
    expect(repository.lastStatus, AuthoritativeCatalogItemStatus.archived);
    expect(repository.lastApplicationId, _applicationId);
    final archived = tester.widget<ChoiceChip>(
      find.byKey(Key('live-catalog-status-$_itemId-archived')),
    );
    final active = tester.widget<ChoiceChip>(
      find.byKey(Key('live-catalog-status-$_itemId-active')),
    );
    expect(archived.selected, isTrue);
    expect(active.selected, isFalse);
    expect(find.textContaining('Pricing revision 1'), findsOneWidget);
    expect(find.textContaining('8 000 UZS'), findsOneWidget);
  });

  testWidgets('401 shows a session error and no demo item', (tester) async {
    final repository = _Catalog()
      ..listFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.authenticationRequired,
        message: 'Sign in.',
      );
    await _pump(tester, _controller(repository));

    expect(find.textContaining('session ended'), findsOneWidget);
    expect(find.text(_demoTitle), findsNothing);
    expect(find.text('Server bread'), findsNothing);
    expect(find.byKey(const Key('live-catalog-add')), findsNothing);
  });

  testWidgets('403 shows a permission error and no demo item', (tester) async {
    final repository = _Catalog()
      ..listFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.forbidden,
        message: 'Denied.',
      );
    await _pump(tester, _controller(repository));

    expect(find.textContaining('not verified'), findsOneWidget);
    expect(find.text(_demoTitle), findsNothing);
    expect(find.byKey(const Key('live-catalog-add')), findsNothing);
  });

  testWidgets('404 shows not found and no demo item', (tester) async {
    final repository = _Catalog()
      ..listFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.notFound,
        message: 'Missing.',
      );
    await _pump(tester, _controller(repository));

    expect(find.textContaining('was not found'), findsOneWidget);
    expect(find.text(_demoTitle), findsNothing);
    expect(find.byKey(const Key('live-catalog-add')), findsNothing);
  });

  testWidgets('409 keeps the previous price and shows the server code', (
    tester,
  ) async {
    final repository = _Catalog()
      ..listResult = [_item(price: 8000, revision: 3)]
      ..priceFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.conflict,
        message: 'Stock conflict.',
        serverCode: 'below_reserved',
      );
    await _pump(tester, _controller(repository));

    await tester.tap(find.byKey(Key('live-catalog-price-$_itemId')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('live-catalog-price-field')),
      '1',
    );
    await tester.tap(find.byKey(const Key('live-catalog-save')));
    await tester.pumpAndSettle();

    expect(repository.priceCalls, 1);
    expect(repository.lastPrice, 1);
    expect(find.textContaining('below_reserved'), findsWidgets);
    expect(find.textContaining('8 000 UZS'), findsOneWidget);
    expect(find.textContaining('Pricing revision 3'), findsWidgets);
    expect(find.textContaining('1 UZS'), findsNothing);
    expect(find.text(_demoTitle), findsNothing);
  });

  testWidgets('503 shows catalog unavailable and does not restore demo items', (
    tester,
  ) async {
    const demoOfferings = [_demoTitle, 'Sample rental tools'];
    final repository = _Catalog()
      ..listFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.catalogUnavailable,
        message: 'Off.',
      );
    await _pump(tester, _controller(repository));

    expect(find.textContaining('not available on the server'), findsOneWidget);
    for (final demo in demoOfferings) {
      expect(find.text(demo), findsNothing);
    }
    expect(find.byKey(const Key('live-catalog-add')), findsNothing);
    expect(repository.inventoryCalls, 0);
  });

  test('invalid application id does not send a catalog request', () async {
    final repository = _Catalog();
    final integration = BusinessCatalogIntegrationController(
      config: _configured,
      accessTokenReader: _Token(),
      applications: _Applications(const [_applicationId]),
      catalog: repository,
    );
    integration.phase = BusinessCatalogLinkPhase.ready;
    integration.applicationId = _profileId;
    final catalog = BusinessLiveCatalogController(integration);

    await catalog.load();
    expect(await integration.listItems(), isNull);

    expect(repository.listCalls, 0);
    expect(
      catalog.failure?.code,
      AuthoritativeCatalogErrorCode.invalidApplicationId,
    );
    expect(catalog.items, isEmpty);
  });

  test('negative price is rejected before a request', () async {
    final repository = _Catalog();
    final catalog = _controller(repository);
    await catalog.open();

    final saved = await catalog.createItem(
      catalogItemStableId: 'bread',
      offeringKind: AuthoritativeOfferingKind.product,
      title: 'Bread',
      unitPriceMinor: -1,
    );

    expect(saved, isFalse);
    expect(repository.createCalls, 0);
    expect(catalog.items, isEmpty);
  });
}
