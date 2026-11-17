import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/application/business_live_catalog_controller.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_live_inventory_panel.dart';

/// Owner catalog management for the verified onboarding application.
///
/// Archive can return to active or inactive because the catalog status API
/// accepts every [AuthoritativeCatalogItemStatus] and does not treat archive
/// as terminal. Live stock for each item is loaded separately.
class BusinessLiveCatalogSection extends StatefulWidget {
  const BusinessLiveCatalogSection({super.key, this.catalog});

  final BusinessLiveCatalogController? catalog;

  @override
  State<BusinessLiveCatalogSection> createState() =>
      _BusinessLiveCatalogSectionState();
}

class _BusinessLiveCatalogSectionState
    extends State<BusinessLiveCatalogSection> {
  late final BusinessLiveCatalogController _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog ?? getIt<BusinessLiveCatalogController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _catalog.open();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([_catalog, _catalog.integration]),
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.businessLiveCatalogSectionTitle,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_catalog.loading)
              const _CatalogSkeleton()
            else if (_catalog.listFailed)
              _CatalogMessage(
                messageKey: const Key('live-catalog-error'),
                message: _failureMessage(l10n, _catalog.failure),
              )
            else if (!_catalog.integration.isLiveCatalogReady)
              _CatalogMessage(
                messageKey: const Key('live-catalog-closed'),
                message: l10n.businessLiveCatalogClosed,
              )
            else ...[
              if (_catalog.failure != null) ...[
                _CatalogMessage(
                  messageKey: const Key('live-catalog-error'),
                  message: _failureMessage(l10n, _catalog.failure),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (_catalog.items.isEmpty)
                _CatalogMessage(
                  messageKey: const Key('live-catalog-empty'),
                  message: l10n.businessLiveCatalogEmptyBody,
                  title: l10n.businessLiveCatalogEmptyTitle,
                )
              else
                for (final item in _catalog.items) ...[
                  _CatalogItemCard(catalog: _catalog, item: item),
                  const SizedBox(height: AppSpacing.sm),
                ],
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const Key('live-catalog-add'),
                  onPressed: _catalog.saving
                      ? null
                      : () => _showCreateDialog(context, _catalog),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.businessLiveCatalogAddItem),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      key: const Key('live-catalog-loading'),
      children: [
        for (var index = 0; index < 3; index++) ...[
          Container(
            height: 88,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.lgAll,
            ),
          ),
          if (index < 2) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({
    required this.messageKey,
    required this.message,
    this.title,
  });

  final Key messageKey;
  final String message;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AppSurfaceCard(
      child: Column(
        key: messageKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogItemCard extends StatelessWidget {
  const _CatalogItemCard({required this.catalog, required this.item});

  final BusinessLiveCatalogController catalog;
  final AuthoritativeCatalogItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _kindLabel(l10n, item.offeringKind),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${formatCatalogAmount(item.unitPriceMinor)} ${item.currencyCode}',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.businessLiveCatalogCurrency(item.currencyCode),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.businessLiveCatalogRevision(item.pricingRevision),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.businessLiveCatalogStableId(item.catalogItemStableId),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.businessLiveCatalogStatusLabel,
            style: textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final status in AuthoritativeCatalogItemStatus.values)
                ChoiceChip(
                  key: Key(
                    'live-catalog-status-${item.catalogItemId}-${status.wireValue}',
                  ),
                  label: Text(_statusLabel(l10n, status)),
                  selected: item.status == status,
                  onSelected: catalog.saving
                      ? null
                      : (selected) {
                          if (!selected || item.status == status) {
                            return;
                          }
                          catalog.updateStatus(
                            catalogItemId: item.catalogItemId,
                            status: status,
                          );
                        },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: Key('live-catalog-price-${item.catalogItemId}'),
              onPressed: catalog.saving
                  ? null
                  : () => _showPriceDialog(context, catalog, item),
              child: Text(l10n.businessLiveCatalogChangePrice),
            ),
          ),
          BusinessLiveInventoryPanel(
            integration: catalog.integration,
            catalogItemId: item.catalogItemId,
          ),
        ],
      ),
    );
  }
}

class _CreateCatalogItemDialog extends StatefulWidget {
  const _CreateCatalogItemDialog({required this.catalog});

  final BusinessLiveCatalogController catalog;

  @override
  State<_CreateCatalogItemDialog> createState() =>
      _CreateCatalogItemDialogState();
}

class _CreateCatalogItemDialogState extends State<_CreateCatalogItemDialog> {
  final _stableId = TextEditingController();
  final _title = TextEditingController();
  final _price = TextEditingController();
  AuthoritativeOfferingKind _kind = AuthoritativeOfferingKind.product;
  String? _error;

  @override
  void dispose() {
    _stableId.dispose();
    _title.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final stableId = _stableId.text.trim();
    final title = _title.text.trim();
    final price = int.tryParse(_price.text);
    if (stableId.isEmpty || title.isEmpty) {
      setState(() => _error = l10n.businessLiveCatalogFieldRequired);
      return;
    }
    if (stableId.length > liveCatalogStableIdMaxLength ||
        title.length > liveCatalogTitleMaxLength) {
      setState(() => _error = l10n.businessLiveCatalogFieldTooLong);
      return;
    }
    if (price == null || price < 0 || price > liveCatalogMaxUnitPriceMinor) {
      setState(() => _error = l10n.businessLiveCatalogPriceInvalid);
      return;
    }
    final saved = await widget.catalog.createItem(
      catalogItemStableId: stableId,
      offeringKind: _kind,
      title: title,
      unitPriceMinor: price,
    );
    if (!mounted) {
      return;
    }
    if (saved) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _error = _failureMessage(l10n, widget.catalog.failure);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.catalog,
      builder: (context, _) => AlertDialog(
        title: Text(l10n.businessLiveCatalogAddItem),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('live-catalog-stable-id'),
                controller: _stableId,
                decoration: InputDecoration(
                  labelText: l10n.businessLiveCatalogFieldStableId,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    liveCatalogStableIdMaxLength,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<AuthoritativeOfferingKind>(
                key: const Key('live-catalog-kind'),
                initialValue: _kind,
                decoration: InputDecoration(
                  labelText: l10n.businessLiveCatalogFieldKind,
                ),
                items: [
                  for (final kind in AuthoritativeOfferingKind.values)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(_kindLabel(l10n, kind)),
                    ),
                ],
                onChanged: (kind) {
                  if (kind != null) {
                    setState(() => _kind = kind);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('live-catalog-title'),
                controller: _title,
                decoration: InputDecoration(
                  labelText: l10n.businessLiveCatalogFieldTitle,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(liveCatalogTitleMaxLength),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('live-catalog-price-field'),
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.businessLiveCatalogFieldPrice,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.businessLiveCatalogCancel),
          ),
          FilledButton(
            key: const Key('live-catalog-save'),
            onPressed: widget.catalog.saving ? null : _save,
            child: Text(l10n.businessLiveCatalogSave),
          ),
        ],
      ),
    );
  }
}

class _PriceDialog extends StatefulWidget {
  const _PriceDialog({required this.catalog, required this.item});

  final BusinessLiveCatalogController catalog;
  final AuthoritativeCatalogItem item;

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  late final TextEditingController _price = TextEditingController(
    text: widget.item.unitPriceMinor.toString(),
  );
  String? _error;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final price = int.tryParse(_price.text);
    if (price == null || price < 0 || price > liveCatalogMaxUnitPriceMinor) {
      setState(() => _error = l10n.businessLiveCatalogPriceInvalid);
      return;
    }
    final saved = await widget.catalog.updatePrice(
      catalogItemId: widget.item.catalogItemId,
      unitPriceMinor: price,
    );
    if (!mounted) {
      return;
    }
    if (saved) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _error = _failureMessage(l10n, widget.catalog.failure);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.catalog,
      builder: (context, _) => AlertDialog(
        title: Text(l10n.businessLiveCatalogChangePrice),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.businessLiveCatalogRevision(widget.item.pricingRevision)),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const Key('live-catalog-price-field'),
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.businessLiveCatalogFieldPrice,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.businessLiveCatalogCancel),
          ),
          FilledButton(
            key: const Key('live-catalog-save'),
            onPressed: widget.catalog.saving ? null : _save,
            child: Text(l10n.businessLiveCatalogSave),
          ),
        ],
      ),
    );
  }
}

Future<void> _showCreateDialog(
  BuildContext context,
  BusinessLiveCatalogController catalog,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => _CreateCatalogItemDialog(catalog: catalog),
  );
}

Future<void> _showPriceDialog(
  BuildContext context,
  BusinessLiveCatalogController catalog,
  AuthoritativeCatalogItem item,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => _PriceDialog(catalog: catalog, item: item),
  );
}

String formatCatalogAmount(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(digits[index]);
  }
  return amount < 0 ? '-${buffer.toString()}' : buffer.toString();
}

String _kindLabel(AppLocalizations l10n, AuthoritativeOfferingKind kind) {
  return switch (kind) {
    AuthoritativeOfferingKind.product => l10n.businessLiveCatalogKindProduct,
    AuthoritativeOfferingKind.service => l10n.businessLiveCatalogKindService,
  };
}

String _statusLabel(
  AppLocalizations l10n,
  AuthoritativeCatalogItemStatus status,
) {
  return switch (status) {
    AuthoritativeCatalogItemStatus.active =>
      l10n.businessLiveCatalogStatusActive,
    AuthoritativeCatalogItemStatus.inactive =>
      l10n.businessLiveCatalogStatusInactive,
    AuthoritativeCatalogItemStatus.archived =>
      l10n.businessLiveCatalogStatusArchived,
  };
}

String _failureMessage(
  AppLocalizations l10n,
  AuthoritativeCatalogFailure? failure,
) {
  return switch (failure?.code) {
    AuthoritativeCatalogErrorCode.authenticationRequired =>
      l10n.businessLiveCatalogErrorSession,
    AuthoritativeCatalogErrorCode.forbidden =>
      l10n.businessLiveCatalogErrorForbidden,
    AuthoritativeCatalogErrorCode.notFound =>
      l10n.businessLiveCatalogErrorNotFound,
    AuthoritativeCatalogErrorCode.conflict =>
      l10n.businessLiveCatalogErrorConflict(failure?.serverCode ?? 'conflict'),
    AuthoritativeCatalogErrorCode.catalogUnavailable =>
      l10n.businessLiveCatalogErrorUnavailable,
    AuthoritativeCatalogErrorCode.invalidApplicationId =>
      l10n.businessLiveCatalogErrorInvalidApplication,
    _ => l10n.businessLiveCatalogErrorGeneric,
  };
}
