import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_price_text.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
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

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DemoContentBadge(),
          const SizedBox(height: AppSpacing.sm),
          AppPriceText(
            label: l10n.cartEstimatedTotalLabel(
              formatCartDemoMoney(l10n, totalUzs),
            ),
            emphasis: PriceEmphasis.total,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.cartDemoEstimateDisclaimer,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
