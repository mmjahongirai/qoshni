import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/routing/route_paths.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_price_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_configuration.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_target_scope.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_fulfillment_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_fulfillment_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_fulfillment_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_price_status_labels.dart';

class BusinessFulfillmentPage extends StatefulWidget {
  const BusinessFulfillmentPage({super.key});

  @override
  State<BusinessFulfillmentPage> createState() => _BusinessFulfillmentPageState();
}

class _BusinessFulfillmentPageState extends State<BusinessFulfillmentPage> {
  String? _branchFilter;
  BusinessFulfillmentType? _typeFilter;
  BusinessCatalogPriceStatus? _statusFilter;
  String? _expandedHistoryId;
  String? _previewConfigurationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessFulfillmentController>().refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessFulfillmentController>();
    final branchController = getIt<BusinessBranchController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.businessFulfillmentListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.saveBusy
            ? null
            : () => _openEditor(context, l10n, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.businessFulfillmentAddAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([controller, branchController]),
          builder: (context, _) {
            if (controller.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = controller.configurations();
            final filtered = controller.configurations(
              branchId: _branchFilter,
              fulfillmentType: _typeFilter,
              status: _statusFilter,
            );
            final previewConfig = _resolvePreview(filtered);

            return ResponsiveLayout(
              phone: _FulfillmentBody(
                maxWidth: 520,
                l10n: l10n,
                configs: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                typeFilter: _typeFilter,
                statusFilter: _statusFilter,
                previewConfig: previewConfig,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: controller.saveBusy,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: controller.historyFor,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onTypeFilterChanged: (v) => setState(() => _typeFilter = v),
                onStatusFilterChanged: (v) => setState(() => _statusFilter = v),
                onSelectPreview: (id) =>
                    setState(() => _previewConfigurationId = id),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onEdit: (c) => _openEditor(context, l10n, c),
                onActivate: (c) => _activate(l10n, c),
                onArchive: (c) => controller.archiveConfiguration(c.configurationId),
              ),
              tablet: _FulfillmentBody(
                maxWidth: 760,
                l10n: l10n,
                configs: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                typeFilter: _typeFilter,
                statusFilter: _statusFilter,
                previewConfig: previewConfig,
                expandedHistoryId: _expandedHistoryId,
                saveBusy: controller.saveBusy,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: controller.historyFor,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onTypeFilterChanged: (v) => setState(() => _typeFilter = v),
                onStatusFilterChanged: (v) => setState(() => _statusFilter = v),
                onSelectPreview: (id) =>
                    setState(() => _previewConfigurationId = id),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onEdit: (c) => _openEditor(context, l10n, c),
                onActivate: (c) => _activate(l10n, c),
                onArchive: (c) => controller.archiveConfiguration(c.configurationId),
              ),
            );
          },
        ),
      ),
    );
  }

  BusinessFulfillmentConfiguration? _resolvePreview(
    List<BusinessFulfillmentConfiguration> filtered,
  ) {
    if (_previewConfigurationId != null) {
      for (final c in filtered) {
        if (c.configurationId == _previewConfigurationId) {
          return c;
        }
      }
    }
    for (final c in filtered) {
      if (c.status == BusinessCatalogPriceStatus.active) {
        return c;
      }
    }
    return filtered.isEmpty ? null : filtered.first;
  }

  Future<void> _activate(
    AppLocalizations l10n,
    BusinessFulfillmentConfiguration config,
  ) async {
    final result = await getIt<BusinessFulfillmentController>()
        .activateConfiguration(config.configurationId);
    if (!mounted) {
      return;
    }
    if (result == BusinessFulfillmentStatusChangeResult.activeTargetConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.businessFulfillmentActivateConflictError)),
      );
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    AppLocalizations l10n,
    BusinessFulfillmentConfiguration? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _FulfillmentEditorDialog(l10n: l10n, existing: existing),
    );
  }
}

class _FulfillmentBody extends StatelessWidget {
  const _FulfillmentBody({
    required this.maxWidth,
    required this.l10n,
    required this.configs,
    required this.allCount,
    required this.branches,
    required this.branchFilter,
    required this.typeFilter,
    required this.statusFilter,
    required this.previewConfig,
    required this.expandedHistoryId,
    required this.saveBusy,
    required this.branchLabel,
    required this.historyFor,
    required this.onBranchFilterChanged,
    required this.onTypeFilterChanged,
    required this.onStatusFilterChanged,
    required this.onSelectPreview,
    required this.onToggleHistory,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessFulfillmentConfiguration> configs;
  final int allCount;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessFulfillmentType? typeFilter;
  final BusinessCatalogPriceStatus? statusFilter;
  final BusinessFulfillmentConfiguration? previewConfig;
  final String? expandedHistoryId;
  final bool saveBusy;
  final String Function(String id) branchLabel;
  final List<BusinessFulfillmentHistoryEvent> Function(String) historyFor;
  final ValueChanged<String?> onBranchFilterChanged;
  final ValueChanged<BusinessFulfillmentType?> onTypeFilterChanged;
  final ValueChanged<BusinessCatalogPriceStatus?> onStatusFilterChanged;
  final ValueChanged<String> onSelectPreview;
  final ValueChanged<String> onToggleHistory;
  final void Function(BusinessFulfillmentConfiguration) onEdit;
  final void Function(BusinessFulfillmentConfiguration) onActivate;
  final void Function(BusinessFulfillmentConfiguration) onArchive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final previewModes = previewConfig == null
        ? l10n.businessFulfillmentPreviewEmpty
        : businessFulfillmentTypesPreviewLabel(
            l10n,
            previewConfig!.supportedFulfillmentTypes,
          );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.businessFulfillmentDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.businessFulfillmentDeliveryTasksBody,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonal(
                      onPressed: saveBusy
                          ? null
                          : () => context.push(RoutePaths.businessDeliveryTasks),
                      child: Text(l10n.businessFulfillmentDeliveryTasksLink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.businessFulfillmentPreviewTitle,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(l10n.businessFulfillmentPreviewSelected(previewModes)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    value: branchFilter,
                    decoration: InputDecoration(
                        labelText: l10n.businessFulfillmentBranchFilter),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text(l10n.businessFulfillmentAllBranches)),
                      for (final b in branches)
                        DropdownMenuItem(value: b.branchId, child: Text(b.name)),
                    ],
                    onChanged: saveBusy ? null : onBranchFilterChanged,
                  ),
                  DropdownButtonFormField<BusinessFulfillmentType?>(
                    isExpanded: true,
                    value: typeFilter,
                    decoration: InputDecoration(
                        labelText: l10n.businessFulfillmentTypeFilter),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text(l10n.businessFulfillmentAllTypes)),
                      for (final t in BusinessFulfillmentType.values)
                        DropdownMenuItem(value: t, child: Text(t.label(l10n))),
                    ],
                    onChanged: saveBusy ? null : onTypeFilterChanged,
                  ),
                  DropdownButtonFormField<BusinessCatalogPriceStatus?>(
                    isExpanded: true,
                    value: statusFilter,
                    decoration: InputDecoration(
                        labelText: l10n.businessFulfillmentStatusFilter),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text(l10n.businessFulfillmentAllStatuses)),
                      for (final s in BusinessCatalogPriceStatus.values)
                        if (s != BusinessCatalogPriceStatus.archived)
                          DropdownMenuItem(value: s, child: Text(s.label(l10n))),
                    ],
                    onChanged: saveBusy ? null : onStatusFilterChanged,
                  ),
                  Text(l10n.catalogListingFilteredCount(configs.length, allCount),
                      style: textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (configs.isEmpty)
              AppSurfaceCard(child: Text(l10n.businessFulfillmentEmptyBody))
            else
              for (final c in configs) ...[
                _ConfigCard(
                  l10n: l10n,
                  config: c,
                  branchName: branchLabel(c.branchId),
                  isPreviewSelected:
                      previewConfig?.configurationId == c.configurationId,
                  historyExpanded: expandedHistoryId == c.configurationId,
                  history: historyFor(c.configurationId),
                  saveBusy: saveBusy,
                  onSelectPreview: () => onSelectPreview(c.configurationId),
                  onToggleHistory: () => onToggleHistory(c.configurationId),
                  onEdit: () => onEdit(c),
                  onActivate: () => onActivate(c),
                  onArchive: () => onArchive(c),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.l10n,
    required this.config,
    required this.branchName,
    required this.isPreviewSelected,
    required this.historyExpanded,
    required this.history,
    required this.saveBusy,
    required this.onSelectPreview,
    required this.onToggleHistory,
    required this.onEdit,
    required this.onActivate,
    required this.onArchive,
  });

  final AppLocalizations l10n;
  final BusinessFulfillmentConfiguration config;
  final String branchName;
  final bool isPreviewSelected;
  final bool historyExpanded;
  final List<BusinessFulfillmentHistoryEvent> history;
  final bool saveBusy;
  final VoidCallback onSelectPreview;
  final VoidCallback onToggleHistory;
  final VoidCallback onEdit;
  final VoidCallback onActivate;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final modes = businessFulfillmentTypesPreviewLabel(
      l10n,
      config.supportedFulfillmentTypes,
    );
    return AppSurfaceCard(
      onTap: saveBusy ? null : onSelectPreview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPreviewSelected)
            Text(l10n.businessFulfillmentPreviewTitle,
                style: Theme.of(context).textTheme.labelSmall),
          Text(config.targetScope.label(l10n),
              style: Theme.of(context).textTheme.titleSmall),
          if (config.listingId != null) Text(config.listingId!),
          Text(l10n.businessFulfillmentTypesLabel(modes)),
          Text(branchName),
          Text(config.status.label(l10n)),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (config.status == BusinessCatalogPriceStatus.draft)
                FilledButton.tonal(
                    onPressed: saveBusy ? null : onEdit,
                    child: Text(l10n.businessFulfillmentEditAction)),
              if (config.status == BusinessCatalogPriceStatus.draft)
                FilledButton(
                    onPressed: saveBusy ? null : onActivate,
                    child: Text(l10n.businessFulfillmentActivateAction)),
              if (config.status == BusinessCatalogPriceStatus.active)
                OutlinedButton(
                    onPressed: saveBusy ? null : onArchive,
                    child: Text(l10n.businessFulfillmentArchiveAction)),
              TextButton(
                  onPressed: saveBusy ? null : onToggleHistory,
                  child: Text(historyExpanded
                      ? l10n.businessFulfillmentHideHistoryAction
                      : l10n.businessFulfillmentShowHistoryAction)),
            ],
          ),
          if (historyExpanded)
            for (final e in history)
              Text('${e.action.name} rev ${e.newRevision ?? ''}'),
        ],
      ),
    );
  }
}

class _FulfillmentEditorDialog extends StatefulWidget {
  const _FulfillmentEditorDialog({required this.l10n, required this.existing});
  final AppLocalizations l10n;
  final BusinessFulfillmentConfiguration? existing;

  @override
  State<_FulfillmentEditorDialog> createState() =>
      _FulfillmentEditorDialogState();
}

class _FulfillmentEditorDialogState extends State<_FulfillmentEditorDialog> {
  String? _branchId = kDemoBranchTashkentCenterId;
  BusinessFulfillmentTargetScope _scope =
      BusinessFulfillmentTargetScope.businessWide;
  late TextEditingController _listingController;
  final Set<BusinessFulfillmentType> _types = {};
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _branchId = e.branchId;
      _scope = e.targetScope;
      _types.addAll(e.supportedFulfillmentTypes);
    } else {
      _types.addAll([
        BusinessFulfillmentType.delivery,
        BusinessFulfillmentType.pickup,
      ]);
    }
    _listingController = TextEditingController(text: e?.listingId ?? '');
  }

  @override
  void dispose() {
    _listingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final controller = getIt<BusinessFulfillmentController>();
    final branchController = getIt<BusinessBranchController>();

    return AlertDialog(
      title: Text(widget.existing == null
          ? l10n.businessFulfillmentCreateTitle
          : l10n.businessFulfillmentEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorKey != null)
              Text(l10n.businessFulfillmentSaveFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _branchId,
              items: [
                for (final b in branchController.branches)
                  DropdownMenuItem(value: b.branchId, child: Text(b.name)),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) => setState(() => _branchId = v),
            ),
            DropdownButtonFormField<BusinessFulfillmentTargetScope>(
              isExpanded: true,
              value: _scope,
              items: [
                for (final s in BusinessFulfillmentTargetScope.values)
                  DropdownMenuItem(value: s, child: Text(s.label(l10n))),
              ],
              onChanged: controller.saveBusy
                  ? null
                  : (v) => setState(() => _scope = v ?? _scope),
            ),
            if (_scope != BusinessFulfillmentTargetScope.businessWide)
              TextField(
                controller: _listingController,
                decoration: InputDecoration(
                    labelText: l10n.businessFulfillmentListingIdField),
              ),
            Text(l10n.businessFulfillmentTypesField),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final t in BusinessFulfillmentType.values)
                  FilterChip(
                    label: Text(t.label(l10n)),
                    selected: _types.contains(t),
                    onSelected: controller.saveBusy
                        ? null
                        : (selected) {
                            setState(() {
                              if (selected) {
                                _types.add(t);
                              } else {
                                _types.remove(t);
                              }
                            });
                          },
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: controller.saveBusy ? null : () => Navigator.pop(context),
          child: Text(l10n.catalogPricingCancelAction),
        ),
        FilledButton(
          onPressed: controller.saveBusy ? null : _save,
          child: Text(l10n.catalogPricingSaveAction),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_types.isEmpty) {
      setState(() => _errorKey = 'empty');
      return;
    }
    final branchId = _branchId?.trim();
    if (branchId == null || branchId.isEmpty) {
      setState(() => _errorKey = 'branch');
      return;
    }
    final input = BusinessFulfillmentConfigurationInput(
      branchId: branchId,
      targetScope: _scope,
      listingId: _scope == BusinessFulfillmentTargetScope.businessWide
          ? null
          : _listingController.text.trim(),
      supportedFulfillmentTypes: _types.toList(),
    );

    final ctrl = getIt<BusinessFulfillmentController>();
    final existing = widget.existing;
    final result = existing == null
        ? await ctrl.createDraft(input)
        : existing.status == BusinessCatalogPriceStatus.draft
            ? await ctrl.updateDraft(
                configurationId: existing.configurationId,
                input: input,
              )
            : BusinessFulfillmentSaveResult.activeImmutable;

    if (!mounted) {
      return;
    }
    if (result == BusinessFulfillmentSaveResult.success) {
      Navigator.pop(context);
      return;
    }
    setState(() => _errorKey = result.name);
  }
}
