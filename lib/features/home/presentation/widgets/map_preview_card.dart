import 'package:flutter/material.dart';

class MapPreviewCard extends StatelessWidget {
  const MapPreviewCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onOpenMap,
    super.key,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenMap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 132,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.55),
                      colorScheme.surfaceContainerHighest,
                    ],
                  ),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 18,
                      top: 18,
                      child: Icon(
                        Icons.map_outlined,
                        size: 28,
                        color: colorScheme.primary,
                      ),
                    ),
                    Positioned(
                      right: 42,
                      top: 34,
                      child: Icon(
                        Icons.location_on,
                        size: 18,
                        color: colorScheme.primary.withValues(alpha: 0.85),
                      ),
                    ),
                    Positioned(
                      left: 92,
                      bottom: 26,
                      child: Icon(
                        Icons.location_on,
                        size: 18,
                        color: colorScheme.primary.withValues(alpha: 0.85),
                      ),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 22,
                      child: Icon(
                        Icons.location_on,
                        size: 18,
                        color: colorScheme.primary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onOpenMap,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
