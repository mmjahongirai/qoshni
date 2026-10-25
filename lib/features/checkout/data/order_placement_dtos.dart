class PlaceOrderLineRequestDto {
  const PlaceOrderLineRequestDto({
    required this.businessStableId,
    required this.catalogItemStableId,
    required this.quantity,
  });

  final String businessStableId;
  final String catalogItemStableId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        'business_stable_id': businessStableId,
        'catalog_item_stable_id': catalogItemStableId,
        'quantity': quantity,
      };
}

class PlaceOrderRequestDto {
  const PlaceOrderRequestDto({
    required this.fulfillmentType,
    required this.checkoutCorrelationId,
    required this.lines,
    this.serverQuoteId,
    this.serverQuoteRevision,
    this.clientSubmittedTotalMinor,
  });

  final String fulfillmentType;
  final String checkoutCorrelationId;
  final String? serverQuoteId;
  final int? serverQuoteRevision;
  final List<PlaceOrderLineRequestDto> lines;
  final int? clientSubmittedTotalMinor;

  Map<String, dynamic> toJson() => {
        'fulfillment_type': fulfillmentType,
        'checkout_correlation_id': checkoutCorrelationId,
        if (serverQuoteId != null) 'server_quote_id': serverQuoteId,
        if (serverQuoteRevision != null)
          'server_quote_revision': serverQuoteRevision,
        'lines': lines.map((l) => l.toJson()).toList(),
        if (clientSubmittedTotalMinor != null)
          'client_submitted_total_minor': clientSubmittedTotalMinor,
      };
}
