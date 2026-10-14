import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/di/injection.dart';
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

  /// Set when a snapshot was recorded but navigation did not complete yet.
  String? _pendingRecordedReferenceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartController = getIt<CartController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.checkoutTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: cartController,
          builder: (context, _) {
            return ResponsiveLayout(
              phone: _CheckoutBody(
                maxWidth: 520,
                l10n: l10n,
                cartController: cartController,
                isConfirming: _isConfirming,
                onConfirm: () => _confirmDemoOrder(context, l10n, cartController),
              ),
              tablet: _CheckoutBody(
                maxWidth: 760,
                l10n: l10n,
                cartController: cartController,
                isConfirming: _isConfirming,
                onConfirm: () => _confirmDemoOrder(context, l10n, cartController),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDemoOrder(
    BuildContext context,
    AppLocalizations l10n,
    CartController cartController,
  ) {
    if (_isConfirming) {
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

    snapshot ??= cartController.buildDemoOrderSnapshot(l10n, colorScheme);
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
    required this.isConfirming,
    required this.onConfirm,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final CartController cartController;
  final bool isConfirming;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lines = cartController.resolveLines(l10n, colorScheme);

    if (lines.isEmpty) {
      return _CheckoutEmptyState(l10n: l10n);
    }

    final total = cartController.estimatedTotalUzs(l10n, colorScheme);
    final textTheme = Theme.of(context).textTheme;

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
                          l10n.checkoutReviewNotice,
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
                for (var i = 0; i < lines.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _CheckoutLineCard(l10n: l10n, line: lines[i]),
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
                  FilledButton(
                    onPressed: isConfirming ? null : onConfirm,
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
