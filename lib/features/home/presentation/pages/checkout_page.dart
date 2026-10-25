import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_controller.dart';
import 'package:qoshni/features/checkout/application/qoshni_checkout_quote_service.dart';
import 'package:qoshni/features/checkout/application/qoshni_order_placement_service.dart';
import 'package:qoshni/features/checkout/domain/qoshni_order_placement_result.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_fulfillment_type.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/checkout/domain/qoshni_checkout_session.dart';
import 'package:qoshni/features/home/presentation/cart/cart_controller.dart';
import 'package:qoshni/features/home/presentation/cart/demo_order_snapshot.dart';
import 'package:qoshni/features/home/presentation/orders/demo_order_controller.dart';
import 'package:qoshni/features/home/presentation/cart/cart_currency_format.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/app_price_text.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/category_icon_badge.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/features/home/presentation/widgets/cart_demo_total_footer.dart';
import 'package:qoshni/routing/route_paths.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isConfirming = false;
  bool _serverPlacementBusy = false;
  String? _pendingRecordedReferenceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareCheckout());
  }

  void _prepareCheckout() {
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final checkout = getIt<QoshniCheckoutController>();
    checkout.preparePricing(
      l10n: l10n,
      colorScheme: Theme.of(context).colorScheme,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartController = getIt<CartController>();
    final checkoutController = getIt<QoshniCheckoutController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.checkoutTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([cartController, checkoutController]),
          builder: (context, _) {
            return ResponsiveLayout(
              phone: _CheckoutBody(
                maxWidth: 520,
                l10n: l10n,
                cartController: cartController,
                checkoutController: checkoutController,
                isConfirming: _isConfirming,
                onPrepare: _prepareCheckout,
                onConfirm: () => _confirmDemoOrder(context, l10n, cartController, checkoutController),
                onTryServerPlacement: () =>
                    _tryServerPlacement(context, l10n, cartController, checkoutController),
                serverPlacementBusy: _serverPlacementBusy,
              ),
              tablet: _CheckoutBody(
                maxWidth: 760,
                l10n: l10n,
                cartController: cartController,
                checkoutController: checkoutController,
                isConfirming: _isConfirming,
                onPrepare: _prepareCheckout,
                onConfirm: () => _confirmDemoOrder(context, l10n, cartController, checkoutController),
                onTryServerPlacement: () =>
                    _tryServerPlacement(context, l10n, cartController, checkoutController),
                serverPlacementBusy: _serverPlacementBusy,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _tryServerPlacement(
    BuildContext context,
    AppLocalizations l10n,
    CartController cartController,
    QoshniCheckoutController checkoutController,
  ) async {
    if (_serverPlacementBusy) {
      return;
    }
    final session = checkoutController.session;
    final quote = session?.quote;
    if (session == null ||
        quote == null ||
        session.status != QoshniCheckoutSessionStatus.priced) {
      _prepareCheckout();
      return;
    }
    setState(() => _serverPlacementBusy = true);
    final quoteService = getIt<QoshniCheckoutQuoteService>();
    final issueResult = await quoteService.tryIssueServerQuote(
      checkoutController: checkoutController,
      session: session,
      demoPricedSnapshot: quote,
    );
    if (!context.mounted) {
      return;
    }
    if (issueResult.outcome != QoshniServerQuoteIssueOutcome.success ||
        issueResult.serverQuote == null) {
      setState(() => _serverPlacementBusy = false);
      final message = switch (issueResult.outcome) {
        QoshniServerQuoteIssueOutcome.unavailableBackend =>
          l10n.checkoutServerOrderNotConfigured,
        QoshniServerQuoteIssueOutcome.unauthenticated =>
          l10n.checkoutServerOrderSignInRequired,
        QoshniServerQuoteIssueOutcome.catalogUnavailable =>
          l10n.checkoutServerOrderCatalogUnavailable,
        _ => l10n.checkoutPricingErrorBody,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    final placement = getIt<QoshniOrderPlacementService>();
    final serverQuote = issueResult.serverQuote!;
    final idempotencyKey =
        'cli-${session.correlationReference}-${serverQuote.quoteId}-${serverQuote.pricingRevision}';
    final result = await placement.tryPlaceServerOrder(
      checkoutController: checkoutController,
      session: session,
      pricedCartSnapshot: quote,
      serverQuote: serverQuote,
      idempotencyKey: idempotencyKey,
    );
    if (!context.mounted) {
      return;
    }
    setState(() => _serverPlacementBusy = false);
    final message = switch (result.outcome) {
      QoshniOrderPlacementOutcome.unavailableBackend =>
        l10n.checkoutServerOrderNotConfigured,
      QoshniOrderPlacementOutcome.unauthenticated =>
        l10n.checkoutServerOrderSignInRequired,
      QoshniOrderPlacementOutcome.catalogUnavailable =>
        l10n.checkoutServerOrderCatalogUnavailable,
      QoshniOrderPlacementOutcome.success => l10n.checkoutServerOrderSuccess(
          result.serverOrderId ?? '—',
        ),
      _ => l10n.checkoutPricingErrorBody,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmDemoOrder(
    BuildContext context,
    AppLocalizations l10n,
    CartController cartController,
    QoshniCheckoutController checkoutController,
  ) {
    if (_isConfirming) {
      return;
    }

    final session = checkoutController.session;
    if (session == null ||
        session.status == QoshniCheckoutSessionStatus.stale ||
        session.status == QoshniCheckoutSessionStatus.invalid ||
        session.quote == null) {
      _prepareCheckout();
      return;
    }

    final demoOrderController = getIt<DemoOrderController>();
    final colorScheme = Theme.of(context).colorScheme;

    DemoOrderSnapshot? snapshot;

    final pendingRef = _pendingRecordedReferenceId;
    if (pendingRef != null) {
      snapshot = demoOrderController.orderByReference(pendingRef)?.snapshot;
      if (snapshot == null) {
        _pendingRecordedReferenceId = null;
      }
    }

    snapshot ??= cartController.buildDemoOrderSnapshot(
      l10n,
      colorScheme,
      authoritativeQuote: session.quote,
    );
    if (snapshot == null) {
      return;
    }

    if (pendingRef == null) {
      if (!demoOrderController.recordOrder(snapshot)) {
        return;
      }
      _pendingRecordedReferenceId = snapshot.referenceId;
    }

    setState(() => _isConfirming = true);

    if (!context.mounted) {
      return;
    }

    context.pushReplacementNamed(
      RouteNames.demoOrderConfirmation,
      extra: snapshot,
    );
    cartController.clear();
    _pendingRecordedReferenceId = null;
  }
}

class _CheckoutBody extends StatelessWidget {
  const _CheckoutBody({
    required this.maxWidth,
    required this.l10n,
    required this.cartController,
    required this.checkoutController,
    required this.isConfirming,
    required this.onPrepare,
    required this.onConfirm,
    required this.onTryServerPlacement,
    required this.serverPlacementBusy,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final CartController cartController;
  final QoshniCheckoutController checkoutController;
  final bool isConfirming;
  final VoidCallback onPrepare;
  final VoidCallback onConfirm;
  final VoidCallback onTryServerPlacement;
  final bool serverPlacementBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lines = cartController.resolveLines(l10n, colorScheme);

    if (lines.isEmpty) {
      return _CheckoutEmptyState(l10n: l10n);
    }

    final session = checkoutController.session;
    final quote = session?.quote;
    final total = quote?.totalSom ?? 0;
    final textTheme = Theme.of(context).textTheme;
    final displayGroups = _groupsFromResolvedLines(lines);
    final showMultiBusiness = displayGroups.length > 1;

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: responsivePagePadding(context),
              children: [
                AppSurfaceCard(
                  child: Row(
                    children: [
                      const DemoContentBadge(),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.checkoutPreparationNotice,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _FulfillmentSelector(
                  l10n: l10n,
                  value: checkoutController.fulfillment,
                  onChanged: (value) {
                    checkoutController.setFulfillment(value);
                    onPrepare();
                  },
                ),
                if (session != null &&
                    session.correlationReference.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.checkoutSessionCorrelationLabel(
                      session.correlationReference,
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (showMultiBusiness) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.checkoutMultiBusinessNotice,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
                if (session?.status == QoshniCheckoutSessionStatus.stale) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _CheckoutBanner(
                    title: l10n.checkoutQuoteStaleTitle,
                    body: l10n.checkoutQuoteStaleBody,
                    onAction: onPrepare,
                    actionLabel: l10n.checkoutRecalculateAction,
                  ),
                ] else if (session?.status ==
                    QoshniCheckoutSessionStatus.invalid) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _CheckoutBanner(
                    title: _invalidTitle(l10n, session!.validationMessage),
                    body: _invalidBody(l10n, session.validationMessage),
                    onAction: onPrepare,
                    actionLabel: l10n.checkoutRecalculateAction,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                for (final group in displayGroups) ...[
                  Text(
                    group.businessName,
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (final line in group.lines) ...[
                    _CheckoutLineCard(l10n: l10n, line: line),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
          Padding(
            padding: responsivePagePadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CartDemoTotalFooter(l10n: l10n, totalUzs: total),
                  const SizedBox(height: 12),
                  AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.checkoutServerOrderSectionTitle,
                          style: textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.checkoutServerOrderUnavailableBody,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton(
                          onPressed: serverPlacementBusy ||
                                  session?.status !=
                                      QoshniCheckoutSessionStatus.priced
                              ? null
                              : onTryServerPlacement,
                          child: serverPlacementBusy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.checkoutServerOrderTryAction),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.checkoutDemoOrderSeparateNotice,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: onPrepare,
                    child: Text(l10n.checkoutRecalculateAction),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: isConfirming ||
                            session?.status != QoshniCheckoutSessionStatus.priced
                        ? null
                        : onConfirm,
                    child: isConfirming
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.checkoutConfirmDemoOrder),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _invalidTitle(AppLocalizations l10n, String? code) {
    if (code != null && code.contains('delivery')) {
      return l10n.checkoutUnsupportedFulfillmentTitle;
    }
    return l10n.checkoutPricingErrorTitle;
  }

  String _invalidBody(AppLocalizations l10n, String? code) {
    if (code != null && code.contains('delivery')) {
      return l10n.checkoutUnsupportedFulfillmentBody;
    }
    if (code == 'empty_cart') {
      return l10n.checkoutEmptyBody;
    }
    return l10n.checkoutPricingErrorBody;
  }

  List<_DisplayBusinessGroup> _groupsFromResolvedLines(
    List<ResolvedCartLine> lines,
  ) {
    final order = <MockBusinessId>[];
    final map = <MockBusinessId, List<ResolvedCartLine>>{};
    for (final line in lines) {
      final id = line.key.businessId;
      map.putIfAbsent(id, () => []).add(line);
      if (!order.contains(id)) {
        order.add(id);
      }
    }
    final sorted = List<MockBusinessId>.from(order)
      ..sort((a, b) => a.routeParam.compareTo(b.routeParam));
    return [
      for (final id in sorted)
        _DisplayBusinessGroup(
          businessName: map[id]!.first.businessName,
          lines: map[id]!,
        ),
    ];
  }
}

class _DisplayBusinessGroup {
  const _DisplayBusinessGroup({
    required this.businessName,
    required this.lines,
  });

  final String businessName;
  final List<ResolvedCartLine> lines;
}

class _FulfillmentSelector extends StatelessWidget {
  const _FulfillmentSelector({
    required this.l10n,
    required this.value,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final QoshniCheckoutFulfillmentType value;
  final ValueChanged<QoshniCheckoutFulfillmentType> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.checkoutFulfillmentLabel),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<QoshniCheckoutFulfillmentType>(
            segments: [
              ButtonSegment(
                value: QoshniCheckoutFulfillmentType.pickup,
                label: Text(l10n.checkoutFulfillmentPickup),
              ),
              ButtonSegment(
                value: QoshniCheckoutFulfillmentType.delivery,
                label: Text(l10n.checkoutFulfillmentDelivery),
              ),
              ButtonSegment(
                value: QoshniCheckoutFulfillmentType.serviceAtLocation,
                label: Text(l10n.checkoutFulfillmentServiceAtLocation),
              ),
            ],
            selected: {value},
            onSelectionChanged: (set) => onChanged(set.first),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBanner extends StatelessWidget {
  const _CheckoutBanner({
    required this.title,
    required this.body,
    required this.onAction,
    required this.actionLabel,
  });

  final String title;
  final String body;
  final VoidCallback onAction;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _CheckoutLineCard extends StatelessWidget {
  const _CheckoutLineCard({
    required this.l10n,
    required this.line,
  });

  final AppLocalizations l10n;
  final ResolvedCartLine line;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final item = line.catalogItem;

    return AppSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryIconBadge(
            icon: item.icon,
            accent: colorScheme.primary,
            size: 48,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(line.businessName, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.checkoutQuantityLabel(line.quantity),
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppPriceText(
                  label: formatCartDemoMoney(l10n, line.unitPriceUzs),
                  emphasis: PriceEmphasis.secondary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppPriceText(
                  label: l10n.cartLineSubtotal(
                    formatCartDemoMoney(l10n, line.subtotalUzs),
                  ),
                  emphasis: PriceEmphasis.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutEmptyState extends StatelessWidget {
  const _CheckoutEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.checkoutEmptyTitle,
        message: l10n.checkoutEmptyBody,
        action: FilledButton(
          onPressed: () => context.go(RoutePaths.home),
          child: Text(l10n.cartBrowseHome),
        ),
      ),
    );
  }
}
