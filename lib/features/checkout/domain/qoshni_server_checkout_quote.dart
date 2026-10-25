/// Credentials returned by `POST /api/v1/checkout/quotes` — not a demo quote.
class QoshniServerCheckoutQuote {
  const QoshniServerCheckoutQuote({
    required this.quoteId,
    required this.pricingRevision,
  });

  /// Server-issued UUID string (`quote_id` in API JSON).
  final String quoteId;

  /// Authoritative pricing revision (`pricing_revision` in API JSON).
  final int pricingRevision;
}
