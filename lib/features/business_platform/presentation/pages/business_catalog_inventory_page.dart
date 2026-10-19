import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/core/widgets/demo_content_badge.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_adjustment.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_availability.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_track_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_variant_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessCatalogInventoryPage extends StatefulWidget {
  const BusinessCatalogInventoryPage({super.key});

  @override
  State<BusinessCatalogInventoryPage> createState() =>
      _BusinessCatalogInventoryPageState();
}

class _BusinessCatalogInventoryPageState
    extends State<BusinessCatalogInventoryPage> {
  String? _branchFilter;
  BusinessCatalogInventoryAvailability? _availabilityFilter;
  String? _expandedHistoryItemId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessCatalogInventoryController>().refreshList();
    });
  }

  void _clearFilters() {
    setState(() {
      _branchFilter = null;
      _availabilityFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inventoryController = getIt<BusinessCatalogInventoryController>();
    final branchController = getIt<BusinessBranchController>();
    final productController = getIt<BusinessCatalogProductController>();
    final variantController = getIt<BusinessCatalogProductVariantController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogInventoryListTitle),
        actions: [
          TextButton(
            onPressed: () =>
                context.push(RoutePaths.businessCatalogInventoryReservations),
            child: Text(l10n.catalogInventoryReservationsNavAction),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            inventoryController,
            branchController,
            productController,
            variantController,
          ]),
          builder: (context, _) {
            if (inventoryController.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (inventoryController.listError != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.catalogInventoryLoadFailed),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: inventoryController.refreshList,
                        child: Text(l10n.catalogInventoryRetryAction),
                      ),
                    ],
                  ),
                ),
              );
            }

            final all = inventoryController.items();
            final filtered = inventoryController.items(
              branchId: _branchFilter,
              availability: _availabilityFilter,
            );
            final branches = branchController.branches;

            return ResponsiveLayout(
              phone: _InventoryBody(
                maxWidth: 520,
                l10n: l10n,
                items: filtered,
                allCount: all.length,
                branches: branches,
                branchFilter: _branchFilter,
                availabilityFilter: _availabilityFilter,
                expandedHistoryItemId: _expandedHistoryItemId,
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onAvailabilityChanged: (v) =>
                    setState(() => _availabilityFilter = v),
                onClearFilters: _clearFilters,
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryItemId =
                      _expandedHistoryItemId == id ? null : id;
                }),
                productLabel: (productId) {
                  final p = productController.productById(productId);
                  return p?.displayName(l10n) ?? productId;
                },
                variantLabel: (variantId) {
                  final v = variantController.variantById(variantId);
                  return v?.label ?? variantId;
                },
                branchLabel: (branchId) {
                  final b = branchController.branchById(branchId);
                  return b?.name ?? branchId;
                },
                onAdjust: (item) => _showAdjustmentDialog(
                  context,
                  l10n,
                  inventoryController,
                  item,
                ),
                onToggleUnavailable: (item) async {
                  final next = item.trackStatus ==
                          BusinessCatalogInventoryTrackStatus.manuallyUnavailable
                      ? BusinessCatalogInventoryTrackStatus.active
                      : BusinessCatalogInventoryTrackStatus.manuallyUnavailable;
                  await inventoryController.setTrackStatus(
                    inventoryItemId: item.inventoryItemId,
                    trackStatus: next,
                  );
                },
              ),
              tablet: _InventoryBody(
                maxWidth: 760,
                l10n: l10n,
                items: filtered,
                allCount: all.length,
                branches: branches,
                branchFilter: _branchFilter,
                availabilityFilter: _availabilityFilter,
                expandedHistoryItemId: _expandedHistoryItemId,
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onAvailabilityChanged: (v) =>
                    setState(() => _availabilityFilter = v),
                onClearFilters: _clearFilters,
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryItemId =
                      _expandedHistoryItemId == id ? null : id;
                }),
                productLabel: (productId) {
                  final p = productController.productById(productId);
                  return p?.displayName(l10n) ?? productId;
                },
                variantLabel: (variantId) {
                  final v = variantController.variantById(variantId);
                  return v?.label ?? variantId;
                },
                branchLabel: (branchId) {
                  final b = branchController.branchById(branchId);
                  return b?.name ?? branchId;
                },
                onAdjust: (item) => _showAdjustmentDialog(
                  context,
                  l10n,
                  inventoryController,
                  item,
                ),
                onToggleUnavailable: (item) async {
                  final next = item.trackStatus ==
                          BusinessCatalogInventoryTrackStatus.manuallyUnavailable
                      ? BusinessCatalogInventoryTrackStatus.active
                      : BusinessCatalogInventoryTrackStatus.manuallyUnavailable;
                  await inventoryController.setTrackStatus(
                    inventoryItemId: item.inventoryItemId,
                    trackStatus: next,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAdjustmentDialog(
    BuildContext context,
    AppLocalizations l10n,
    BusinessCatalogInventoryController controller,
    BusinessCatalogInventoryItem item,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _StockAdjustmentDialog(
          l10n: l10n,
          item: item,
          controller: controller,
        );
      },
    );
  }
}

class _InventoryBody extends StatelessWidget {
  const _InventoryBody({
    required this.maxWidth,
    required this.l10n,
    required this.items,
    required this.allCount,
    required this.branches,
    required this.branchFilter,
    required this.availabilityFilter,
    required this.expandedHistoryItemId,
    required this.onBranchChanged,
    required this.onAvailabilityChanged,
    required this.onClearFilters,
    required this.onToggleHistory,
    required this.productLabel,
    required this.variantLabel,
    required this.branchLabel,
    required this.onAdjust,
    required this.onToggleUnavailable,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessCatalogInventoryItem> items;
  final int allCount;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessCatalogInventoryAvailability? availabilityFilter;
  final String? expandedHistoryItemId;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<BusinessCatalogInventoryAvailability?> onAvailabilityChanged;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onToggleHistory;
  final String Function(String productId) productLabel;
  final String Function(String variantId) variantLabel;
  final String Function(String branchId) branchLabel;
  final void Function(BusinessCatalogInventoryItem item) onAdjust;
  final Future<void> Function(BusinessCatalogInventoryItem item)
      onToggleUnavailable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.catalogInventoryDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    value: branchFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogInventoryBranchFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogInventoryAllBranches),
                      ),
                      for (final b in branches)
                        DropdownMenuItem(
                          value: b.branchId,
                          child: Text(b.name),
                        ),
                    ],
                    onChanged: onBranchChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<
                      BusinessCatalogInventoryAvailability?>(
                    isExpanded: true,
                    value: availabilityFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogInventoryAvailabilityFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogInventoryAllAvailability),
                      ),
                      for (final a in BusinessCatalogInventoryAvailability.values)
                        DropdownMenuItem(
                          value: a,
                          child: Text(a.label(l10n)),
                        ),
                    ],
                    onChanged: onAvailabilityChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onClearFilters,
                      child: Text(l10n.catalogListingClearFilters),
                    ),
                  ),
                  Text(
                    l10n.catalogListingFilteredCount(items.length, allCount),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (items.isEmpty)
              AppSurfaceCard(
                child: Text(l10n.catalogInventoryEmptyBody),
              )
            else
              for (final item in items) ...[
                _InventoryItemCard(
                  l10n: l10n,
                  item: item,
                  productName: productLabel(item.productId),
                  variantName: item.variantId == null
                      ? null
                      : variantLabel(item.variantId!),
                  branchName: branchLabel(item.branchId),
                  historyExpanded:
                      expandedHistoryItemId == item.inventoryItemId,
                  history: getIt<BusinessCatalogInventoryController>()
                      .historyFor(item.inventoryItemId),
                  onToggleHistory: () => onToggleHistory(item.inventoryItemId),
                  onAdjust: () => onAdjust(item),
                  onToggleUnavailable: () => onToggleUnavailable(item),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  const _InventoryItemCard({
    required this.l10n,
    required this.item,
    required this.productName,
    required this.variantName,
    required this.branchName,
    required this.historyExpanded,
    required this.history,
    required this.onToggleHistory,
    required this.onAdjust,
    required this.onToggleUnavailable,
  });

  final AppLocalizations l10n;
  final BusinessCatalogInventoryItem item;
  final String productName;
  final String? variantName;
  final String branchName;
  final bool historyExpanded;
  final List<BusinessCatalogInventoryAdjustmentEvent> history;
  final VoidCallback onToggleHistory;
  final VoidCallback onAdjust;
  final VoidCallback onToggleUnavailable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final availability = computeCatalogInventoryAvailability(item);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (variantName != null)
                      Text(
                        l10n.catalogInventoryVariantLabel(variantName!),
                        style: textTheme.bodySmall,
                      ),
                    Text(
                      l10n.catalogInventoryBranchLabel(branchName),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (item.isDemoSeed) const DemoContentBadge(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(label: Text(availability.label(l10n))),
              Text(l10n.catalogInventoryOnHandLabel(item.onHandQuantity)),
              Text(l10n.catalogInventoryReservedLabel(item.reservedQuantity)),
              Text(
                l10n.catalogInventoryAvailableLabel(item.availableQuantity),
              ),
              Text(
                l10n.catalogInventoryLowStockThresholdLabel(
                  item.lowStockThreshold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilledButton.tonal(
                onPressed: onAdjust,
                child: Text(l10n.catalogInventoryAdjustAction),
              ),
              OutlinedButton(
                onPressed: onToggleUnavailable,
                child: Text(
                  item.trackStatus ==
                          BusinessCatalogInventoryTrackStatus
                              .manuallyUnavailable
                      ? l10n.catalogInventoryMarkAvailableAction
                      : l10n.catalogInventoryMarkUnavailableAction,
                ),
              ),
              TextButton(
                onPressed: onToggleHistory,
                child: Text(
                  historyExpanded
                      ? l10n.catalogInventoryHideHistoryAction
                      : l10n.catalogInventoryShowHistoryAction,
                ),
              ),
            ],
          ),
          if (historyExpanded) ...[
            const SizedBox(height: AppSpacing.sm),
            if (history.isEmpty)
              Text(
                l10n.catalogInventoryHistoryEmpty,
                style: textTheme.bodySmall,
              )
            else
              for (final event in history.reversed)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    l10n.catalogInventoryHistoryLine(
                      event.delta,
                      event.onHandBefore,
                      event.onHandAfter,
                      event.reason,
                    ),
                    style: textTheme.bodySmall,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _StockAdjustmentDialog extends StatefulWidget {
  const _StockAdjustmentDialog({
    required this.l10n,
    required this.item,
    required this.controller,
  });

  final AppLocalizations l10n;
  final BusinessCatalogInventoryItem item;
  final BusinessCatalogInventoryController controller;

  @override
  State<_StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<_StockAdjustmentDialog> {
  final _deltaController = TextEditingController();
  final _reasonController = TextEditingController();
  BusinessCatalogInventoryAdjustmentKind _kind =
      BusinessCatalogInventoryAdjustmentKind.onHandDelta;
  String? _validationMessage;

  @override
  void dispose() {
    _deltaController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String? _messageForCode(String? code) {
    if (code == null) {
      return null;
    }
    final l10n = widget.l10n;
    switch (code) {
      case 'reason_required':
        return l10n.catalogInventoryAdjustReasonRequired;
      case 'delta_zero':
        return l10n.catalogInventoryAdjustDeltaZero;
      case 'on_hand_negative':
      case 'reserved_negative':
      case 'reserved_exceeds_on_hand':
        return l10n.catalogInventoryAdjustInvalidQuantities;
      default:
        return l10n.catalogInventoryAdjustInvalidQuantities;
    }
  }

  String? _messageForResult(BusinessCatalogInventoryAdjustmentResult result) {
    final l10n = widget.l10n;
    switch (result) {
      case BusinessCatalogInventoryAdjustmentResult.success:
        return null;
      case BusinessCatalogInventoryAdjustmentResult.invalidReason:
        return l10n.catalogInventoryAdjustReasonRequired;
      case BusinessCatalogInventoryAdjustmentResult.invalidDelta:
        return l10n.catalogInventoryAdjustDeltaZero;
      case BusinessCatalogInventoryAdjustmentResult.invalidQuantities:
        return l10n.catalogInventoryAdjustInvalidQuantities;
      case BusinessCatalogInventoryAdjustmentResult.notFound:
      case BusinessCatalogInventoryAdjustmentResult.failure:
        return l10n.catalogInventoryAdjustSaveFailed;
    }
  }

  Future<void> _submit() async {
    final delta = int.tryParse(_deltaController.text.trim());
    if (delta == null) {
      setState(() {
        _validationMessage = widget.l10n.catalogInventoryAdjustDeltaInvalid;
      });
      return;
    }
    final input = BusinessCatalogInventoryAdjustmentInput(
      kind: _kind,
      delta: delta,
      reason: _reasonController.text,
    );
    final preError = catalogInventoryAdjustmentValidationError(
      widget.item,
      input,
    );
    if (preError != null) {
      setState(() {
        _validationMessage = _messageForCode(preError);
      });
      return;
    }

    final result = await widget.controller.applyAdjustment(
      inventoryItemId: widget.item.inventoryItemId,
      input: input,
    );
    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogInventoryAdjustmentResult.success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.catalogInventoryAdjustSuccess)),
      );
      return;
    }
    setState(() {
      _validationMessage = _messageForResult(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      title: Text(l10n.catalogInventoryAdjustTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<BusinessCatalogInventoryAdjustmentKind>(
              isExpanded: true,
              value: _kind,
              decoration: InputDecoration(
                labelText: l10n.catalogInventoryAdjustKindLabel,
              ),
              items: [
                DropdownMenuItem(
                  value: BusinessCatalogInventoryAdjustmentKind.onHandDelta,
                  child: Text(l10n.catalogInventoryAdjustKindOnHand),
                ),
                DropdownMenuItem(
                  value: BusinessCatalogInventoryAdjustmentKind.reservedDelta,
                  child: Text(l10n.catalogInventoryAdjustKindReserved),
                ),
              ],
              onChanged: widget.controller.adjustBusy
                  ? null
                  : (v) {
                      if (v != null) {
                        setState(() => _kind = v);
                      }
                    },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _deltaController,
              decoration: InputDecoration(
                labelText: l10n.catalogInventoryAdjustDeltaLabel,
                helperText: l10n.catalogInventoryAdjustDeltaHint,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'-?\d+'))],
              enabled: !widget.controller.adjustBusy,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: l10n.catalogInventoryAdjustReasonLabel,
              ),
              maxLines: 2,
              enabled: !widget.controller.adjustBusy,
            ),
            if (_validationMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _validationMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.controller.adjustBusy
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: widget.controller.adjustBusy ? null : _submit,
          child: widget.controller.adjustBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.catalogInventoryAdjustConfirmAction),
        ),
      ],
    );
  }
}
