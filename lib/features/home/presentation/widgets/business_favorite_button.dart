import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/favorites/favorites_controller.dart';

class BusinessFavoriteButton extends StatelessWidget {
  const BusinessFavoriteButton({
    required this.businessId,
    super.key,
  });

  final MockBusinessId businessId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favoritesController = getIt<FavoritesController>();
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: favoritesController,
      builder: (context, _) {
        final isFavorite = favoritesController.isFavorite(businessId);
        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          tooltip: isFavorite
              ? l10n.favoritesRemoveTooltip
              : l10n.favoritesAddTooltip,
          onPressed: () => favoritesController.toggleFavorite(businessId),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 22,
            color: isFavorite
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
