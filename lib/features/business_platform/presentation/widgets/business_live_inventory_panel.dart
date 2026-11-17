import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/features/business_platform/application/business_catalog_integration_controller.dart';
import 'package:qoshni/features/business_platform/application/business_live_inventory_controller.dart';
import 'package:qoshni/features/business_platform/domain/authoritative_catalog/authoritative_catalog.dart';

/// Live stock for one catalog item. Reserved quantity is shown from the server
/// and is never submitted. Missing stock is the `inventory_not_open` conflict,
/// not a hidden zero.
class BusinessLiveInventoryPanel extends StatefulWidget {
  const BusinessLiveInventoryPanel({
    required this.integration,
    required this.catalogItemId,
    this.stock,
    super.key,
  });

  final BusinessCatalogIntegrationController integration;
  final String catalogItemId;
  final BusinessLiveInventoryController? stock;

  @override
  State<BusinessLiveInventoryPanel> createState() =>
      _BusinessLiveInventoryPanelState();
}

class _BusinessLiveInventoryPanelState
    extends State<BusinessLiveInventoryPanel> {
  late final BusinessLiveInventoryController _stock;

  @override
  void initState() {
    super.initState();
    _stock =
        widget.stock ??
        BusinessLiveInventoryController(
          integration: widget.integration,
          catalogItemId: widget.catalogItemId,
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stock.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _stock,
      builder: (context, _) {
        final balance = _stock.balance;
        final blocked =
            _stock.failure != null && balance == null && !_stock.notOpen;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),
            if (_stock.loading && balance == null)
              const _InventorySkeleton()
            else if (blocked)
              Text(
                key: const Key('live-inventory-error'),
                _failureMessage(l10n, _stock.failure),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  height: 1.35,
                ),
              )
            else ...[
              if (_stock.notOpen)
                Text(
                  key: const Key('live-inventory-not-open'),
                  l10n.businessLiveInventoryNotOpen,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              if (balance != null) _InventorySummary(balance: balance),
              if (_stock.failure != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  key: const Key('live-inventory-error'),
                  _failureMessage(l10n, _stock.failure),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    height: 1.35,
                  ),
                ),
              ],
              if (_stock.confirmed) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  key: const Key('live-inventory-saved'),
                  l10n.businessLiveInventorySaved,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
              if (balance != null || _stock.notOpen) ...[
                const SizedBox(height: AppSpacing.sm),
                if (_stock.notOpen)
                  _StockForm(
                    stock: _stock,
                    form: LiveInventoryForm.open,
                    title: l10n.businessLiveInventoryOpen,
                    quantityLabel: l10n.businessLiveInventoryOpenQuantity,
                    quantityKey: const Key('live-inventory-open-quantity'),
                    reasonKey: const Key('live-inventory-open-reason'),
                    submitKey: const Key('live-inventory-open-save'),
                  )
                else ...[
                  _StockForm(
                    stock: _stock,
                    form: LiveInventoryForm.replenish,
                    title: l10n.businessLiveInventoryReplenish,
                    quantityLabel: l10n.businessLiveInventoryQuantity,
                    quantityKey: const Key('live-inventory-replenish-quantity'),
                    reasonKey: const Key('live-inventory-replenish-reason'),
                    submitKey: const Key('live-inventory-replenish-save'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StockForm(
                    stock: _stock,
                    form: LiveInventoryForm.count,
                    title: l10n.businessLiveInventoryCount,
                    quantityLabel: l10n.businessLiveInventoryCounted,
                    quantityKey: const Key('live-inventory-count-quantity'),
                    reasonKey: const Key('live-inventory-count-reason'),
                    submitKey: const Key('live-inventory-count-save'),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                _InventoryEvents(stock: _stock),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _InventorySkeleton extends StatelessWidget {
  const _InventorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('live-inventory-loading'),
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.mdAll,
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary({required this.balance});

  final AuthoritativeInventoryBalance balance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodyMedium;
    return Column(
      key: const Key('live-inventory-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.businessLiveInventoryOnHand(balance.quantityOnHand),
          style: style,
        ),
        Text(
          l10n.businessLiveInventoryReserved(balance.reservedQuantity),
          style: style,
        ),
        Text(
          l10n.businessLiveInventoryAvailable(balance.availableQuantity),
          style: style,
        ),
      ],
    );
  }
}

class _StockForm extends StatefulWidget {
  const _StockForm({
    required this.stock,
    required this.form,
    required this.title,
    required this.quantityLabel,
    required this.quantityKey,
    required this.reasonKey,
    required this.submitKey,
  });

  final BusinessLiveInventoryController stock;
  final LiveInventoryForm form;
  final String title;
  final String quantityLabel;
  final Key quantityKey;
  final Key reasonKey;
  final Key submitKey;

  @override
  State<_StockForm> createState() => _StockFormState();
}

class _StockFormState extends State<_StockForm> {
  final _quantity = TextEditingController();
  final _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _quantity.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final quantity = int.tryParse(_quantity.text);
    final reason = _reason.text.trim();
    final allowsZero = widget.form != LiveInventoryForm.replenish;
    if (quantity == null || (allowsZero ? quantity < 0 : quantity < 1)) {
      setState(() {
        _error = switch (widget.form) {
          LiveInventoryForm.open =>
            l10n.businessLiveInventoryOpenQuantityInvalid,
          LiveInventoryForm.count => l10n.businessLiveInventoryCountInvalid,
          LiveInventoryForm.replenish =>
            l10n.businessLiveInventoryQuantityInvalid,
        };
      });
      return;
    }
    if (reason.isEmpty) {
      setState(() => _error = l10n.businessLiveInventoryReasonRequired);
      return;
    }
    final saved = switch (widget.form) {
      LiveInventoryForm.open => await widget.stock.openStock(
        quantityOnHand: quantity,
        reason: reason,
      ),
      LiveInventoryForm.count => await widget.stock.recordCount(
        quantityOnHand: quantity,
        reason: reason,
      ),
      LiveInventoryForm.replenish => await widget.stock.replenish(
        quantity: quantity,
        reason: reason,
      ),
    };
    if (!mounted) {
      return;
    }
    setState(() {
      _error = saved ? null : _failureMessage(l10n, widget.stock.failure);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          key: widget.quantityKey,
          controller: _quantity,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: widget.quantityLabel),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          key: widget.reasonKey,
          controller: _reason,
          decoration: InputDecoration(
            labelText: l10n.businessLiveInventoryReason,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(liveInventoryReasonMaxLength),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _error!,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            key: widget.submitKey,
            onPressed: widget.stock.saving ? null : _submit,
            child: widget.stock.saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.businessLiveInventorySubmit),
          ),
        ),
      ],
    );
  }
}

class _InventoryEvents extends StatelessWidget {
  const _InventoryEvents({required this.stock});

  final BusinessLiveInventoryController stock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: const Key('live-inventory-events'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.businessLiveInventoryEventsTitle,
          style: textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (stock.eventsFailure != null)
          Text(
            _failureMessage(l10n, stock.eventsFailure),
            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
          )
        else if (stock.events.isEmpty)
          Text(
            l10n.businessLiveInventoryEventsEmpty,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (final event in stock.events) ...[
            Text(_kindLabel(l10n, event.kind), style: textTheme.bodyMedium),
            Text(l10n.businessLiveInventoryEventDelta(event.quantityDelta)),
            Text(
              l10n.businessLiveInventoryEventOnHand(event.quantityOnHandAfter),
            ),
            Text(
              l10n.businessLiveInventoryEventReserved(
                event.reservedQuantityAfter,
              ),
            ),
            Text(event.reason),
            Text(l10n.businessLiveInventoryActor(event.actorUserId)),
            Text(event.createdAt.toUtc().toIso8601String()),
            const SizedBox(height: AppSpacing.xs),
          ],
      ],
    );
  }
}

enum LiveInventoryForm { open, replenish, count }

String _kindLabel(AppLocalizations l10n, AuthoritativeInventoryEventKind kind) {
  return switch (kind) {
    AuthoritativeInventoryEventKind.opened =>
      l10n.businessLiveInventoryKindOpened,
    AuthoritativeInventoryEventKind.replenished =>
      l10n.businessLiveInventoryKindReplenished,
    AuthoritativeInventoryEventKind.countCorrected =>
      l10n.businessLiveInventoryKindCountCorrected,
  };
}

String _failureMessage(
  AppLocalizations l10n,
  AuthoritativeCatalogFailure? failure,
) {
  return switch (failure?.code) {
    AuthoritativeCatalogErrorCode.authenticationRequired =>
      l10n.businessLiveInventoryErrorSession,
    AuthoritativeCatalogErrorCode.forbidden =>
      l10n.businessLiveInventoryErrorForbidden,
    AuthoritativeCatalogErrorCode.notFound =>
      l10n.businessLiveInventoryErrorNotFound,
    AuthoritativeCatalogErrorCode.conflict =>
      l10n.businessLiveInventoryErrorConflict(
        failure?.serverCode ?? 'conflict',
      ),
    AuthoritativeCatalogErrorCode.catalogUnavailable =>
      l10n.businessLiveInventoryErrorUnavailable,
    AuthoritativeCatalogErrorCode.network =>
      l10n.businessLiveInventoryErrorNetwork,
    _ => l10n.businessLiveInventoryErrorGeneric,
  };
}
