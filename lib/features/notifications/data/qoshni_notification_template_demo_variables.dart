/// Synthetic demo variable values for template preview (no PII or secrets).
Map<String, String> qoshniNotificationTemplateDemoVariablesForKey(
  String templateKey,
) {
  return switch (templateKey) {
    'demo.order.confirmation' => const {
      'customerLabel': 'Demo guest',
      'orderReference': 'DEMO-ORD-1042',
      'etaWindow': 'afternoon demo window',
    },
    'demo.delivery.status' => const {
      'statusPhrase': 'Courier is nearby (demo).',
      'courierLabel': 'Demo courier A',
    },
    'demo.security.alert' => const {
      'alertHeadline': 'New sign-in on a demo device.',
      'actionHint': 'Review sessions in profile.',
    },
    'demo.business.update' => const {
      'businessName': 'Demo Cafe',
      'updateSummary': 'Holiday hours updated for preview only.',
    },
    'demo.promotion.offer' => const {
      'offerTitle': 'Demo weekend bundle',
      'discountPercent': '15',
      'expiryDate': '2025-04-30',
    },
    'demo.archived.promotion' => const {
      'offerTitle': 'Legacy demo promo',
    },
    _ => const {},
  };
}
