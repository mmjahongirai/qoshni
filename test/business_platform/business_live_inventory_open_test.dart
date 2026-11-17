import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/application/business_catalog_integration_controller.dart';
import 'package:qoshni/features/business_platform/application/business_live_inventory_controller.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog_repository.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_live_inventory_panel.dart';

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
  @override
  Future<List<String>> verifiedApplicationIds({
    required String accessToken,
  }) async {
    return const [_applicationId];
  }
}

class _Api implements AuthoritativeCatalogRepository {
  AuthoritativeInventoryBalance? balance;
  List<AuthoritativeInventoryEvent> events = const [];
  AuthoritativeCatalogFailure? readFailure = const AuthoritativeCatalogFailure(
    code: AuthoritativeCatalogErrorCode.conflict,
    message: 'Inventory has not been opened.',
    serverCode: liveInventoryNotOpenCode,
  );
  AuthoritativeCatalogFailure? openFailure;
  Completer<AuthoritativeInventoryBalance>? openGate;
  AuthoritativeInventoryBalance? openResult;
  final List<String> applicationIds = [];
  Map<String, Object?>? lastOpenBody;
  int readCalls = 0;
  int openCalls = 0;
  int eventCalls = 0;

  @override
  Future<AuthoritativeInventoryBalance> getInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) {
    readCalls += 1;
    applicationIds.add(applicationId);
    final failure = readFailure;
    if (failure != null) {
      throw failure;
    }
    return Future.value(balance!);
  }

  @override
  Future<AuthoritativeInventoryBalance> openInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) {
    openCalls += 1;
    applicationIds.add(applicationId);
    lastOpenBody = {'quantity_on_hand': quantityOnHand, 'reason': reason};
    final gate = openGate;
    if (gate != null) {
      return gate.future.then((value) {
        balance = value;
        readFailure = null;
        return value;
      });
    }
    final failure = openFailure;
    if (failure != null) {
      throw failure;
    }
    final saved = openResult;
    if (saved == null) {
      throw StateError('missing open response');
    }
    balance = saved;
    readFailure = null;
    return Future.value(saved);
  }

  @override
  Future<List<AuthoritativeInventoryEvent>> listInventoryEvents({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) async {
    eventCalls += 1;
    applicationIds.add(applicationId);
    return events;
  }

  @override
  Future<List<AuthoritativeCatalogItem>> listItems({
    required String accessToken,
    required String applicationId,
  }) => throw StateError('catalog list is outside this test');

  @override
  Future<AuthoritativeCatalogItem> getItem({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) => throw StateError('catalog detail is outside this test');

  @override
  Future<AuthoritativeCatalogItem> createItem({
    required String accessToken,
    required String applicationId,
    required String catalogItemStableId,
    required AuthoritativeOfferingKind offeringKind,
    required String title,
    required int unitPriceMinor,
  }) => throw StateError('catalog create is outside this test');

  @override
  Future<AuthoritativeCatalogItem> updatePrice({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int unitPriceMinor,
  }) => throw StateError('catalog price is outside this test');

  @override
  Future<AuthoritativeCatalogItem> updateStatus({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required AuthoritativeCatalogItemStatus status,
  }) => throw StateError('catalog status is outside this test');

  @override
  Future<AuthoritativeInventoryBalance> replenishInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantity,
    required String reason,
  }) => throw StateError('replenish is outside this test');

  @override
  Future<AuthoritativeInventoryBalance> correctInventoryCount({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) => throw StateError('count is outside this test');
}

AuthoritativeInventoryBalance _opened({
  int onHand = 10,
  int reserved = 4,
  int available = 7,
}) {
  return AuthoritativeInventoryBalance(
    catalogItemId: _itemId,
    quantityOnHand: onHand,
    reservedQuantity: reserved,
    availableQuantity: available,
    updatedAt: DateTime.utc(2026, 11, 4, 12, 5),
  );
}

BusinessCatalogIntegrationController _integration(_Api api) {
  final integration = BusinessCatalogIntegrationController(
    config: _configured,
    accessTokenReader: _Token(),
    applications: _Applications(),
    catalog: api,
  );
  integration.phase = BusinessCatalogLinkPhase.ready;
  integration.applicationId = _applicationId;
  return integration;
}

Future<void> _pump(
  WidgetTester tester,
  BusinessCatalogIntegrationController integration,
) async {
  tester.view.physicalSize = const Size(900, 1600);
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
          child: BusinessLiveInventoryPanel(
            integration: integration,
            catalogItemId: _itemId,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillOpen(
  WidgetTester tester, {
  String quantity = '8',
  String reason = 'initial count',
}) async {
  await tester.enterText(
    find.byKey(const Key('live-inventory-open-quantity')),
    quantity,
  );
  await tester.enterText(
    find.byKey(const Key('live-inventory-open-reason')),
    reason,
  );
  await tester.ensureVisible(find.byKey(const Key('live-inventory-open-save')));
  await tester.tap(find.byKey(const Key('live-inventory-open-save')));
  await tester.pumpAndSettle();
}

void _expectNoStockShown() {
  expect(find.textContaining('On hand:'), findsNothing);
  expect(find.text(_demoTitle), findsNothing);
}

void main() {
  testWidgets('inventory_not_open shows the open action', (tester) async {
    await _pump(tester, _integration(_Api()));

    expect(find.byKey(const Key('live-inventory-not-open')), findsOneWidget);
    expect(find.text('Open stock'), findsOneWidget);
    expect(
      find.byKey(const Key('live-inventory-replenish-save')),
      findsNothing,
    );
    _expectNoStockShown();
  });

  testWidgets('open inventory form shows quantity and reason', (tester) async {
    await _pump(tester, _integration(_Api()));

    expect(
      find.byKey(const Key('live-inventory-open-quantity')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('live-inventory-open-reason')), findsOneWidget);
    expect(find.text('Quantity on hand'), findsOneWidget);
    expect(find.text('Reason'), findsOneWidget);
  });

  testWidgets('quantity validation does not call open', (tester) async {
    final api = _Api();
    await _pump(tester, _integration(api));
    await _fillOpen(tester, quantity: '');

    expect(api.openCalls, 0);
    expect(find.textContaining('zero or more'), findsOneWidget);

    final stock = BusinessLiveInventoryController(
      integration: _integration(api),
      catalogItemId: _itemId,
    );
    expect(await stock.openStock(quantityOnHand: -1, reason: 'start'), isFalse);
    expect(api.openCalls, 0);
    expect(stock.balance, isNull);
  });

  testWidgets('reason validation does not call open', (tester) async {
    final api = _Api();
    await _pump(tester, _integration(api));
    await _fillOpen(tester, quantity: '8', reason: '   ');

    expect(api.openCalls, 0);
    expect(find.textContaining('Enter a reason'), findsOneWidget);
    _expectNoStockShown();
  });

  testWidgets('valid open sends quantity_on_hand and the onboarding id', (
    tester,
  ) async {
    final api = _Api()..openResult = _opened();
    final integration = _integration(api);
    await _pump(tester, integration);
    await _fillOpen(tester);

    expect(api.openCalls, 1);
    expect(api.lastOpenBody?['quantity_on_hand'], 8);
    expect(api.lastOpenBody?['reason'], 'initial count');
    expect(api.applicationIds, everyElement(_applicationId));
    expect(api.applicationIds, isNot(contains(_profileId)));

    integration.applicationId = _profileId;
    final blocked = BusinessLiveInventoryController(
      integration: integration,
      catalogItemId: _itemId,
    );
    expect(
      await blocked.openStock(quantityOnHand: 3, reason: 'other'),
      isFalse,
    );
    expect(api.openCalls, 1);
    expect(blocked.balance, isNull);
  });

  testWidgets('reserved_quantity is not sent', (tester) async {
    final api = _Api()..openResult = _opened();
    await _pump(tester, _integration(api));
    await _fillOpen(tester);

    expect(api.lastOpenBody?.containsKey('reserved_quantity'), isFalse);
  });

  testWidgets('pricing_revision and available_quantity are not sent', (
    tester,
  ) async {
    final api = _Api()..openResult = _opened();
    await _pump(tester, _integration(api));
    await _fillOpen(tester);

    expect(api.lastOpenBody?.containsKey('pricing_revision'), isFalse);
    expect(api.lastOpenBody?.containsKey('available_quantity'), isFalse);
    expect(api.lastOpenBody?.keys, ['quantity_on_hand', 'reason']);
  });

  testWidgets('success reloads the server balance', (tester) async {
    final api = _Api()
      ..openResult = _opened(onHand: 10, reserved: 4, available: 7);
    await _pump(tester, _integration(api));
    final readsBefore = api.readCalls;
    await _fillOpen(tester);

    expect(api.readCalls, readsBefore + 1);
    expect(find.byKey(const Key('live-inventory-not-open')), findsNothing);
    expect(find.text('On hand: 10'), findsOneWidget);
    expect(find.text('Reserved: 4'), findsOneWidget);
    expect(find.text('Available: 7'), findsOneWidget);
    expect(find.text('Available: 6'), findsNothing);
  });

  testWidgets('success reloads stock events', (tester) async {
    final api = _Api()..openResult = _opened();
    await _pump(tester, _integration(api));
    expect(find.text('No stock events have been recorded.'), findsOneWidget);
    api.events = [
      AuthoritativeInventoryEvent(
        eventId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
        catalogItemId: _itemId,
        actorUserId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        kind: AuthoritativeInventoryEventKind.opened,
        quantityDelta: 10,
        quantityOnHandAfter: 10,
        reservedQuantityAfter: 0,
        reason: 'initial count',
        createdAt: DateTime.utc(2026, 11, 4, 12, 5),
      ),
    ];
    final eventsBefore = api.eventCalls;
    await _fillOpen(tester);

    expect(api.eventCalls, eventsBefore + 1);
    expect(find.text('Opened'), findsOneWidget);
    expect(find.text('Delta: 10'), findsOneWidget);
    expect(find.text('initial count'), findsWidgets);
  });

  testWidgets('409 keeps the not-open state and the server code', (
    tester,
  ) async {
    final api = _Api()
      ..openFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.conflict,
        message: 'Inventory is already open.',
        serverCode: 'inventory_already_open',
      );
    await _pump(tester, _integration(api));
    await _fillOpen(tester);

    expect(api.openCalls, 1);
    expect(find.textContaining('inventory_already_open'), findsWidgets);
    expect(find.byKey(const Key('live-inventory-not-open')), findsOneWidget);
    _expectNoStockShown();
  });

  testWidgets('403 does not show another business stock record', (
    tester,
  ) async {
    final api = _Api()
      ..openFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.forbidden,
        message: 'Not verified.',
        serverCode: 'business_not_verified',
      );
    await _pump(tester, _integration(api));
    await _fillOpen(tester);

    expect(find.textContaining('not verified'), findsWidgets);
    _expectNoStockShown();
    expect(find.text(_demoTitle), findsNothing);
  });

  testWidgets('503 does not replace the closed stock record', (tester) async {
    final api = _Api()
      ..openFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.catalogUnavailable,
        message: 'Off.',
        serverCode: 'authoritative_inventory_unavailable',
      );
    await _pump(tester, _integration(api));
    await _fillOpen(tester);

    expect(find.textContaining('not available on the server'), findsWidgets);
    expect(find.byKey(const Key('live-inventory-not-open')), findsOneWidget);
    _expectNoStockShown();
  });

  testWidgets('duplicate open does not send a second request', (tester) async {
    final gate = Completer<AuthoritativeInventoryBalance>();
    final api = _Api()..openGate = gate;
    final integration = _integration(api);
    final stock = BusinessLiveInventoryController(
      integration: integration,
      catalogItemId: _itemId,
    );
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: BusinessLiveInventoryPanel(
            integration: integration,
            catalogItemId: _itemId,
            stock: stock,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('live-inventory-open-quantity')),
      '8',
    );
    await tester.enterText(
      find.byKey(const Key('live-inventory-open-reason')),
      'initial count',
    );
    await tester.tap(find.byKey(const Key('live-inventory-open-save')));
    await tester.pump();

    expect(api.openCalls, 1);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('live-inventory-open-save')),
          )
          .onPressed,
      isNull,
    );
    expect(await stock.openStock(quantityOnHand: 9, reason: 'again'), isFalse);
    expect(api.openCalls, 1);
    gate.complete(_opened());
    await tester.pumpAndSettle();
    expect(api.openCalls, 1);
    expect(stock.notOpen, isFalse);
    expect(find.text('Available: 7'), findsOneWidget);
  });
}
