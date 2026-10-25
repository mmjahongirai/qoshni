import 'package:qoshni/features/checkout/domain/qoshni_checkout_fulfillment_type.dart';
import 'package:qoshni/features/home/presentation/data/business_catalog_mock_data.dart';

enum QoshniCheckoutFulfillmentValidation {
  supported,
  emptyCart,
  deliveryWithServiceItems,
  serviceAtLocationWithProductOnlyCart,
}

QoshniCheckoutFulfillmentValidation validateCheckoutFulfillment({
  required QoshniCheckoutFulfillmentType fulfillment,
  required List<CatalogItemKind> catalogItemKinds,
}) {
  if (catalogItemKinds.isEmpty) {
    return QoshniCheckoutFulfillmentValidation.emptyCart;
  }

  final hasService = catalogItemKinds.any((k) => k == CatalogItemKind.service);
  final hasProduct = catalogItemKinds.any((k) => k == CatalogItemKind.product);

  switch (fulfillment) {
    case QoshniCheckoutFulfillmentType.delivery:
      if (hasService) {
        return QoshniCheckoutFulfillmentValidation.deliveryWithServiceItems;
      }
      return QoshniCheckoutFulfillmentValidation.supported;
    case QoshniCheckoutFulfillmentType.serviceAtLocation:
      if (hasProduct && !hasService) {
        return QoshniCheckoutFulfillmentValidation
            .serviceAtLocationWithProductOnlyCart;
      }
      return QoshniCheckoutFulfillmentValidation.supported;
    case QoshniCheckoutFulfillmentType.pickup:
      return QoshniCheckoutFulfillmentValidation.supported;
  }
}
