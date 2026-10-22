import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product_media_item.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_product_media_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_media_controller.dart';

class CatalogProductMediaGallerySection extends StatelessWidget {
  const CatalogProductMediaGallerySection({
    required this.productId,
    this.readOnly = false,
    super.key,
  });

  final String productId;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogProductMediaController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final items = controller.mediaForProduct(productId);
        final primary = items.where((m) => m.isPrimary).firstOrNull ?? items.firstOrNull;

        return AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.catalogProductMediaGalleryTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppMessageBanner(
                message: l10n.catalogProductMediaPreviewOnlyNotice,
                icon: Icons.photo_library_outlined,
                tone: AppMessageTone.info,
              ),
              const SizedBox(height: AppSpacing.md),
              _PrimaryPreview(
                l10n: l10n,
                item: primary,
                controller: controller,
              ),
              const SizedBox(height: AppSpacing.md),
              if (items.isEmpty)
                Text(
                  l10n.catalogProductMediaEmptyBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                _ThumbnailStrip(
                  l10n: l10n,
                  productId: productId,
                  items: items,
                  controller: controller,
                  readOnly: readOnly,
                ),
              if (!readOnly) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: controller.saveBusy
                      ? null
                      : () => _pickLocalPreview(context, productId),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(l10n.catalogProductMediaAddAction),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickLocalPreview(BuildContext context, String productId) async {
    final l10n = AppLocalizations.of(context);
    final mediaController = getIt<BusinessCatalogProductMediaController>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (!context.mounted || result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogProductMediaPickFailed)),
      );
      return;
    }
    final saveResult = await mediaController.addLocalSessionPreview(
      productId: productId,
      bytes: bytes,
      displayLabel: file.name,
    );
    if (!context.mounted) {
      return;
    }
    if (saveResult == BusinessCatalogProductMediaSaveResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogProductMediaPreviewAdded)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogProductMediaSaveFailed)),
      );
    }
  }
}

class _PrimaryPreview extends StatelessWidget {
  const _PrimaryPreview({
    required this.l10n,
    required this.item,
    required this.controller,
  });

  final AppLocalizations l10n;
  final BusinessCatalogProductMediaItem? item;
  final BusinessCatalogProductMediaController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (item == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_not_supported_outlined, color: scheme.outline),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.catalogProductMediaNoPrimary),
              ],
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _MediaImage(item: item!, controller: controller),
            Positioned(
              left: AppSpacing.sm,
              top: AppSpacing.sm,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    l10n.catalogProductMediaPrimaryBadge,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaImage extends StatelessWidget {
  const _MediaImage({
    required this.item,
    required this.controller,
    this.compact = false,
  });

  final BusinessCatalogProductMediaItem item;
  final BusinessCatalogProductMediaController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (item.previewKind == BusinessCatalogProductMediaPreviewKind.localSession) {
      final bytes = controller.previewBytes(item.mediaId);
      if (bytes != null) {
        return Image.memory(bytes, fit: BoxFit.cover);
      }
    }
    if (compact) {
      return ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.image_outlined, color: scheme.outline),
      );
    }
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 48, color: scheme.outline),
            const SizedBox(height: AppSpacing.sm),
            Text(item.displayLabel, textAlign: TextAlign.center),
            if (item.isDemoSeed) ...[
              const SizedBox(height: AppSpacing.sm),
              const DemoContentBadge(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({
    required this.l10n,
    required this.productId,
    required this.items,
    required this.controller,
    required this.readOnly,
  });

  final AppLocalizations l10n;
  final String productId;
  final List<BusinessCatalogProductMediaItem> items;
  final BusinessCatalogProductMediaController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            _ThumbnailTile(
              l10n: l10n,
              productId: productId,
              item: items[index],
              index: index,
              count: items.length,
              controller: controller,
              readOnly: readOnly,
            ),
          ],
        ],
      ),
    );
  }
}

class _ThumbnailTile extends StatelessWidget {
  const _ThumbnailTile({
    required this.l10n,
    required this.productId,
    required this.item,
    required this.index,
    required this.count,
    required this.controller,
    required this.readOnly,
  });

  final AppLocalizations l10n;
  final String productId;
  final BusinessCatalogProductMediaItem item;
  final int index;
  final int count;
  final BusinessCatalogProductMediaController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Material(
            color: item.isPrimary
                ? scheme.primaryContainer
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: readOnly || controller.saveBusy
                  ? null
                  : () async {
                      await controller.setPrimary(
                        productId: productId,
                        mediaId: item.mediaId,
                      );
                    },
              child: SizedBox(
                width: 120,
                height: 72,
                child: _MediaImage(
                  item: item,
                  controller: controller,
                  compact: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.isPrimary ? Icons.star : Icons.star_border,
                size: 18,
                semanticLabel: l10n.catalogProductMediaMakePrimaryAction,
              ),
              if (!readOnly && count > 1) ...[
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: controller.saveBusy || index == 0
                      ? null
                      : () => _move(context, -1),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: controller.saveBusy || index >= count - 1
                      ? null
                      : () => _move(context, 1),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _move(BuildContext context, int delta) async {
    final items = controller.mediaForProduct(productId);
    final ids = items.map((m) => m.mediaId).toList();
    final target = index + delta;
    if (target < 0 || target >= ids.length) {
      return;
    }
    final swapped = ids[target];
    ids[target] = ids[index];
    ids[index] = swapped;
    await controller.reorderMedia(productId: productId, orderedMediaIds: ids);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
