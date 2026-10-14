import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_price_text.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/category_icon_badge.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/features/home/presentation/data/business_catalog_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/navigation/catalog_navigation.dart';

class CatalogOfferingTile extends StatelessWidget {
  const CatalogOfferingTile({
    required this.item,
    required this.businessId,
    required this.l10n,
    super.key,
  });

  final BusinessCatalogItem item;
  final MockBusinessId businessId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final typeLabel = catalogItemKindLabel(item.kind, l10n);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => openCatalogItemDetail(
        context,
        businessId: businessId,
        catalogItemId: item.id,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryIconBadge(
            icon: item.icon,
            accent: colorScheme.primary,
            size: 52,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const DemoContentBadge(),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        typeLabel,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.name,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.description,
                  style: textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.samplePriceUzs != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppPriceText(
                    label: formatCatalogSamplePrice(item.samplePriceUzs!, l10n),
                    emphasis: PriceEmphasis.primary,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
