import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/checkout/data/checkout_quote_dtos.dart';
import 'package:qoshni/features/checkout/data/order_placement_dtos.dart';
import 'package:qoshni/features/checkout/domain/qoshni_server_checkout_quote.dart';

void main() {
  test('issue response maps quote_id and pricing_revision for placement', () {
    const cartRevision = 17;
    final issueJson = {
      'quote_id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
      'pricing_revision': 1,
      'expires_at': '2026-10-25T12:00:00Z',
      'currency_code': 'UZS',
      'total_minor': 16000,
    };
    final issueDto = CheckoutQuoteIssueResponseDto.fromJson(issueJson);
    final serverQuote = issueDto.toServerCheckoutQuote();

    expect(serverQuote.quoteId, issueJson['quote_id']);
    expect(serverQuote.pricingRevision, 1);
    expect(serverQuote.pricingRevision, isNot(cartRevision));

    final placement = placeOrderRequestFromServerQuote(
      serverQuote: serverQuote,
      fulfillmentType: 'pickup',
      checkoutCorrelationId: 'corr-1',
      lines: const [
        PlaceOrderLineRequestDto(
          businessStableId: 'baraka-market',
          catalogItemStableId: 'baraka-fresh-bread',
          quantity: 2,
        ),
      ],
    );

    final wire = placement.toJson();
    expect(wire['server_quote_id'], issueJson['quote_id']);
    expect(wire['server_quote_revision'], issueJson['pricing_revision']);
    expect(wire['server_quote_revision'], isNot(cartRevision));
  });

  test('demo cart revision is not substituted for pricing revision', () {
    const serverQuote = QoshniServerCheckoutQuote(
      quoteId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      pricingRevision: 3,
    );
    const demoCartRevision = 99;

    final dto = placeOrderRequestFromServerQuote(
      serverQuote: serverQuote,
      fulfillmentType: 'pickup',
      checkoutCorrelationId: 'corr-x',
      lines: const [
        PlaceOrderLineRequestDto(
          businessStableId: 'b',
          catalogItemStableId: 'c',
          quantity: 1,
        ),
      ],
    );

    expect(dto.serverQuoteRevision, serverQuote.pricingRevision);
    expect(dto.serverQuoteRevision, isNot(demoCartRevision));
    expect(dto.serverQuoteId, serverQuote.quoteId);
    expect(dto.serverQuoteId, isNot(startsWith('quote-')));
  });
}
