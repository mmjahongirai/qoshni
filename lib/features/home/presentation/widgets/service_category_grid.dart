import 'package:flutter/material.dart';
import 'package:qoshni/core/responsive/breakpoints.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/category_icon_badge.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

/// Grid column count for category shortcuts from available content width.
@visibleForTesting
int serviceCategoryCrossAxisCount(double maxWidth) {
  return maxWidth >= 520 ? 3 : 2;
}

/// Aspect ratio (width / height) keeps cards compact without excess vertical space.
@visibleForTesting
double serviceCategoryChildAspectRatio(int crossAxisCount) {
  return crossAxisCount >= 3 ? 2.35 : 2.15;
}

class ServiceCategoryGrid extends StatelessWidget {
  const ServiceCategoryGrid({
    required this.categories,
    required this.onCategorySelected,
    super.key,
  });

  final List<HomeServiceCategoryItem> categories;
  final ValueChanged<ServiceCategoryId> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = serviceCategoryCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: serviceCategoryChildAspectRatio(crossAxisCount),
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryCard(
              category: category,
              onTap: () => onCategorySelected(category.id),
            );
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final HomeServiceCategoryItem category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isCompactPhone = Breakpoints.isPhone(context);

    return Material(
      color: colorScheme.surface,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompactPhone ? AppSpacing.sm : AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CategoryIconBadge(
                  icon: category.icon,
                  accent: colorScheme.primary,
                  size: 36,
                  iconSize: AppIconSize.sm,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  category.label,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
