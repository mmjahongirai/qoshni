import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_item.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_lifecycle_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_reconciliation.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_inventory_reservation_status_labels.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_inventory_reservation_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_reservation_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_reservation_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_inventory_reservation_validation.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_variant_controller.dart';

class BusinessCatalogInventoryReservationsPage extends StatefulWidget {
  const BusinessCatalogInventoryReservationsPage({super.key});

  @override
  State<BusinessCatalogInventoryReservationsPage> createState() =>
      _BusinessCatalogInventoryReservationsPageState();
}

class _BusinessCatalogInventoryReservationsPageState
    extends State<BusinessCatalogInventoryReservationsPage> {
  BusinessCatalogInventoryReservationStatus? _statusFilter;
  String? _expandedHistoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getIt<BusinessCatalogInventoryController>().refreshList();
      await getIt<BusinessCatalogInventoryReservationController>().refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reservationController =
        getIt<BusinessCatalogInventoryReservationController>();
    final inventoryController = getIt<BusinessCatalogInventoryController>();
    final productController = getIt<BusinessCatalogProductController>();
    final variantController = getIt<BusinessCatalogProductVariantController>();
    final branchController = getIt<BusinessBranchController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogInventoryReservationsTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: reservationController.operationBusy
            ? null
            : () => _showReserveDialog(
                  context,
                  l10n,
                  inventoryController.items(),
                  reservationController,
                  inventoryController,
                  productController,
                  variantController,
                  branchController,
                ),
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogInventoryReservationCreateAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            reservationController,
            inventoryController,
            productController,
            variantController,
            branchController,
          ]),
          builder: (context, _) {
            if (reservationController.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final all = reservationController.reservations();
            final filtered = reservationController.reservations(
              status: _statusFilter,
            );
            final report = reservationController.lastReconciliation;

            return ResponsiveLayout(
              phone: _ReservationsBody(
                maxWidth: 520,
                l10n: l10n,
                reservations: filtered,
                allCount: all.length,
                statusFilter: _statusFilter,
                report: report,
                expandedHistoryId: _expandedHistoryId,
                operationBusy: reservationController.operationBusy,
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                productLabel: (id) =>
                    productController.productById(id)?.displayName(l10n) ?? id,
                variantLabel: (id) =>
                    variantController.variantById(id)?.label ?? id,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: reservationController.historyFor,
                onRelease: (id) => _act(
                  context,
                  l10n,
                  reservationController,
                  inventoryController,
                  () => reservationController.release(id),
                  l10n.catalogInventoryReservationReleaseSuccess,
                ),
                onConfirm: (id) => _act(
                  context,
                  l10n,
                  reservationController,
                  inventoryController,
                  () => reservationController.confirm(id),
                  l10n.catalogInventoryReservationConfirmSuccess,
                ),
                onExpire: (id) => _act(
                  context,
                  l10n,
                  reservationController,
                  inventoryController,
                  () => reservationController.expire(id),
                  l10n.catalogInventoryReservationExpireSuccess,
                ),
                onExpireAllDue: () async {
                  final count = await reservationController.expireAllDue();
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.catalogInventoryReservationExpireAllResult(count),
                      ),
                    ),
                  );
                },
                onReconcile: () async {
                  await reservationController.runReconciliation();
                },
                canRelease: (r) => catalogReservationCanRelease(r),
                canConfirm: (r) =>
                    catalogReservationCanConfirm(r, DateTime.now()),
                canExpire: (r) =>
                    catalogReservationCanExpire(r, DateTime.now()),
              ),
              tablet: _ReservationsBody(
                maxWidth: 760,
                l10n: l10n,
                reservations: filtered,
                allCount: all.length,
                statusFilter: _statusFilter,
                report: report,
                expandedHistoryId: _expandedHistoryId,
                operationBusy: reservationController.operationBusy,
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                productLabel: (id) =>
                    productController.productById(id)?.displayName(l10n) ?? id,
                variantLabel: (id) =>
                    variantController.variantById(id)?.label ?? id,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: reservationController.historyFor,
                onRelease: (id) => _act(
                  context,
                  l10n,
                  reservationController,
                  inventoryController,
                  () => reservationController.release(id),
                  l10n.catalogInventoryReservationReleaseSuccess,
                ),
                onConfirm: (id) => _act(
                  context,
                  l10n,
                  reservationController,
                  inventoryController,
                  () => reservationController.confirm(id),
                  l10n.catalogInventoryReservationConfirmSuccess,
                ),
                onExpire: (id) => _act(
                  context,
                  l10n,
                  reservationController,
                  inventoryController,
                  () => reservationController.expire(id),
                  l10n.catalogInventoryReservationExpireSuccess,
                ),
                onExpireAllDue: () async {
                  final count = await reservationController.expireAllDue();
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.catalogInventoryReservationExpireAllResult(count),
                      ),
                    ),
                  );
                },
                onReconcile: () async {
                  await reservationController.runReconciliation();
                },
                canRelease: (r) => catalogReservationCanRelease(r),
                canConfirm: (r) =>
                    catalogReservationCanConfirm(r, DateTime.now()),
                canExpire: (r) =>
                    catalogReservationCanExpire(r, DateTime.now()),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _act<T>(
    BuildContext context,
    AppLocalizations l10n,
    BusinessCatalogInventoryReservationController reservationController,
    BusinessCatalogInventoryController inventoryController,
    Future<T> Function() action,
    String successMessage,
  ) async {
    await action();
    await inventoryController.refreshList();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage)),
    );
  }

  Future<void> _showReserveDialog(
    BuildContext context,
    AppLocalizations l10n,
    List<BusinessCatalogInventoryItem> items,
    BusinessCatalogInventoryReservationController reservationController,
    BusinessCatalogInventoryController inventoryController,
    BusinessCatalogProductController productController,
    BusinessCatalogProductVariantController variantController,
    BusinessBranchController branchController,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _ReserveDialog(
        l10n: l10n,
        items: items,
        reservationController: reservationController,
        inventoryController: inventoryController,
        productLabel: (id) =>
            productController.productById(id)?.displayName(l10n) ?? id,
        branchLabel: (id) => branchController.branchById(id)?.name ?? id,
      ),
    );
  }
}

class _ReservationsBody extends StatelessWidget {
  const _ReservationsBody({
    required this.maxWidth,
    required this.l10n,
    required this.reservations,
    required this.allCount,
    required this.statusFilter,
    required this.report,
    required this.expandedHistoryId,
    required this.operationBusy,
    required this.onStatusChanged,
    required this.onToggleHistory,
    required this.productLabel,
    required this.variantLabel,
    required this.branchLabel,
    required this.historyFor,
    required this.onRelease,
    required this.onConfirm,
    required this.onExpire,
    required this.onExpireAllDue,
    required this.onReconcile,
    required this.canRelease,
    required this.canConfirm,
    required this.canExpire,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessCatalogInventoryReservation> reservations;
  final int allCount;
  final BusinessCatalogInventoryReservationStatus? statusFilter;
  final BusinessCatalogInventoryReservationReconciliationReport? report;
  final String? expandedHistoryId;
  final bool operationBusy;
  final ValueChanged<BusinessCatalogInventoryReservationStatus?> onStatusChanged;
  final ValueChanged<String> onToggleHistory;
  final String Function(String productId) productLabel;
  final String Function(String variantId) variantLabel;
  final String Function(String branchId) branchLabel;
  final List<BusinessCatalogInventoryReservationLifecycleEvent> Function(String)
      historyFor;
  final Future<void> Function(String reservationId) onRelease;
  final Future<void> Function(String reservationId) onConfirm;
  final Future<void> Function(String reservationId) onExpire;
  final Future<void> Function() onExpireAllDue;
  final Future<void> Function() onReconcile;
  final bool Function(BusinessCatalogInventoryReservation) canRelease;
  final bool Function(BusinessCatalogInventoryReservation) canConfirm;
  final bool Function(BusinessCatalogInventoryReservation) canExpire;

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
              message: l10n.catalogInventoryReservationDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<
                      BusinessCatalogInventoryReservationStatus?>(
                    isExpanded: true,
                    value: statusFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogInventoryReservationStatusFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogInventoryReservationAllStatuses),
                      ),
                      for (final s
                          in BusinessCatalogInventoryReservationStatus.values)
                        DropdownMenuItem(
                          value: s,
                          child: Text(s.label(l10n)),
                        ),
                    ],
                    onChanged: operationBusy ? null : onStatusChanged,
                  ),
                  Text(
                    l10n.catalogListingFilteredCount(
                      reservations.length,
                      allCount,
                    ),
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      OutlinedButton(
                        onPressed: operationBusy ? null : onExpireAllDue,
                        child: Text(l10n.catalogInventoryReservationExpireAllDue),
                      ),
                      FilledButton.tonal(
                        onPressed: operationBusy ? null : onReconcile,
                        child: Text(l10n.catalogInventoryReservationReconcileAction),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (report != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.catalogInventoryReservationReconcileTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(l10n.catalogInventoryReservationReconcileDemoNote),
                    if (!report!.hasDiscrepancies)
                      Text(l10n.catalogInventoryReservationReconcileClean)
                    else
                      for (final line in report!.discrepancies)
                        Text(
                          l10n.catalogInventoryReservationReconcileLine(
                            line.inventoryItemId,
                            line.expectedReservedQuantity,
                            line.actualReservedQuantity,
                          ),
                          style: textTheme.bodySmall,
                        ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (reservations.isEmpty)
              AppSurfaceCard(child: Text(l10n.catalogInventoryReservationEmpty))
            else
              for (final r in reservations) ...[
                _ReservationCard(
                  l10n: l10n,
                  reservation: r,
                  productName: productLabel(r.productId),
                  variantName: r.variantId == null
                      ? null
                      : variantLabel(r.variantId!),
                  branchName: branchLabel(r.branchId),
                  historyExpanded: expandedHistoryId == r.reservationId,
                  history: historyFor(r.reservationId),
                  operationBusy: operationBusy,
                  onToggleHistory: () => onToggleHistory(r.reservationId),
                  onRelease: canRelease(r) &&
                          r.status ==
                              BusinessCatalogInventoryReservationStatus.reserved
                      ? () => onRelease(r.reservationId)
                      : null,
                  onConfirm: canConfirm(r) &&
                          r.status ==
                              BusinessCatalogInventoryReservationStatus.reserved
                      ? () => onConfirm(r.reservationId)
                      : null,
                  onExpire: canExpire(r) &&
                          r.status ==
                              BusinessCatalogInventoryReservationStatus.reserved
                      ? () => onExpire(r.reservationId)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.l10n,
    required this.reservation,
    required this.productName,
    required this.variantName,
    required this.branchName,
    required this.historyExpanded,
    required this.history,
    required this.operationBusy,
    required this.onToggleHistory,
    required this.onRelease,
    required this.onConfirm,
    required this.onExpire,
  });

  final AppLocalizations l10n;
  final BusinessCatalogInventoryReservation reservation;
  final String productName;
  final String? variantName;
  final String branchName;
  final bool historyExpanded;
  final List<BusinessCatalogInventoryReservationLifecycleEvent> history;
  final bool operationBusy;
  final VoidCallback onToggleHistory;
  final VoidCallback? onRelease;
  final VoidCallback? onConfirm;
  final VoidCallback? onExpire;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final created = MaterialLocalizations.of(context).formatShortDate(
      reservation.createdAt,
    );
    final expires = MaterialLocalizations.of(context).formatShortDate(
      reservation.expiresAt,
    );

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            productName,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (variantName != null)
            Text(l10n.catalogInventoryVariantLabel(variantName!)),
          Text(l10n.catalogInventoryBranchLabel(branchName)),
          Chip(label: Text(reservation.status.label(l10n))),
          Text(l10n.catalogInventoryReservationQuantityLabel(reservation.quantity)),
          Text(l10n.catalogInventoryReservationCreatedLabel(created)),
          Text(l10n.catalogInventoryReservationExpiresLabel(expires)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (onRelease != null)
                OutlinedButton(
                  onPressed: operationBusy ? null : onRelease,
                  child: Text(l10n.catalogInventoryReservationReleaseAction),
                ),
              if (onConfirm != null)
                FilledButton.tonal(
                  onPressed: operationBusy ? null : onConfirm,
                  child: Text(l10n.catalogInventoryReservationConfirmAction),
                ),
              if (onExpire != null)
                OutlinedButton(
                  onPressed: operationBusy ? null : onExpire,
                  child: Text(l10n.catalogInventoryReservationExpireAction),
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
            if (history.isEmpty)
              Text(l10n.catalogInventoryReservationHistoryEmpty)
            else
              for (final e in history.reversed)
                Text(
                  l10n.catalogInventoryReservationHistoryLine(
                    e.action.name,
                    e.statusBefore.name,
                    e.statusAfter.name,
                    e.quantity,
                  ),
                  style: textTheme.bodySmall,
                ),
          ],
        ],
      ),
    );
  }
}

class _ReserveDialog extends StatefulWidget {
  const _ReserveDialog({
    required this.l10n,
    required this.items,
    required this.reservationController,
    required this.inventoryController,
    required this.productLabel,
    required this.branchLabel,
  });

  final AppLocalizations l10n;
  final List<BusinessCatalogInventoryItem> items;
  final BusinessCatalogInventoryReservationController reservationController;
  final BusinessCatalogInventoryController inventoryController;
  final String Function(String productId) productLabel;
  final String Function(String branchId) branchLabel;

  @override
  State<_ReserveDialog> createState() => _ReserveDialogState();
}

class _ReserveDialogState extends State<_ReserveDialog> {
  String? _inventoryItemId;
  final _quantityController = TextEditingController(text: '1');
  final _minutesController = TextEditingController(text: '60');
  String? _errorMessage;

  @override
  void dispose() {
    _quantityController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = widget.l10n;
    final itemId = _inventoryItemId;
    if (itemId == null || itemId.isEmpty) {
      setState(() => _errorMessage = l10n.catalogInventoryReservationItemRequired);
      return;
    }
    final quantity = int.tryParse(_quantityController.text.trim());
    final minutes = int.tryParse(_minutesController.text.trim());
    if (quantity == null || quantity <= 0) {
      setState(() => _errorMessage = l10n.catalogInventoryReservationQuantityInvalid);
      return;
    }
    if (minutes == null || minutes <= 0) {
      setState(() => _errorMessage = l10n.catalogInventoryReservationExpiryInvalid);
      return;
    }
    final item = widget.inventoryController.itemById(itemId);
    final now = DateTime.now();
    final expiresAt = now.add(Duration(minutes: minutes));
    final validation = catalogInventoryReservationInputValidationError(
      quantity: quantity,
      expiresAt: expiresAt,
      now: now,
      item: item,
      businessScopeId: item?.businessScopeId ?? '',
    );
    if (validation != null) {
      setState(() {
        _errorMessage = _validationMessage(l10n, validation);
      });
      return;
    }

    final result = await widget.reservationController.reserve(
      BusinessCatalogInventoryReservationInput(
        inventoryItemId: itemId,
        quantity: quantity,
        expiresAt: expiresAt,
      ),
    );
    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogInventoryReservationReserveResult.success ||
        result == BusinessCatalogInventoryReservationReserveResult.idempotentReplay) {
      await widget.inventoryController.refreshList();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogInventoryReservationCreateSuccess)),
      );
      return;
    }
    setState(() => _errorMessage = _reserveResultMessage(l10n, result));
  }

  String _validationMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'insufficient_available':
        return l10n.catalogInventoryReservationInsufficientStock;
      case 'item_unavailable':
        return l10n.catalogInventoryReservationItemUnavailable;
      case 'invalid_expiry':
        return l10n.catalogInventoryReservationExpiryInvalid;
      default:
        return l10n.catalogInventoryReservationSaveFailed;
    }
  }

  String _reserveResultMessage(
    AppLocalizations l10n,
    BusinessCatalogInventoryReservationReserveResult result,
  ) {
    switch (result) {
      case BusinessCatalogInventoryReservationReserveResult.insufficientAvailable:
        return l10n.catalogInventoryReservationInsufficientStock;
      case BusinessCatalogInventoryReservationReserveResult.itemUnavailable:
        return l10n.catalogInventoryReservationItemUnavailable;
      case BusinessCatalogInventoryReservationReserveResult.invalidQuantity:
        return l10n.catalogInventoryReservationQuantityInvalid;
      case BusinessCatalogInventoryReservationReserveResult.invalidExpiry:
        return l10n.catalogInventoryReservationExpiryInvalid;
      default:
        return l10n.catalogInventoryReservationSaveFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final busy = widget.reservationController.operationBusy;

    return AlertDialog(
      title: Text(l10n.catalogInventoryReservationCreateTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _inventoryItemId,
              decoration: InputDecoration(
                labelText: l10n.catalogInventoryReservationItemLabel,
              ),
              items: [
                for (final item in widget.items)
                  DropdownMenuItem(
                    value: item.inventoryItemId,
                    child: Text(
                      '${widget.productLabel(item.productId)} · ${widget.branchLabel(item.branchId)}',
                    ),
                  ),
              ],
              onChanged: busy
                  ? null
                  : (v) => setState(() => _inventoryItemId = v),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: l10n.catalogInventoryReservationQuantityField,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !busy,
            ),
            TextField(
              controller: _minutesController,
              decoration: InputDecoration(
                labelText: l10n.catalogInventoryReservationExpiryMinutesField,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !busy,
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: busy ? null : _submit,
          child: Text(l10n.catalogInventoryReservationCreateConfirm),
        ),
      ],
    );
  }
}
