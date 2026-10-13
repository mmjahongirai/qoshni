import 'package:flutter/material.dart';
import 'package:qoshni/core/responsive/breakpoints.dart';
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
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompactPhone ? 12 : 14,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(category.icon, size: 20, color: colorScheme.primary),
                ),
                const SizedBox(height: 8),
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
