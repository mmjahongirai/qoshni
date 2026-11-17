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
const _actorId = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
const _profileId = 'sample-rental-tools';
const _demoTitle = 'Fresh bread';
const _demoStock = '12 available of 20';

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

class _StockApi implements AuthoritativeCatalogRepository {
  AuthoritativeInventoryBalance? balance;
  List<AuthoritativeInventoryEvent> events = const [];
  AuthoritativeCatalogFailure? readFailure;
  AuthoritativeCatalogFailure? replenishFailure;
  AuthoritativeCatalogFailure? countFailure;
  Completer<AuthoritativeInventoryBalance>? readGate;
  Completer<AuthoritativeInventoryBalance>? replenishGate;
  AuthoritativeInventoryBalance? replenishResult;
  AuthoritativeInventoryBalance? countResult;
  final List<String> applicationIds = [];
  int readCalls = 0;
  int replenishCalls = 0;
  int countCalls = 0;
  int eventCalls = 0;
  int? lastReplenishQuantity;
  String? lastReplenishReason;
  int? lastCount;
  String? lastCountReason;

  void _track(String applicationId) => applicationIds.add(applicationId);

  @override
  Future<AuthoritativeInventoryBalance> getInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) {
    readCalls += 1;
    _track(applicationId);
    final gate = readGate;
    if (gate != null) {
      return gate.future;
    }
    final failure = readFailure;
    if (failure != null) {
      throw failure;
    }
    final current = balance;
    if (current == null) {
      throw const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.conflict,
        message: 'Inventory has not been opened.',
        serverCode: liveInventoryNotOpenCode,
      );
    }
    return Future.value(current);
  }

  @override
  Future<AuthoritativeInventoryBalance> replenishInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantity,
    required String reason,
  }) {
    replenishCalls += 1;
    _track(applicationId);
    lastReplenishQuantity = quantity;
    lastReplenishReason = reason;
    final gate = replenishGate;
    if (gate != null) {
      return gate.future.then((value) {
        balance = value;
        return value;
      });
    }
    final failure = replenishFailure;
    if (failure != null) {
      throw failure;
    }
    final saved = replenishResult;
    if (saved == null) {
      throw StateError('missing replenishment response');
    }
    balance = saved;
    return Future.value(saved);
  }

  @override
  Future<AuthoritativeInventoryBalance> correctInventoryCount({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) {
    countCalls += 1;
    _track(applicationId);
    lastCount = quantityOnHand;
    lastCountReason = reason;
    final failure = countFailure;
    if (failure != null) {
      throw failure;
    }
    final saved = countResult;
    if (saved == null) {
      throw StateError('missing count response');
    }
    balance = saved;
    return Future.value(saved);
  }

  @override
  Future<List<AuthoritativeInventoryEvent>> listInventoryEvents({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) async {
    eventCalls += 1;
    _track(applicationId);
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
  Future<AuthoritativeInventoryBalance> openInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) => throw StateError('open inventory is not sent by this panel');
}

AuthoritativeInventoryBalance _balance({
  int onHand = 25,
  int reserved = 4,
  int available = 99,
}) {
  return AuthoritativeInventoryBalance(
    catalogItemId: _itemId,
    quantityOnHand: onHand,
    reservedQuantity: reserved,
    availableQuantity: available,
    updatedAt: DateTime.utc(2026, 11, 4, 12, 5),
  );
}

AuthoritativeInventoryEvent _event({
  AuthoritativeInventoryEventKind kind =
      AuthoritativeInventoryEventKind.replenished,
  int delta = -7,
  int onHand = 30,
  int reserved = 4,
  String reason = 'delivery',
}) {
  return AuthoritativeInventoryEvent(
    eventId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    catalogItemId: _itemId,
    actorUserId: _actorId,
    kind: kind,
    quantityDelta: delta,
    quantityOnHandAfter: onHand,
    reservedQuantityAfter: reserved,
    reason: reason,
    createdAt: DateTime.utc(2026, 11, 4, 12, 5),
  );
}

BusinessCatalogIntegrationController _integration(_StockApi api) {
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
  BusinessCatalogIntegrationController integration, {
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(900, 2200);
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
  if (settle) {
    await tester.pumpAndSettle();
  }
}

void _expectNoDemo() {
  expect(find.text(_demoTitle), findsNothing);
  expect(find.text(_demoStock), findsNothing);
  expect(find.textContaining('On hand: 0'), findsNothing);
}

void main() {
  testWidgets('inventory loading', (tester) async {
    final gate = Completer<AuthoritativeInventoryBalance>();
    final api = _StockApi()..readGate = gate;
    await _pump(tester, _integration(api), settle: false);
    for (var attempt = 0; attempt < 8; attempt++) {
      await tester.pump();
      if (find
          .byKey(const Key('live-inventory-loading'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(find.byKey(const Key('live-inventory-loading')), findsOneWidget);
    _expectNoDemo();
    gate.complete(_balance());
    await tester.pumpAndSettle();
    expect(find.text('On hand: 25'), findsOneWidget);
    expect(find.byKey(const Key('live-inventory-loading')), findsNothing);
  });

  testWidgets('inventory success keeps the server available quantity', (
    tester,
  ) async {
    final api = _StockApi()..balance = _balance();
    await _pump(tester, _integration(api));

    expect(find.text('On hand: 25'), findsOneWidget);
    expect(find.text('Reserved: 4'), findsOneWidget);
    expect(find.text('Available: 99'), findsOneWidget);
    expect(find.text('Available: 21'), findsNothing);
    _expectNoDemo();
  });

  testWidgets('no inventory is not shown as zero', (tester) async {
    final api = _StockApi()
      ..readFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.conflict,
        message: 'Inventory has not been opened.',
        serverCode: liveInventoryNotOpenCode,
      );
    await _pump(tester, _integration(api));

    expect(find.byKey(const Key('live-inventory-not-open')), findsOneWidget);
    expect(find.textContaining('No stock record'), findsOneWidget);
    expect(find.textContaining('On hand:'), findsNothing);
    _expectNoDemo();
  });

  testWidgets('inventory error does not restore demo stock', (tester) async {
    final api = _StockApi()
      ..readFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.network,
        message: 'offline',
      );
    await _pump(tester, _integration(api));

    expect(find.textContaining('could not reach the server'), findsOneWidget);
    expect(find.textContaining('On hand:'), findsNothing);
    _expectNoDemo();
  });

  testWidgets('replenishment validation does not call the API', (tester) async {
    final api = _StockApi()..balance = _balance();
    await _pump(tester, _integration(api));

    await tester.enterText(
      find.byKey(const Key('live-inventory-replenish-quantity')),
      '0',
    );
    await tester.enterText(
      find.byKey(const Key('live-inventory-replenish-reason')),
      'delivery',
    );
    await tester.tap(find.byKey(const Key('live-inventory-replenish-save')));
    await tester.pumpAndSettle();

    expect(api.replenishCalls, 0);
    expect(find.textContaining('greater than zero'), findsOneWidget);
    expect(find.text('On hand: 25'), findsOneWidget);
  });

  testWidgets('replenishment success reloads server stock and events', (
    tester,
  ) async {
    final api = _StockApi()
      ..balance = _balance()
      ..replenishResult = _balance(onHand: 30, reserved: 4, available: 26);
    final integration = _integration(api);
    await _pump(tester, integration);

    api.events = [_event(delta: 5, onHand: 30, reason: 'delivery')];
    await tester.enterText(
      find.byKey(const Key('live-inventory-replenish-quantity')),
      '5',
    );
    await tester.enterText(
      find.byKey(const Key('live-inventory-replenish-reason')),
      'delivery',
    );
    await tester.ensureVisible(
      find.byKey(const Key('live-inventory-replenish-save')),
    );
    await tester.tap(find.byKey(const Key('live-inventory-replenish-save')));
    await tester.pumpAndSettle();

    expect(api.replenishCalls, 1);
    expect(api.lastReplenishQuantity, 5);
    expect(api.lastReplenishReason, 'delivery');
    expect(api.readCalls, 2);
    expect(api.eventCalls, 2);
    expect(find.text('On hand: 30'), findsOneWidget);
    expect(find.text('Reserved: 4'), findsOneWidget);
    expect(find.text('Available: 26'), findsOneWidget);
    expect(find.text('Stock was updated from the server.'), findsOneWidget);
    expect(find.text('Replenished'), findsOneWidget);
    expect(find.text('Delta: 5'), findsOneWidget);
  });

  testWidgets('replenishment 409 keeps the previous server balance', (
    tester,
  ) async {
    final api = _StockApi()
      ..balance = _balance()
      ..replenishFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.conflict,
        message: 'Open inventory first.',
        serverCode: liveInventoryNotOpenCode,
      );
    await _pump(tester, _integration(api));
    await tester.enterText(
      find.byKey(const Key('live-inventory-replenish-quantity')),
      '5',
    );
    await tester.enterText(
      find.byKey(const Key('live-inventory-replenish-reason')),
      'delivery',
    );
    await tester.ensureVisible(
      find.byKey(const Key('live-inventory-replenish-save')),
    );
    await tester.tap(find.byKey(const Key('live-inventory-replenish-save')));
    await tester.pumpAndSettle();

    expect(api.replenishCalls, 1);
    expect(find.textContaining(liveInventoryNotOpenCode), findsWidgets);
    expect(find.text('On hand: 25'), findsOneWidget);
    expect(find.text('Reserved: 4'), findsOneWidget);
    expect(find.text('The stock request failed. Try again.'), findsNothing);
    _expectNoDemo();
  });

  testWidgets('count validation does not call the API', (tester) async {
    final api = _StockApi()..balance = _balance();
    await _pump(tester, _integration(api));
    await tester.ensureVisible(
      find.byKey(const Key('live-inventory-count-save')),
    );
    await tester.tap(find.byKey(const Key('live-inventory-count-save')));
    await tester.pumpAndSettle();

    expect(api.countCalls, 0);
    expect(find.textContaining('counted quantity'), findsOneWidget);
  });

  testWidgets('count success reloads the server balance', (tester) async {
    final api = _StockApi()
      ..balance = _balance()
      ..countResult = _balance(onHand: 21, reserved: 4, available: 17);
    await _pump(tester, _integration(api));
    api.events = [
      _event(
        kind: AuthoritativeInventoryEventKind.countCorrected,
        delta: -4,
        onHand: 21,
        reason: 'shelf count',
      ),
    ];
    await tester.ensureVisible(
      find.byKey(const Key('live-inventory-count-quantity')),
    );
    await tester.enterText(
      find.byKey(const Key('live-inventory-count-quantity')),
      '21',
    );
    await tester.enterText(
      find.byKey(const Key('live-inventory-count-reason')),
      'shelf count',
    );
    await tester.ensureVisible(
      find.byKey(const Key('live-inventory-count-save')),
    );
    await tester.tap(find.byKey(const Key('live-inventory-count-save')));
    await tester.pumpAndSettle();

    expect(api.countCalls, 1);
    expect(api.lastCount, 21);
    expect(api.lastCountReason, 'shelf count');
    expect(api.readCalls, 2);
    expect(find.text('On hand: 21'), findsOneWidget);
    expect(find.text('Reserved: 4'), findsOneWidget);
    expect(find.text('Available: 17'), findsOneWidget);
    expect(find.text('Count corrected'), findsOneWidget);
    expect(find.text('Delta: -4'), findsOneWidget);
  });

  testWidgets('count below_reserved keeps the server code and old balance', (
    tester,
  ) async {
    final api = _StockApi()
      ..balance = _balance()
      ..countFailure = const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.conflict,
        message: 'On-hand quantity cannot be set below the reserved quantity.',
        serverCode: 'below_reserved',
      );
    await _pump(tester, _integration(api));
    await tester.ensureVisible(
      find.byKey(const Key('live-inventory-count-quantity')),
    );
    await tester.enterText(
      find.byKey(const Key('live-inventory-count-quantity')),
      '1',
    );
    await tester.enterText(
      find.byKey(const Key('live-inventory-count-reason')),
      'shelf count',
    );
    await tester.ensureVisible(
      find.byKey(const Key('live-inventory-count-save')),
    );
    await tester.tap(find.byKey(const Key('live-inventory-count-save')));
    await tester.pumpAndSettle();

    expect(api.countCalls, 1);
    expect(find.textContaining('below_reserved'), findsWidgets);
    expect(find.text('On hand: 25'), findsOneWidget);
    expect(find.text('Reserved: 4'), findsOneWidget);
    expect(find.text('Available: 99'), findsOneWidget);
    expect(find.text('The stock request failed. Try again.'), findsNothing);
  });

  testWidgets('events render server fields', (tester) async {
    final api = _StockApi()
      ..balance = _balance(onHand: 30, available: 26)
      ..events = [_event()];
    await _pump(tester, _integration(api));

    expect(find.text('Replenished'), findsOneWidget);
    expect(find.text('Delta: -7'), findsOneWidget);
    expect(find.text('On hand after: 30'), findsOneWidget);
    expect(find.text('Reserved after: 4'), findsOneWidget);
    expect(find.text('delivery'), findsOneWidget);
    expect(find.textContaining(_actorId), findsOneWidget);
    expect(find.textContaining('2026-11-04T12:05:00.000Z'), findsOneWidget);
    expect(api.eventCalls, 1);
  });

  testWidgets('401 403 404 and 503 stay distinct and hide demo stock', (
    tester,
  ) async {
    final cases = {
      AuthoritativeCatalogErrorCode.authenticationRequired: 'session ended',
      AuthoritativeCatalogErrorCode.forbidden: 'not verified',
      AuthoritativeCatalogErrorCode.notFound: 'was not found',
      AuthoritativeCatalogErrorCode.catalogUnavailable:
          'not available on the server',
    };
    for (final entry in cases.entries) {
      final api = _StockApi()
        ..readFailure = AuthoritativeCatalogFailure(
          code: entry.key,
          message: 'failed',
          serverCode:
              entry.key == AuthoritativeCatalogErrorCode.catalogUnavailable
              ? 'authoritative_inventory_unavailable'
              : null,
        );
      await _pump(tester, _integration(api));
      expect(find.textContaining(entry.value), findsOneWidget);
      expect(find.textContaining('On hand:'), findsNothing);
      _expectNoDemo();
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  test('application id is the onboarding uuid on every stock call', () async {
    final api = _StockApi()
      ..balance = _balance()
      ..replenishResult = _balance(onHand: 30, available: 26)
      ..countResult = _balance(onHand: 21, available: 17);
    final integration = _integration(api);
    final stock = BusinessLiveInventoryController(
      integration: integration,
      catalogItemId: _itemId,
    );

    await stock.load();
    await stock.replenish(quantity: 5, reason: 'delivery');
    await stock.recordCount(quantityOnHand: 21, reason: 'shelf count');

    expect(api.applicationIds, isNotEmpty);
    expect(api.applicationIds, everyElement(_applicationId));
    expect(api.applicationIds, isNot(contains(_profileId)));
    expect(api.readCalls, greaterThan(0));
    expect(api.eventCalls, greaterThan(0));
  });

  test('invalid application id does not send a stock request', () async {
    final api = _StockApi()..balance = _balance();
    final integration = _integration(api);
    integration.applicationId = _profileId;
    final stock = BusinessLiveInventoryController(
      integration: integration,
      catalogItemId: _itemId,
    );

    await stock.load();

    expect(api.readCalls, 0);
    expect(api.eventCalls, 0);
    expect(stock.balance, isNull);
  });

  test('negative count and a second replenishment are not sent', () async {
    final gate = Completer<AuthoritativeInventoryBalance>();
    final api = _StockApi()
      ..balance = _balance()
      ..replenishGate = gate;
    final stock = BusinessLiveInventoryController(
      integration: _integration(api),
      catalogItemId: _itemId,
    );
    await stock.load();

    expect(await stock.recordCount(quantityOnHand: -1, reason: 'bad'), isFalse);
    expect(api.countCalls, 0);

    final first = stock.replenish(quantity: 5, reason: 'delivery');
    final second = stock.replenish(quantity: 9, reason: 'again');
    expect(await second, isFalse);
    expect(api.replenishCalls, 1);
    gate.complete(_balance(onHand: 30, available: 26));
    await first;
  });
}
