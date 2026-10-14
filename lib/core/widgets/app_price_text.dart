import 'package:flutter/material.dart';

/// Scannable price line for catalog and cart surfaces.
class AppPriceText extends StatelessWidget {
  const AppPriceText({
    required this.label,
    this.emphasis = PriceEmphasis.primary,
    super.key,
  });

  final String label;
  final PriceEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final style = switch (emphasis) {
      PriceEmphasis.primary => textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      PriceEmphasis.secondary => textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      PriceEmphasis.total => textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
    };

    return Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

enum PriceEmphasis { primary, secondary, total }
