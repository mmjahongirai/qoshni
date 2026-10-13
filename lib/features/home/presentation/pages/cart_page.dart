import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/cart/cart_controller.dart';
import 'package:qoshni/features/home/presentation/cart/cart_currency_format.dart';
import 'package:qoshni/features/home/presentation/widgets/cart_demo_total_footer.dart';
import 'package:qoshni/routing/route_paths.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartController = getIt<CartController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.cartTitle),
        actions: [
          ListenableBuilder(
            listenable: cartController,
            builder: (context, _) {
              if (cartController.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () => _confirmClearCart(context, l10n, cartController),
                child: Text(l10n.cartClearAction),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: cartController,
          builder: (context, _) {
            return ResponsiveLayout(
              phone: _CartBody(
                maxWidth: 520,
                l10n: l10n,
                cartController: cartController,
              ),
              tablet: _CartBody(
                maxWidth: 760,
                l10n: l10n,
                cartController: cartController,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmClearCart(
    BuildContext context,
    AppLocalizations l10n,
    CartController cartController,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.cartClearConfirmTitle),
          content: Text(l10n.cartClearConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cartClearConfirmCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.cartClearConfirmYes),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      cartController.clear();
    }
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({
    required this.maxWidth,
    required this.l10n,
    required this.cartController,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lines = cartController.resolveLines(l10n, colorScheme);

    if (lines.isEmpty) {
      return _CartEmptyState(l10n: l10n);
    }

    final total = cartController.estimatedTotalUzs(l10n, colorScheme);

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: responsivePagePadding(context),
              itemCount: lines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final line = lines[index];
                return _CartLineCard(
                  l10n: l10n,
                  line: line,
                  onIncrement: () =>
                      cartController.incrementQuantity(line.key),
                  onDecrement: () =>
                      cartController.decrementQuantity(line.key),
                  onRemove: () => cartController.removeLine(line.key),
                );
              },
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
                    onPressed: () => context.pushNamed(RouteNames.checkout),
                    child: Text(l10n.cartProceedCheckout),
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

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({
    required this.l10n,
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final AppLocalizations l10n;
  final ResolvedCartLine line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final item = line.catalogItem;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              line.businessName,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatCartDemoMoney(l10n, line.unitPriceUzs),
              style: textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.cartQuantityDecrease,
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '${line.quantity}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.cartQuantityIncrease,
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.cartRemoveItem,
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                ),
              ],
            ),
            Text(
              l10n.cartLineSubtotal(
                formatCartDemoMoney(l10n, line.subtotalUzs),
              ),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 48, color: colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              l10n.cartEmptyTitle,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cartEmptyBody,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go(RoutePaths.home),
              child: Text(l10n.cartBrowseHome),
            ),
          ],
        ),
      ),
    );
  }
}
