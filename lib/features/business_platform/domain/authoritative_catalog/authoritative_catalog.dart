/// Server catalog and inventory values. Prices are integer UZS minor units.
library;

enum AuthoritativeOfferingKind {
  product('product'),
  service('service');

  const AuthoritativeOfferingKind(this.wireValue);
  final String wireValue;

  static AuthoritativeOfferingKind parse(String raw) {
    for (final kind in AuthoritativeOfferingKind.values) {
      if (kind.wireValue == raw) {
        return kind;
      }
    }
    throw const AuthoritativeCatalogFailure(
      code: AuthoritativeCatalogErrorCode.malformedResponse,
      message: 'Unexpected offering kind.',
    );
  }
}

enum AuthoritativeCatalogItemStatus {
  active('active'),
  inactive('inactive'),
  archived('archived');

  const AuthoritativeCatalogItemStatus(this.wireValue);
  final String wireValue;

  static AuthoritativeCatalogItemStatus parse(String raw) {
    for (final status in AuthoritativeCatalogItemStatus.values) {
      if (status.wireValue == raw) {
        return status;
      }
    }
    throw const AuthoritativeCatalogFailure(
      code: AuthoritativeCatalogErrorCode.malformedResponse,
      message: 'Unexpected catalog status.',
    );
  }
}

enum AuthoritativeInventoryEventKind {
  opened('opened'),
  replenished('replenished'),
  countCorrected('count_corrected');

  const AuthoritativeInventoryEventKind(this.wireValue);
  final String wireValue;

  static AuthoritativeInventoryEventKind parse(String raw) {
    for (final kind in AuthoritativeInventoryEventKind.values) {
      if (kind.wireValue == raw) {
        return kind;
      }
    }
    throw const AuthoritativeCatalogFailure(
      code: AuthoritativeCatalogErrorCode.malformedResponse,
      message: 'Unexpected inventory event kind.',
    );
  }
}

enum AuthoritativeCatalogErrorCode {
  authenticationRequired,
  forbidden,
  notFound,
  conflict,
  validationFailed,
  catalogUnavailable,
  apiNotConfigured,
  invalidApplicationId,
  network,
  malformedResponse,
  unknown,
}

class AuthoritativeCatalogFailure implements Exception {
  const AuthoritativeCatalogFailure({
    required this.code,
    required this.message,
    this.serverCode,
  });

  final AuthoritativeCatalogErrorCode code;
  final String message;
  final String? serverCode;

  bool get isSessionExpired =>
      code == AuthoritativeCatalogErrorCode.authenticationRequired;

  @override
  String toString() => 'AuthoritativeCatalogFailure(${code.name})';
}

final RegExp authoritativeApplicationIdPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

void requireAuthoritativeApplicationId(String applicationId) {
  if (!authoritativeApplicationIdPattern.hasMatch(applicationId)) {
    throw const AuthoritativeCatalogFailure(
      code: AuthoritativeCatalogErrorCode.invalidApplicationId,
      message: 'A verified onboarding application id is required.',
    );
  }
}

class AuthoritativeCatalogItem {
  const AuthoritativeCatalogItem({
    required this.catalogItemId,
    required this.businessApplicationId,
    required this.catalogItemStableId,
    required this.offeringKind,
    required this.title,
    required this.unitPriceMinor,
    required this.currencyCode,
    required this.pricingRevision,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String catalogItemId;
  final String businessApplicationId;
  final String catalogItemStableId;
  final AuthoritativeOfferingKind offeringKind;
  final String title;
  final int unitPriceMinor;
  final String currencyCode;
  final int pricingRevision;
  final AuthoritativeCatalogItemStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AuthoritativeCatalogItem.fromJson(Map<String, dynamic> json) {
    return AuthoritativeCatalogItem(
      catalogItemId: _string(json, 'catalog_item_id'),
      businessApplicationId: _string(json, 'business_application_id'),
      catalogItemStableId: _string(json, 'catalog_item_stable_id'),
      offeringKind: AuthoritativeOfferingKind.parse(
        _string(json, 'offering_kind'),
      ),
      title: _string(json, 'title'),
      unitPriceMinor: _int(json, 'unit_price_minor'),
      currencyCode: _string(json, 'currency_code'),
      pricingRevision: _int(json, 'pricing_revision'),
      status: AuthoritativeCatalogItemStatus.parse(_string(json, 'status')),
      createdAt: DateTime.parse(_string(json, 'created_at')),
      updatedAt: DateTime.parse(_string(json, 'updated_at')),
    );
  }
}

class AuthoritativeInventoryBalance {
  const AuthoritativeInventoryBalance({
    required this.catalogItemId,
    required this.quantityOnHand,
    required this.reservedQuantity,
    required this.availableQuantity,
    required this.updatedAt,
  });

  final String catalogItemId;
  final int quantityOnHand;
  final int reservedQuantity;
  final int availableQuantity;
  final DateTime updatedAt;

  factory AuthoritativeInventoryBalance.fromJson(Map<String, dynamic> json) {
    return AuthoritativeInventoryBalance(
      catalogItemId: _string(json, 'catalog_item_id'),
      quantityOnHand: _int(json, 'quantity_on_hand'),
      reservedQuantity: _int(json, 'reserved_quantity'),
      availableQuantity: _int(json, 'available_quantity'),
      updatedAt: DateTime.parse(_string(json, 'updated_at')),
    );
  }
}

class AuthoritativeInventoryEvent {
  const AuthoritativeInventoryEvent({
    required this.eventId,
    required this.catalogItemId,
    required this.actorUserId,
    required this.kind,
    required this.quantityDelta,
    required this.quantityOnHandAfter,
    required this.reservedQuantityAfter,
    required this.reason,
    required this.createdAt,
  });

  final String eventId;
  final String catalogItemId;
  final String actorUserId;
  final AuthoritativeInventoryEventKind kind;
  final int quantityDelta;
  final int quantityOnHandAfter;
  final int reservedQuantityAfter;
  final String reason;
  final DateTime createdAt;

  factory AuthoritativeInventoryEvent.fromJson(Map<String, dynamic> json) {
    return AuthoritativeInventoryEvent(
      eventId: _string(json, 'event_id'),
      catalogItemId: _string(json, 'catalog_item_id'),
      actorUserId: _string(json, 'actor_user_id'),
      kind: AuthoritativeInventoryEventKind.parse(_string(json, 'kind')),
      quantityDelta: _int(json, 'quantity_delta'),
      quantityOnHandAfter: _int(json, 'quantity_on_hand_after'),
      reservedQuantityAfter: _int(json, 'reserved_quantity_after'),
      reason: _string(json, 'reason'),
      createdAt: DateTime.parse(_string(json, 'created_at')),
    );
  }
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw AuthoritativeCatalogFailure(
      code: AuthoritativeCatalogErrorCode.malformedResponse,
      message: 'Missing $key.',
    );
  }
  return value;
}

int _int(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw AuthoritativeCatalogFailure(
      code: AuthoritativeCatalogErrorCode.malformedResponse,
      message: 'Missing $key.',
    );
  }
  return value;
}
