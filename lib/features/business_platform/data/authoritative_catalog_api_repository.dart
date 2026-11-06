import 'package:dio/dio.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog_repository.dart';

class AuthoritativeCatalogApiRepository
    implements AuthoritativeCatalogRepository {
  AuthoritativeCatalogApiRepository({
    required ApiClient apiClient,
    required this.config,
  }) : _dio = apiClient.dio;

  final Dio _dio;
  final AppConfig config;

  static const _prefix = '/api/v1/business/onboarding/applications';

  @override
  Future<List<AuthoritativeCatalogItem>> listItems({
    required String accessToken,
    required String applicationId,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'GET',
      path: _items(applicationId),
    );
    final items = data['items'];
    if (items is! List) {
      throw _malformed();
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(AuthoritativeCatalogItem.fromJson)
        .toList(growable: false);
  }

  @override
  Future<AuthoritativeCatalogItem> getItem({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'GET',
      path: _item(applicationId, catalogItemId),
    );
    return AuthoritativeCatalogItem.fromJson(data);
  }

  @override
  Future<AuthoritativeCatalogItem> createItem({
    required String accessToken,
    required String applicationId,
    required String catalogItemStableId,
    required AuthoritativeOfferingKind offeringKind,
    required String title,
    required int unitPriceMinor,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'POST',
      path: _items(applicationId),
      body: {
        'catalog_item_stable_id': catalogItemStableId,
        'offering_kind': offeringKind.wireValue,
        'title': title,
        'unit_price_minor': unitPriceMinor,
      },
    );
    return AuthoritativeCatalogItem.fromJson(data);
  }

  @override
  Future<AuthoritativeCatalogItem> updatePrice({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int unitPriceMinor,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'PATCH',
      path: '${_item(applicationId, catalogItemId)}/price',
      body: {'unit_price_minor': unitPriceMinor},
    );
    return AuthoritativeCatalogItem.fromJson(data);
  }

  @override
  Future<AuthoritativeCatalogItem> updateStatus({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required AuthoritativeCatalogItemStatus status,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'PATCH',
      path: '${_item(applicationId, catalogItemId)}/status',
      body: {'status': status.wireValue},
    );
    return AuthoritativeCatalogItem.fromJson(data);
  }

  @override
  Future<AuthoritativeInventoryBalance> openInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'POST',
      path: '${_item(applicationId, catalogItemId)}/inventory',
      body: {'quantity_on_hand': quantityOnHand, 'reason': reason},
    );
    return AuthoritativeInventoryBalance.fromJson(data);
  }

  @override
  Future<AuthoritativeInventoryBalance> replenishInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantity,
    required String reason,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'POST',
      path: '${_item(applicationId, catalogItemId)}/inventory/replenishments',
      body: {'quantity': quantity, 'reason': reason},
    );
    return AuthoritativeInventoryBalance.fromJson(data);
  }

  @override
  Future<AuthoritativeInventoryBalance> correctInventoryCount({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
    required int quantityOnHand,
    required String reason,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'POST',
      path: '${_item(applicationId, catalogItemId)}/inventory/counts',
      body: {'quantity_on_hand': quantityOnHand, 'reason': reason},
    );
    return AuthoritativeInventoryBalance.fromJson(data);
  }

  @override
  Future<AuthoritativeInventoryBalance> getInventory({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'GET',
      path: '${_item(applicationId, catalogItemId)}/inventory',
    );
    return AuthoritativeInventoryBalance.fromJson(data);
  }

  @override
  Future<List<AuthoritativeInventoryEvent>> listInventoryEvents({
    required String accessToken,
    required String applicationId,
    required String catalogItemId,
  }) async {
    final data = await _send(
      accessToken: accessToken,
      applicationId: applicationId,
      method: 'GET',
      path: '${_item(applicationId, catalogItemId)}/inventory/events',
    );
    final events = data['events'];
    if (events is! List) {
      throw _malformed();
    }
    return events
        .whereType<Map<String, dynamic>>()
        .map(AuthoritativeInventoryEvent.fromJson)
        .toList(growable: false);
  }

  String _items(String applicationId) => '$_prefix/$applicationId/catalog/items';

  String _item(String applicationId, String catalogItemId) =>
      '${_items(applicationId)}/$catalogItemId';

  Future<Map<String, dynamic>> _send({
    required String accessToken,
    required String applicationId,
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    if (!config.apiConfigured) {
      throw const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.apiNotConfigured,
        message: 'API base URL is not configured.',
      );
    }
    requireAuthoritativeApplicationId(applicationId);
    if (accessToken.trim().isEmpty) {
      throw const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.authenticationRequired,
        message: 'Sign in to manage the live catalog.',
      );
    }
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(
          method: method,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      final data = response.data;
      if (data == null) {
        throw _malformed();
      }
      return data;
    } on AuthoritativeCatalogFailure {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  AuthoritativeCatalogFailure _malformed() {
    return const AuthoritativeCatalogFailure(
      code: AuthoritativeCatalogErrorCode.malformedResponse,
      message: 'Unexpected catalog response.',
    );
  }

  AuthoritativeCatalogFailure _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    final payload = _errorPayload(error.response?.data);
    final serverCode = payload?['code'] as String?;
    final message = (payload?['message'] as String?) ?? 'Request failed.';
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AuthoritativeCatalogFailure(
        code: AuthoritativeCatalogErrorCode.network,
        message: 'Network connection failed.',
      );
    }
    return AuthoritativeCatalogFailure(
      code: switch (status) {
        401 => AuthoritativeCatalogErrorCode.authenticationRequired,
        403 => AuthoritativeCatalogErrorCode.forbidden,
        404 => AuthoritativeCatalogErrorCode.notFound,
        409 => AuthoritativeCatalogErrorCode.conflict,
        422 => AuthoritativeCatalogErrorCode.validationFailed,
        503 => AuthoritativeCatalogErrorCode.catalogUnavailable,
        _ => AuthoritativeCatalogErrorCode.unknown,
      },
      message: message,
      serverCode: serverCode,
    );
  }

  Map<String, dynamic>? _errorPayload(Object? data) {
    if (data is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(data);
    final detail = map['detail'];
    if (detail is Map) {
      return Map<String, dynamic>.from(detail);
    }
    final error = map['error'];
    if (error is Map) {
      return Map<String, dynamic>.from(error);
    }
    if (map['code'] is String) {
      return map;
    }
    return null;
  }
}
