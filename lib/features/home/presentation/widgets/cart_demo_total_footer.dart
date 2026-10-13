import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/home/presentation/cart/cart_currency_format.dart';

class CartDemoTotalFooter extends StatelessWidget {
  const CartDemoTotalFooter({
    required this.l10n,
    required this.totalUzs,
    super.key,
  });

  final AppLocalizations l10n;
  final int totalUzs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.cartEstimatedTotalLabel(
                formatCartDemoMoney(l10n, totalUzs),
              ),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.cartDemoEstimateDisclaimer,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
