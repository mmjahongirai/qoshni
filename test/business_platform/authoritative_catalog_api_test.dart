import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/business_onboarding/domain/onboarding_failure.dart';
import 'package:qoshni/features/business_platform/application/business_catalog_integration_controller.dart';
import 'package:qoshni/features/business_platform/data/authoritative_catalog_api_repository.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog_repository.dart';

const _applicationId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const _itemId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
const _profileId = 'sample-rental-tools';

const _configured = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: 'https://api.example.test',
  enableLogging: false,
  enableBusinessProfileSamples: true,
  enableBusinessOfferingSamples: true,
  enableRemoteSearchDiscovery: false,
);

const _unconfigured = AppConfig(
  environment: AppEnvironment.development,
  appName: 'test',
  apiBaseUrl: '',
  enableLogging: false,
  enableBusinessProfileSamples: true,
  enableBusinessOfferingSamples: true,
  enableRemoteSearchDiscovery: false,
);

Map<String, dynamic> _item({int price = 8000, int revision = 1}) {
  return {
    'catalog_item_id': _itemId,
    'business_application_id': _applicationId,
    'catalog_item_stable_id': 'bread',
    'offering_kind': 'product',
    'title': 'Bread',
    'unit_price_minor': price,
    'currency_code': 'UZS',
    'pricing_revision': revision,
    'status': 'active',
    'created_at': '2026-11-04T12:00:00Z',
    'updated_at': '2026-11-04T12:00:00Z',
  };
}

Map<String, dynamic> _balance() {
  return {
    'catalog_item_id': _itemId,
    'quantity_on_hand': 7,
    'reserved_quantity': 2,
    'available_quantity': 5,
    'updated_at': '2026-11-04T12:05:00Z',
  };
}

AuthoritativeCatalogApiRepository _repository(
  Dio dio, {
  AppConfig config = _configured,
}) {
  return AuthoritativeCatalogApiRepository(
    apiClient: ApiClient(
      config: config,
      logger: AppLogger(config),
      dio: dio,
    ),
    config: config,
  );
}

Dio _dio({
  required Map<String, dynamic> data,
  int statusCode = 200,
  void Function(RequestOptions options)? onRequest,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        onRequest?.call(options);
        final response = Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: statusCode,
          data: data,
        );
        if (statusCode >= 400) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        handler.resolve(response);
      },
    ),
  );
  return dio;
}

void main() {
  test('list sends bearer token and application id, not a profile id', () async {
    String? authorization;
    String? path;
    final repository = _repository(
      _dio(
        data: {'items': [_item()]},
        onRequest: (options) {
          authorization = options.headers['Authorization'] as String?;
          path = options.path;
        },
      ),
    );

    final items = await repository.listItems(
      accessToken: 'session-token',
      applicationId: _applicationId,
    );

    expect(authorization, 'Bearer session-token');
    expect(path, contains(_applicationId));
    expect(path, isNot(contains(_profileId)));
    expect(items.single.unitPriceMinor, 8000);
    expect(items.single.pricingRevision, 1);
    expect(items.single.currencyCode, 'UZS');
  });

  test('profile id is rejected before any request', () async {
    var called = false;
    final repository = _repository(
      _dio(
        data: {'items': [_item()]},
        onRequest: (_) => called = true,
      ),
    );

    expect(
      () => repository.listItems(
        accessToken: 'session-token',
        applicationId: _profileId,
      ),
      throwsA(
        isA<AuthoritativeCatalogFailure>().having(
          (failure) => failure.code,
          'code',
          AuthoritativeCatalogErrorCode.invalidApplicationId,
        ),
      ),
    );
    expect(called, isFalse);
  });

  test('create, price and status keep integer price and revision', () async {
    final requests = <RequestOptions>[];
    final repository = _repository(
      _dio(
        data: _item(price: 9000, revision: 2),
        statusCode: 201,
        onRequest: requests.add,
      ),
    );

    final created = await repository.createItem(
      accessToken: 'session-token',
      applicationId: _applicationId,
      catalogItemStableId: 'bread',
      offeringKind: AuthoritativeOfferingKind.product,
      title: 'Bread',
      unitPriceMinor: 8000,
    );
    expect(requests.single.method, 'POST');
    expect(requests.single.data['unit_price_minor'], 8000);
    expect(created.pricingRevision, 2);

    requests.clear();
    final priced = await repository.updatePrice(
      accessToken: 'session-token',
      applicationId: _applicationId,
      catalogItemId: _itemId,
      unitPriceMinor: 9000,
    );
    expect(requests.single.path, endsWith('/price'));
    expect(requests.single.data, {'unit_price_minor': 9000});
    expect(priced.unitPriceMinor, 9000);
    expect(priced.pricingRevision, 2);

    requests.clear();
    await repository.updateStatus(
      accessToken: 'session-token',
      applicationId: _applicationId,
      catalogItemId: _itemId,
      status: AuthoritativeCatalogItemStatus.archived,
    );
    expect(requests.single.path, endsWith('/status'));
    expect(requests.single.data, {'status': 'archived'});
  });

  test('inventory summary, replenishment and count stay separate', () async {
    final requests = <RequestOptions>[];
    final repository = _repository(
      _dio(
        data: _balance(),
        onRequest: requests.add,
      ),
    );

    final summary = await repository.getInventory(
      accessToken: 'session-token',
      applicationId: _applicationId,
      catalogItemId: _itemId,
    );
    expect(summary.quantityOnHand, 7);
    expect(summary.reservedQuantity, 2);
    expect(summary.availableQuantity, 5);

    await repository.replenishInventory(
      accessToken: 'session-token',
      applicationId: _applicationId,
      catalogItemId: _itemId,
      quantity: 3,
      reason: 'morning delivery',
    );
    expect(requests.last.path, endsWith('/inventory/replenishments'));
    expect(requests.last.data['quantity'], 3);

    await repository.correctInventoryCount(
      accessToken: 'session-token',
      applicationId: _applicationId,
      catalogItemId: _itemId,
      quantityOnHand: 6,
      reason: 'shelf count',
    );
    expect(requests.last.path, endsWith('/inventory/counts'));
    expect(requests.last.data.containsKey('reserved_quantity'), isFalse);
  });

  test('401, 403, 404, 409 and 503 stay typed', () async {
    Future<AuthoritativeCatalogFailure> failureFor(
      int status,
      Map<String, dynamic> body,
    ) async {
      final repository = _repository(
        _dio(data: body, statusCode: status),
      );
      try {
        await repository.listItems(
          accessToken: 'session-token',
          applicationId: _applicationId,
        );
      } on AuthoritativeCatalogFailure catch (failure) {
        return failure;
      }
      fail('expected a catalog failure');
    }

    expect(
      (await failureFor(401, {
        'error': {'code': 'authentication_required', 'message': 'Sign in.'},
      })).code,
      AuthoritativeCatalogErrorCode.authenticationRequired,
    );
    expect(
      (await failureFor(403, {
        'detail': {
          'code': 'business_not_verified',
          'message': 'Not verified.',
        },
      })).code,
      AuthoritativeCatalogErrorCode.forbidden,
    );
    expect(
      (await failureFor(404, {
        'detail': {'code': 'business_not_found', 'message': 'Missing.'},
      })).code,
      AuthoritativeCatalogErrorCode.notFound,
    );
    final conflict = await failureFor(409, {
      'detail': {'code': 'below_reserved', 'message': 'Too low.'},
    });
    expect(conflict.code, AuthoritativeCatalogErrorCode.conflict);
    expect(conflict.serverCode, 'below_reserved');
    expect(
      (await failureFor(503, {
        'code': 'authoritative_catalog_unavailable',
        'message': 'Catalog off.',
      })).code,
      AuthoritativeCatalogErrorCode.catalogUnavailable,
    );
  });

  test('unconfigured API does not call the network', () async {
    var called = false;
    final repository = _repository(
      _dio(
        data: {'items': [_item()]},
        onRequest: (_) => called = true,
      ),
      config: _unconfigured,
    );

    expect(
      () => repository.listItems(
        accessToken: 'session-token',
        applicationId: _applicationId,
      ),
      throwsA(
        isA<AuthoritativeCatalogFailure>().having(
          (failure) => failure.code,
          'code',
          AuthoritativeCatalogErrorCode.apiNotConfigured,
        ),
      ),
    );
    expect(called, isFalse);
  });

  test('live list failure does not replace demo offerings', () async {
    const demoOfferings = ['sample bread'];
    final controller = BusinessCatalogIntegrationController(
      config: _configured,
      accessTokenReader: _Token('session-token'),
      applications: _Lookup([_applicationId]),
      catalog: _FailingCatalog(
        const AuthoritativeCatalogFailure(
          code: AuthoritativeCatalogErrorCode.catalogUnavailable,
          message: 'Catalog off.',
          serverCode: 'authoritative_catalog_unavailable',
        ),
      ),
    );

    await controller.refresh();
    expect(controller.isLiveCatalogReady, isTrue);
    final live = await controller.listItems();

    expect(live, isNull);
    expect(demoOfferings, ['sample bread']);
    expect(
      controller.lastFailure?.code,
      AuthoritativeCatalogErrorCode.catalogUnavailable,
    );
    expect(controller.phase, BusinessCatalogLinkPhase.unavailable);
  });

  test('missing and ambiguous applications stay unavailable', () async {
    final missing = BusinessCatalogIntegrationController(
      config: _configured,
      accessTokenReader: _Token('session-token'),
      applications: _Lookup(const []),
      catalog: _FailingCatalog(
        const AuthoritativeCatalogFailure(
          code: AuthoritativeCatalogErrorCode.unknown,
          message: 'unused',
        ),
      ),
    );
    await missing.refresh();
    expect(missing.blocker, BusinessCatalogLinkBlocker.noVerifiedApplication);
    expect(await missing.listItems(), isNull);

    final ambiguous = BusinessCatalogIntegrationController(
      config: _configured,
      accessTokenReader: _Token('session-token'),
      applications: _Lookup(const [
        _applicationId,
        'cccccccc-cccc-cccc-cccc-cccccccccccc',
      ]),
      catalog: _FailingCatalog(
        const AuthoritativeCatalogFailure(
          code: AuthoritativeCatalogErrorCode.unknown,
          message: 'unused',
        ),
      ),
    );
    await ambiguous.refresh();
    expect(
      ambiguous.blocker,
      BusinessCatalogLinkBlocker.ambiguousApplication,
    );
  });

  test('session expiry is separate from a signed-out owner', () async {
    final signedOut = BusinessCatalogIntegrationController(
      config: _unconfigured,
      accessTokenReader: _Token(null),
      applications: _Lookup(const [_applicationId]),
      catalog: _FailingCatalog(
        const AuthoritativeCatalogFailure(
          code: AuthoritativeCatalogErrorCode.unknown,
          message: 'unused',
        ),
      ),
    );
    await signedOut.refresh();
    expect(signedOut.blocker, BusinessCatalogLinkBlocker.apiNotConfigured);

    final expired = BusinessCatalogIntegrationController(
      config: _configured,
      accessTokenReader: _Token('session-token'),
      applications: _Lookup(
        const [],
        failure: const OnboardingFailure(
          code: OnboardingErrorCode.authenticationRequired,
          message: 'Authentication required.',
        ),
      ),
      catalog: _FailingCatalog(
        const AuthoritativeCatalogFailure(
          code: AuthoritativeCatalogErrorCode.unknown,
          message: 'unused',
        ),
      ),
    );
    await expired.refresh();
    expect(expired.blocker, BusinessCatalogLinkBlocker.sessionExpired);
  });
}

class _Token implements AccessTokenReader {
  _Token(this.accessToken);

  @override
  final String? accessToken;
}

class _Lookup implements VerifiedApplicationLookup {
  _Lookup(this.ids, {this.failure});

  final List<String> ids;
  final OnboardingFailure? failure;

  @override
  Future<List<String>> verifiedApplicationIds({
    required String accessToken,
  }) async {
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return ids;
  }
}

class _FailingCatalog implements AuthoritativeCatalogRepository {
  _FailingCatalog(this.failure);

  final AuthoritativeCatalogFailure failure;

  @override
  Future<List<AuthoritativeCatalogItem>> listItems({
    required String accessToken,
    required String applicationId,
  }) async {
    throw failure;
  }

  @override
  Future<AuthoritativeCatalogItem> createItem({
    required String accessToken,
    required String applicationId,
    required String catalogItemStableId,
    required AuthoritativeOfferingKind offeringKind,
    required String title,
    required int unitPriceMinor,
  }) =>
      throw failure;

  @override
  Future<AuthoritativeCatalogItem> getItem({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) =>
      throw failure;

  @override
  Future<AuthoritativeInventoryBalance> correctInventoryCount({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) =>
      throw failure;

  @override
  Future<AuthoritativeInventoryBalance> getInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) =>
      throw failure;

  @override
  Future<List<AuthoritativeInventoryEvent>> listInventoryEvents({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) =>
      throw failure;

  @override
  Future<AuthoritativeInventoryBalance> openInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) =>
      throw failure;

  @override
  Future<AuthoritativeInventoryBalance> replenishInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantity,
    required String reason,
  }) =>
      throw failure;

  @override
  Future<AuthoritativeCatalogItem> updatePrice({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int unitPriceMinor,
  }) =>
      throw failure;

  @override
  Future<AuthoritativeCatalogItem> updateStatus({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required AuthoritativeCatalogItemStatus status,
  }) =>
      throw failure;
}
