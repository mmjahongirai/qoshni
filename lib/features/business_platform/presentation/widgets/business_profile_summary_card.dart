import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_kind.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

class BusinessProfileSummaryCard extends StatelessWidget {
  const BusinessProfileSummaryCard({
    required this.l10n,
    required this.profile,
    required this.onTap,
    super.key,
  });

  final AppLocalizations l10n;
  final BusinessProfileDraft profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSample = profile.kind == BusinessProfileKind.sampleDemo;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  profile.businessName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          if (isSample) ...[
            const SizedBox(height: AppSpacing.xs),
            const DemoContentBadge(),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            serviceCategoryLabel(profile.categoryId, l10n),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            profile.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}
