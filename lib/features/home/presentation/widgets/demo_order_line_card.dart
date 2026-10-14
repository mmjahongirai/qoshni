import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_price_text.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/features/home/presentation/cart/cart_currency_format.dart';
import 'package:qoshni/features/home/presentation/cart/demo_order_snapshot.dart';

class DemoOrderLineCard extends StatelessWidget {
  const DemoOrderLineCard({
    required this.l10n,
    required this.line,
    super.key,
  });

  final AppLocalizations l10n;
  final DemoOrderLineSnapshot line;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.itemName,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            line.businessName,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.checkoutQuantityLabel(line.quantity)),
          const SizedBox(height: AppSpacing.xxs),
          AppPriceText(
            label: l10n.cartLineSubtotal(
              formatCartDemoMoney(l10n, line.subtotalUzs),
            ),
          ),
        ],
      ),
    );
  }
}
