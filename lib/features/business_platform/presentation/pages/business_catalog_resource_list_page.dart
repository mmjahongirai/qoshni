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
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_capacity_event.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_resource_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_catalog_resource_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_resource_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_resource_validation.dart';

class BusinessCatalogResourceListPage extends StatefulWidget {
  const BusinessCatalogResourceListPage({super.key});

  @override
  State<BusinessCatalogResourceListPage> createState() =>
      _BusinessCatalogResourceListPageState();
}

class _BusinessCatalogResourceListPageState
    extends State<BusinessCatalogResourceListPage> {
  String? _branchFilter;
  BusinessCatalogResourceType? _typeFilter;
  BusinessCatalogResourceStatus? _statusFilter;
  String? _expandedHistoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessCatalogResourceController>().refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessCatalogResourceController>();
    final branchController = getIt<BusinessBranchController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.catalogResourceListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.saveBusy
            ? null
            : () => _openEditor(context, l10n, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogResourceAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([controller, branchController]),
          builder: (context, _) {
            if (controller.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = controller.resources();
            final filtered = controller.resources(
              branchId: _branchFilter,
              type: _typeFilter,
              status: _statusFilter,
            );

            return ResponsiveLayout(
              phone: _ResourceListBody(
                maxWidth: 520,
                l10n: l10n,
                resources: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                typeFilter: _typeFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: controller.saveBusy,
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onTypeChanged: (v) => setState(() => _typeFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: controller.capacityHistory,
                onEdit: (r) => _openEditor(context, l10n, r),
                onChangeCapacity: (r) => _openCapacityDialog(context, l10n, r),
                onToggleUnavailable: (r) => _toggleUnavailable(l10n, r),
                onArchive: (r) => _archive(l10n, r),
              ),
              tablet: _ResourceListBody(
                maxWidth: 760,
                l10n: l10n,
                resources: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                typeFilter: _typeFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: controller.saveBusy,
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onTypeChanged: (v) => setState(() => _typeFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: controller.capacityHistory,
                onEdit: (r) => _openEditor(context, l10n, r),
                onChangeCapacity: (r) => _openCapacityDialog(context, l10n, r),
                onToggleUnavailable: (r) => _toggleUnavailable(l10n, r),
                onArchive: (r) => _archive(l10n, r),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleUnavailable(
    AppLocalizations l10n,
    BusinessCatalogResource resource,
  ) async {
    final controller = getIt<BusinessCatalogResourceController>();
    final next = resource.status ==
            BusinessCatalogResourceStatus.manuallyUnavailable
        ? BusinessCatalogResourceStatus.active
        : BusinessCatalogResourceStatus.manuallyUnavailable;
    await controller.setStatus(resourceId: resource.resourceId, status: next);
  }

  Future<void> _archive(
    AppLocalizations l10n,
    BusinessCatalogResource resource,
  ) async {
    await getIt<BusinessCatalogResourceController>()
        .archiveResource(resource.resourceId);
  }

  Future<void> _openEditor(
    BuildContext context,
    AppLocalizations l10n,
    BusinessCatalogResource? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ResourceEditorDialog(l10n: l10n, existing: existing),
    );
  }

  Future<void> _openCapacityDialog(
    BuildContext context,
    AppLocalizations l10n,
    BusinessCatalogResource resource,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) =>
          _CapacityChangeDialog(l10n: l10n, resource: resource),
    );
  }
}

class _ResourceListBody extends StatelessWidget {
  const _ResourceListBody({
    required this.maxWidth,
    required this.l10n,
    required this.resources,
    required this.allCount,
    required this.branches,
    required this.branchFilter,
    required this.typeFilter,
    required this.statusFilter,
    required this.expandedHistoryId,
    required this.saveBusy,
    required this.onBranchChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onToggleHistory,
    required this.branchLabel,
    required this.historyFor,
    required this.onEdit,
    required this.onChangeCapacity,
    required this.onToggleUnavailable,
    required this.onArchive,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessCatalogResource> resources;
  final int allCount;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessCatalogResourceType? typeFilter;
  final BusinessCatalogResourceStatus? statusFilter;
  final String? expandedHistoryId;
  final bool saveBusy;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<BusinessCatalogResourceType?> onTypeChanged;
  final ValueChanged<BusinessCatalogResourceStatus?> onStatusChanged;
  final ValueChanged<String> onToggleHistory;
  final String Function(String branchId) branchLabel;
  final List<BusinessCatalogResourceCapacityEvent> Function(String) historyFor;
  final void Function(BusinessCatalogResource) onEdit;
  final void Function(BusinessCatalogResource) onChangeCapacity;
  final void Function(BusinessCatalogResource) onToggleUnavailable;
  final void Function(BusinessCatalogResource) onArchive;

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
              message: l10n.catalogResourceDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    value: branchFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogResourceBranchFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogResourceAllBranches),
                      ),
                      for (final b in branches)
                        DropdownMenuItem(
                          value: b.branchId,
                          child: Text(b.name),
                        ),
                    ],
                    onChanged: saveBusy ? null : onBranchChanged,
                  ),
                  DropdownButtonFormField<BusinessCatalogResourceType?>(
                    isExpanded: true,
                    value: typeFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogResourceTypeFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogResourceAllTypes),
                      ),
                      for (final t in BusinessCatalogResourceType.values)
                        DropdownMenuItem(
                          value: t,
                          child: Text(t.label(l10n)),
                        ),
                    ],
                    onChanged: saveBusy ? null : onTypeChanged,
                  ),
                  DropdownButtonFormField<BusinessCatalogResourceStatus?>(
                    isExpanded: true,
                    value: statusFilter,
                    decoration: InputDecoration(
                      labelText: l10n.catalogResourceStatusFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.catalogResourceAllStatuses),
                      ),
                      for (final s in BusinessCatalogResourceStatus.values)
                        if (!s.isArchived)
                          DropdownMenuItem(
                            value: s,
                            child: Text(s.label(l10n)),
                          ),
                    ],
                    onChanged: saveBusy ? null : onStatusChanged,
                  ),
                  Text(
                    l10n.catalogListingFilteredCount(
                      resources.length,
                      allCount,
                    ),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (resources.isEmpty)
              AppSurfaceCard(child: Text(l10n.catalogResourceEmptyBody))
            else
              for (final r in resources) ...[
                _ResourceCard(
                  l10n: l10n,
                  resource: r,
                  branchName: branchLabel(r.branchId),
                  historyExpanded: expandedHistoryId == r.resourceId,
                  history: historyFor(r.resourceId),
                  saveBusy: saveBusy,
                  onToggleHistory: () => onToggleHistory(r.resourceId),
                  onEdit: () => onEdit(r),
                  onChangeCapacity: () => onChangeCapacity(r),
                  onToggleUnavailable: () => onToggleUnavailable(r),
                  onArchive: () => onArchive(r),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.l10n,
    required this.resource,
    required this.branchName,
    required this.historyExpanded,
    required this.history,
    required this.saveBusy,
    required this.onToggleHistory,
    required this.onEdit,
    required this.onChangeCapacity,
    required this.onToggleUnavailable,
    required this.onArchive,
  });

  final AppLocalizations l10n;
  final BusinessCatalogResource resource;
  final String branchName;
  final bool historyExpanded;
  final List<BusinessCatalogResourceCapacityEvent> history;
  final bool saveBusy;
  final VoidCallback onToggleHistory;
  final VoidCallback onEdit;
  final VoidCallback onChangeCapacity;
  final VoidCallback onToggleUnavailable;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = displayFromLocalized(resource.localized, l10n);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (resource.isDemoSeed) const DemoContentBadge(),
            ],
          ),
          Text(resource.type.label(l10n), style: textTheme.bodySmall),
          Text(l10n.catalogInventoryBranchLabel(branchName)),
          Chip(label: Text(resource.status.label(l10n))),
          Text(l10n.catalogResourceTotalLabel(resource.totalCapacity)),
          Text(l10n.catalogResourceAllocatedLabel(resource.allocatedCapacity)),
          Text(l10n.catalogResourceAvailableLabel(resource.availableCapacity)),
          Text(l10n.catalogResourceUnitLabel(resource.capacityUnit)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              OutlinedButton(
                onPressed: saveBusy ? null : onEdit,
                child: Text(l10n.catalogResourceEditAction),
              ),
              FilledButton.tonal(
                onPressed: saveBusy ? null : onChangeCapacity,
                child: Text(l10n.catalogResourceChangeCapacityAction),
              ),
              OutlinedButton(
                onPressed: saveBusy ? null : onToggleUnavailable,
                child: Text(
                  resource.status ==
                          BusinessCatalogResourceStatus.manuallyUnavailable
                      ? l10n.catalogResourceMarkActiveAction
                      : l10n.catalogResourceMarkUnavailableAction,
                ),
              ),
              TextButton(
                onPressed: saveBusy ? null : onArchive,
                child: Text(l10n.catalogResourceArchiveAction),
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
              Text(l10n.catalogResourceHistoryEmpty, style: textTheme.bodySmall)
            else
              for (final e in history.reversed)
                Text(
                  l10n.catalogResourceHistoryLine(
                    e.totalBefore,
                    e.totalAfter,
                    e.reason,
                  ),
                  style: textTheme.bodySmall,
                ),
          ],
        ],
      ),
    );
  }
}

class _ResourceEditorDialog extends StatefulWidget {
  const _ResourceEditorDialog({required this.l10n, this.existing});

  final AppLocalizations l10n;
  final BusinessCatalogResource? existing;

  @override
  State<_ResourceEditorDialog> createState() => _ResourceEditorDialogState();
}

class _ResourceEditorDialogState extends State<_ResourceEditorDialog> {
  late final TextEditingController _nameEn;
  late final TextEditingController _unit;
  late final TextEditingController _total;
  String? _branchId;
  BusinessCatalogResourceType _type = BusinessCatalogResourceType.equipment;
  BusinessCatalogResourceStatus _status = BusinessCatalogResourceStatus.active;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameEn = TextEditingController(text: e?.localized.nameEn ?? '');
    _unit = TextEditingController(text: e?.capacityUnit ?? 'units');
    _total = TextEditingController(
      text: e?.totalCapacity.toString() ?? '1',
    );
    _branchId = e?.branchId;
    _type = e?.type ?? BusinessCatalogResourceType.equipment;
    _status = e?.status ?? BusinessCatalogResourceStatus.active;
    if (_status == BusinessCatalogResourceStatus.archived) {
      _status = BusinessCatalogResourceStatus.active;
    }
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _unit.dispose();
    _total.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = widget.l10n;
    final branchId = _branchId;
    if (branchId == null || branchId.isEmpty) {
      setState(() => _error = l10n.catalogResourceBranchRequired);
      return;
    }
    final total = int.tryParse(_total.text.trim());
    if (total == null || total < 0) {
      setState(() => _error = l10n.catalogResourceCapacityInvalid);
      return;
    }
    final input = BusinessCatalogResourceInput(
      branchId: branchId,
      type: _type,
      capacityUnit: _unit.text,
      localized: BusinessCatalogLocalizedFields(nameEn: _nameEn.text),
      totalCapacity: total,
      status: _status,
    );
    final existing = widget.existing;
    if (existing != null && total < existing.allocatedCapacity) {
      setState(() => _error = l10n.catalogResourceBelowAllocated);
      return;
    }

    final controller = getIt<BusinessCatalogResourceController>();
    final result = existing == null
        ? await controller.createResource(input)
        : await controller.updateResource(existing.resourceId, input);
    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogResourceSaveResult.success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogResourceSaveSuccess)),
      );
      return;
    }
    setState(() => _error = l10n.catalogResourceSaveFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final branches = getIt<BusinessBranchController>().branches;
    final busy = getIt<BusinessCatalogResourceController>().saveBusy;

    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.catalogResourceCreateTitle
            : l10n.catalogResourceEditTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameEn,
              decoration: InputDecoration(labelText: l10n.catalogResourceNameField),
              enabled: !busy,
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _branchId,
              decoration: InputDecoration(
                labelText: l10n.catalogResourceBranchFilter,
              ),
              items: [
                for (final b in branches)
                  DropdownMenuItem(value: b.branchId, child: Text(b.name)),
              ],
              onChanged: busy ? null : (v) => setState(() => _branchId = v),
            ),
            DropdownButtonFormField<BusinessCatalogResourceType>(
              isExpanded: true,
              value: _type,
              decoration: InputDecoration(
                labelText: l10n.catalogResourceTypeFilter,
              ),
              items: [
                for (final t in BusinessCatalogResourceType.values)
                  DropdownMenuItem(value: t, child: Text(t.label(l10n))),
              ],
              onChanged: busy ? null : (v) => setState(() => _type = v!),
            ),
            TextField(
              controller: _unit,
              decoration: InputDecoration(
                labelText: l10n.catalogResourceUnitField,
              ),
              enabled: !busy,
            ),
            TextField(
              controller: _total,
              decoration: InputDecoration(
                labelText: l10n.catalogResourceTotalField,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !busy,
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: busy ? null : _save,
          child: Text(l10n.catalogResourceSaveAction),
        ),
      ],
    );
  }
}

class _CapacityChangeDialog extends StatefulWidget {
  const _CapacityChangeDialog({required this.l10n, required this.resource});

  final AppLocalizations l10n;
  final BusinessCatalogResource resource;

  @override
  State<_CapacityChangeDialog> createState() => _CapacityChangeDialogState();
}

class _CapacityChangeDialogState extends State<_CapacityChangeDialog> {
  late final TextEditingController _total;
  late final TextEditingController _reason;
  String? _error;

  @override
  void initState() {
    super.initState();
    _total = TextEditingController(
      text: widget.resource.totalCapacity.toString(),
    );
    _reason = TextEditingController();
  }

  @override
  void dispose() {
    _total.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = widget.l10n;
    final newTotal = int.tryParse(_total.text.trim());
    if (newTotal == null) {
      setState(() => _error = l10n.catalogResourceCapacityInvalid);
      return;
    }
    final input = BusinessCatalogResourceCapacityChangeInput(
      newTotalCapacity: newTotal,
      reason: _reason.text,
    );
    final validation = catalogResourceCapacityChangeValidationError(
      widget.resource,
      input,
    );
    if (validation != null) {
      setState(() => _error = _validationMessage(l10n, validation));
      return;
    }
    final result = await getIt<BusinessCatalogResourceController>()
        .changeTotalCapacity(
      resourceId: widget.resource.resourceId,
      input: input,
    );
    if (!mounted) {
      return;
    }
    if (result == BusinessCatalogResourceCapacityChangeResult.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogResourceCapacityChangeSuccess)),
      );
      return;
    }
    setState(() => _error = l10n.catalogResourceSaveFailed);
  }

  String _validationMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'below_allocated':
        return l10n.catalogResourceBelowAllocated;
      case 'reason_required':
        return l10n.catalogResourceReasonRequired;
      case 'no_change':
        return l10n.catalogResourceNoCapacityChange;
      default:
        return l10n.catalogResourceCapacityInvalid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final busy = getIt<BusinessCatalogResourceController>().saveBusy;

    return AlertDialog(
      title: Text(l10n.catalogResourceChangeCapacityTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.catalogResourceAllocatedHint(widget.resource.allocatedCapacity)),
          TextField(
            controller: _total,
            decoration: InputDecoration(labelText: l10n.catalogResourceTotalField),
            keyboardType: TextInputType.number,
            enabled: !busy,
          ),
          TextField(
            controller: _reason,
            decoration: InputDecoration(labelText: l10n.catalogResourceReasonField),
            enabled: !busy,
          ),
          if (_error != null)
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: busy ? null : _submit,
          child: Text(l10n.catalogResourceChangeCapacityAction),
        ),
      ],
    );
  }
}
