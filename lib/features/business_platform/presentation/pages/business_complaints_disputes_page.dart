import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_complaint_demo_evidence.dart';
import 'package:qoshni/features/business_platform/data/business_complaint_dispute_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_category.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_complaint_status.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_dispute_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_complaint_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_dispute_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_service_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_complaint_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_complaint_dispute_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_complaint_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_dispute_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_dispute_transitions.dart';

class BusinessComplaintsDisputesPage extends StatefulWidget {
  const BusinessComplaintsDisputesPage({super.key});

  @override
  State<BusinessComplaintsDisputesPage> createState() =>
      _BusinessComplaintsDisputesPageState();
}

class _BusinessComplaintsDisputesPageState
    extends State<BusinessComplaintsDisputesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String? _branchFilter;
  BusinessComplaintCategory? _categoryFilter;
  BusinessComplaintStatus? _complaintStatusFilter;
  BusinessDisputeStatus? _disputeStatusFilter;
  String? _expandedComplaintHistoryId;
  String? _expandedDisputeHistoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessComplaintController>().refreshList();
      getIt<BusinessDisputeController>().refreshList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final complaintController = getIt<BusinessComplaintController>();
    final disputeController = getIt<BusinessDisputeController>();
    final branchController = getIt<BusinessBranchController>();
    final productController = getIt<BusinessCatalogProductController>();
    final serviceController = getIt<BusinessCatalogServiceController>();

    String targetLabel(BusinessComplaint c) {
      switch (c.targetType) {
        case BusinessReviewTargetType.business:
          return l10n.businessReviewTargetBusinessScope;
        case BusinessReviewTargetType.product:
          final p = productController.productById(c.targetId);
          return p?.displayName(l10n) ?? c.targetId;
        case BusinessReviewTargetType.service:
          final s = serviceController.serviceById(c.targetId);
          return s?.displayName(l10n) ?? c.targetId;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.businessComplaintDisputeListTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.businessComplaintTab),
            Tab(text: l10n.businessDisputeTab),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          final onComplaintsTab = _tabController.index == 0;
          return FloatingActionButton.extended(
            onPressed: complaintController.saveBusy || disputeController.saveBusy
                ? null
                : () {
                    if (onComplaintsTab) {
                      _openCreateComplaintDialog(
                        context,
                        l10n,
                        complaintController,
                      );
                    } else {
                      _openCreateDisputeDialog(
                        context,
                        l10n,
                        complaintController,
                        disputeController,
                      );
                    }
                  },
            icon: Icon(
              onComplaintsTab
                  ? Icons.report_outlined
                  : Icons.gavel_outlined,
            ),
            label: Text(
              onComplaintsTab
                  ? l10n.businessComplaintCreateDemoAction
                  : l10n.businessDisputeCreateDemoAction,
            ),
          );
        },
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            complaintController,
            disputeController,
            branchController,
            productController,
            serviceController,
          ]),
          builder: (context, _) {
            if (complaintController.listLoading ||
                disputeController.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final complaints = complaintController.complaints(
              branchId: _branchFilter,
              category: _categoryFilter,
              status: _complaintStatusFilter,
            );
            final disputes = disputeController.disputes(
              branchId: _branchFilter,
              status: _disputeStatusFilter,
            );

            return ResponsiveLayout(
              phone: _Body(
                maxWidth: 520,
                l10n: l10n,
                tabController: _tabController,
                complaints: complaints,
                disputes: disputes,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                categoryFilter: _categoryFilter,
                complaintStatusFilter: _complaintStatusFilter,
                disputeStatusFilter: _disputeStatusFilter,
                saveBusy:
                    complaintController.saveBusy || disputeController.saveBusy,
                expandedComplaintHistoryId: _expandedComplaintHistoryId,
                expandedDisputeHistoryId: _expandedDisputeHistoryId,
                targetLabel: targetLabel,
                disputeFor: disputeController.disputeForComplaint,
                complaintHistory: complaintController.historyFor,
                disputeHistory: disputeController.historyFor,
                onClearFilters: () => setState(() {
                  _branchFilter = null;
                  _categoryFilter = null;
                  _complaintStatusFilter = null;
                  _disputeStatusFilter = null;
                }),
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onCategoryChanged: (v) => setState(() => _categoryFilter = v),
                onComplaintStatusChanged: (v) =>
                    setState(() => _complaintStatusFilter = v),
                onDisputeStatusChanged: (v) =>
                    setState(() => _disputeStatusFilter = v),
                onToggleComplaintHistory: (id) => setState(() {
                  _expandedComplaintHistoryId =
                      _expandedComplaintHistoryId == id ? null : id;
                }),
                onToggleDisputeHistory: (id) => setState(() {
                  _expandedDisputeHistoryId =
                      _expandedDisputeHistoryId == id ? null : id;
                }),
                onComplaintAction: (c, target) => _complaintTransition(
                  context,
                  l10n,
                  complaintController,
                  c,
                  target,
                ),
                onDisputeAction: (d, target) => _disputeTransition(
                  context,
                  l10n,
                  disputeController,
                  d,
                  target,
                ),
              ),
              tablet: _Body(
                maxWidth: 720,
                l10n: l10n,
                tabController: _tabController,
                complaints: complaints,
                disputes: disputes,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                categoryFilter: _categoryFilter,
                complaintStatusFilter: _complaintStatusFilter,
                disputeStatusFilter: _disputeStatusFilter,
                saveBusy:
                    complaintController.saveBusy || disputeController.saveBusy,
                expandedComplaintHistoryId: _expandedComplaintHistoryId,
                expandedDisputeHistoryId: _expandedDisputeHistoryId,
                targetLabel: targetLabel,
                disputeFor: disputeController.disputeForComplaint,
                complaintHistory: complaintController.historyFor,
                disputeHistory: disputeController.historyFor,
                onClearFilters: () => setState(() {
                  _branchFilter = null;
                  _categoryFilter = null;
                  _complaintStatusFilter = null;
                  _disputeStatusFilter = null;
                }),
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onCategoryChanged: (v) => setState(() => _categoryFilter = v),
                onComplaintStatusChanged: (v) =>
                    setState(() => _complaintStatusFilter = v),
                onDisputeStatusChanged: (v) =>
                    setState(() => _disputeStatusFilter = v),
                onToggleComplaintHistory: (id) => setState(() {
                  _expandedComplaintHistoryId =
                      _expandedComplaintHistoryId == id ? null : id;
                }),
                onToggleDisputeHistory: (id) => setState(() {
                  _expandedDisputeHistoryId =
                      _expandedDisputeHistoryId == id ? null : id;
                }),
                onComplaintAction: (c, target) => _complaintTransition(
                  context,
                  l10n,
                  complaintController,
                  c,
                  target,
                ),
                onDisputeAction: (d, target) => _disputeTransition(
                  context,
                  l10n,
                  disputeController,
                  d,
                  target,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _complaintTransition(
    BuildContext context,
    AppLocalizations l10n,
    BusinessComplaintController controller,
    BusinessComplaint complaint,
    BusinessComplaintStatus target,
  ) async {
    String? note;
    if (target == BusinessComplaintStatus.resolved ||
        target == BusinessComplaintStatus.dismissed) {
      note = await _reasonDialog(context, l10n);
      if (note == null) {
        return;
      }
    }
    await controller.applyTransition(
      complaintId: complaint.complaintId,
      request: BusinessComplaintTransitionRequest(
        targetStatus: target,
        resolutionNote: note,
      ),
    );
  }

  Future<void> _disputeTransition(
    BuildContext context,
    AppLocalizations l10n,
    BusinessDisputeController controller,
    BusinessDispute dispute,
    BusinessDisputeStatus target,
  ) async {
    String? note;
    if (target == BusinessDisputeStatus.resolvedForBusiness ||
        target == BusinessDisputeStatus.resolvedForReporter ||
        target == BusinessDisputeStatus.dismissed) {
      note = await _reasonDialog(context, l10n);
      if (note == null) {
        return;
      }
    }
    await controller.applyTransition(
      disputeId: dispute.disputeId,
      request: BusinessDisputeTransitionRequest(
        targetStatus: target,
        resolutionNote: note,
      ),
    );
  }

  Future<String?> _reasonDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final c = TextEditingController(text: 'Demo resolution note');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.businessReviewModerationReasonTitle),
        content: TextField(
          controller: c,
          decoration: InputDecoration(
            labelText: l10n.businessReviewModerationReasonLabel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.businessReviewDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: Text(l10n.businessReviewDialogConfirm),
          ),
        ],
      ),
    );
    c.dispose();
    return result;
  }

  Future<void> _openCreateComplaintDialog(
    BuildContext context,
    AppLocalizations l10n,
    BusinessComplaintController controller,
  ) async {
    var category = BusinessComplaintCategory.productQuality;
    final descriptionController = TextEditingController(
      text: 'Demo synthetic complaint description.',
    );
    var errorMessage = '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.businessComplaintCreateDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.businessComplaintSyntheticEvidenceNote),
                    DropdownButtonFormField<BusinessComplaintCategory>(
                      isExpanded: true,
                      initialValue: category,
                      decoration: InputDecoration(
                        labelText: l10n.businessComplaintCategoryFilter,
                      ),
                      items: [
                        for (final cat in BusinessComplaintCategory.values)
                          DropdownMenuItem(
                            value: cat,
                            child: Text(l10n.businessComplaintCategoryLabel(cat)),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => category = v);
                        }
                      },
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.businessComplaintDescriptionField,
                      ),
                      maxLines: 3,
                    ),
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.businessReviewDialogCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final result = await controller.createComplaint(
                      BusinessComplaintCreateInput(
                        targetType: BusinessReviewTargetType.product,
                        targetId: kDemoCatalogProductBreadId,
                        demoReporterReference: kDemoComplaintReporterA,
                        category: category,
                        description: descriptionController.text,
                        syntheticEvidenceReferences: const [
                          kDemoComplaintEvidenceSessionCreate,
                        ],
                      ),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    switch (result) {
                      case BusinessComplaintCreateResult.success:
                        Navigator.pop(context);
                      case BusinessComplaintCreateResult.failure:
                        setDialogState(() {
                          errorMessage = l10n.businessComplaintSaveError;
                        });
                      default:
                        setDialogState(() {
                          errorMessage = l10n.businessReviewValidationError;
                        });
                    }
                  },
                  child: Text(l10n.businessReviewDialogSave),
                ),
              ],
            );
          },
        );
      },
    );
    descriptionController.dispose();
  }

  Future<void> _openCreateDisputeDialog(
    BuildContext context,
    AppLocalizations l10n,
    BusinessComplaintController complaintController,
    BusinessDisputeController disputeController,
  ) async {
    final eligible = complaintController
        .complaints()
        .where(
          (c) =>
              c.status == BusinessComplaintStatus.submitted ||
              c.status == BusinessComplaintStatus.underReview,
        )
        .where(
          (c) => disputeController.disputeForComplaint(c.complaintId) == null,
        )
        .toList();
    if (eligible.isEmpty) {
      eligible.add(
        complaintController.complaints().firstWhere(
              (c) => c.complaintId == kDemoComplaintSubmittedId,
              orElse: () => complaintController.complaints().first,
            ),
      );
    }

    var complaintId = eligible.first.complaintId;
    final summaryController = TextEditingController(
      text: 'Demo dispute summary — synthetic only.',
    );
    var errorMessage = '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.businessDisputeCreateDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.businessComplaintSyntheticEvidenceNote),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: complaintId,
                      decoration: InputDecoration(
                        labelText: l10n.businessComplaintSelectComplaintField,
                      ),
                      items: [
                        for (final c in eligible)
                          DropdownMenuItem(
                            value: c.complaintId,
                            child: Text(c.complaintId),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => complaintId = v);
                        }
                      },
                    ),
                    TextField(
                      controller: summaryController,
                      decoration: InputDecoration(
                        labelText: l10n.businessDisputeSummaryField,
                      ),
                      maxLines: 2,
                    ),
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.businessReviewDialogCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final result = await disputeController.createDispute(
                      BusinessDisputeCreateInput(
                        complaintId: complaintId,
                        demoBusinessInitiatorReference:
                            kDemoDisputeBusinessInitiator,
                        summary: summaryController.text,
                        syntheticEvidenceReferences: const [
                          kDemoDisputeEvidenceSessionCreate,
                        ],
                      ),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    switch (result) {
                      case BusinessDisputeCreateResult.success:
                        Navigator.pop(context);
                      case BusinessDisputeCreateResult.duplicateForComplaint:
                        setDialogState(() {
                          errorMessage = l10n.businessDisputeDuplicateError;
                        });
                      case BusinessDisputeCreateResult.failure:
                        setDialogState(() {
                          errorMessage = l10n.businessDisputeSaveError;
                        });
                      default:
                        setDialogState(() {
                          errorMessage = l10n.businessReviewValidationError;
                        });
                    }
                  },
                  child: Text(l10n.businessReviewDialogSave),
                ),
              ],
            );
          },
        );
      },
    );
    summaryController.dispose();
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.maxWidth,
    required this.l10n,
    required this.tabController,
    required this.complaints,
    required this.disputes,
    required this.branches,
    required this.branchFilter,
    required this.categoryFilter,
    required this.complaintStatusFilter,
    required this.disputeStatusFilter,
    required this.saveBusy,
    required this.expandedComplaintHistoryId,
    required this.expandedDisputeHistoryId,
    required this.targetLabel,
    required this.disputeFor,
    required this.complaintHistory,
    required this.disputeHistory,
    required this.onClearFilters,
    required this.onBranchChanged,
    required this.onCategoryChanged,
    required this.onComplaintStatusChanged,
    required this.onDisputeStatusChanged,
    required this.onToggleComplaintHistory,
    required this.onToggleDisputeHistory,
    required this.onComplaintAction,
    required this.onDisputeAction,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final TabController tabController;
  final List<BusinessComplaint> complaints;
  final List<BusinessDispute> disputes;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessComplaintCategory? categoryFilter;
  final BusinessComplaintStatus? complaintStatusFilter;
  final BusinessDisputeStatus? disputeStatusFilter;
  final bool saveBusy;
  final String? expandedComplaintHistoryId;
  final String? expandedDisputeHistoryId;
  final String Function(BusinessComplaint) targetLabel;
  final BusinessDispute? Function(String) disputeFor;
  final List<BusinessComplaintHistoryEvent> Function(String) complaintHistory;
  final List<BusinessDisputeHistoryEvent> Function(String) disputeHistory;
  final VoidCallback onClearFilters;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<BusinessComplaintCategory?> onCategoryChanged;
  final ValueChanged<BusinessComplaintStatus?> onComplaintStatusChanged;
  final ValueChanged<BusinessDisputeStatus?> onDisputeStatusChanged;
  final ValueChanged<String> onToggleComplaintHistory;
  final ValueChanged<String> onToggleDisputeHistory;
  final void Function(BusinessComplaint, BusinessComplaintStatus)
      onComplaintAction;
  final void Function(BusinessDispute, BusinessDisputeStatus) onDisputeAction;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: TabBarView(
          controller: tabController,
          children: [
            _ComplaintsTab(
              l10n: l10n,
              complaints: complaints,
              branches: branches,
              branchFilter: branchFilter,
              categoryFilter: categoryFilter,
              statusFilter: complaintStatusFilter,
              saveBusy: saveBusy,
              expandedHistoryId: expandedComplaintHistoryId,
              targetLabel: targetLabel,
              disputeFor: disputeFor,
              historyFor: complaintHistory,
              onClearFilters: onClearFilters,
              onBranchChanged: onBranchChanged,
              onCategoryChanged: onCategoryChanged,
              onStatusChanged: onComplaintStatusChanged,
              onToggleHistory: onToggleComplaintHistory,
              onAction: onComplaintAction,
            ),
            _DisputesTab(
              l10n: l10n,
              disputes: disputes,
              branches: branches,
              branchFilter: branchFilter,
              statusFilter: disputeStatusFilter,
              saveBusy: saveBusy,
              expandedHistoryId: expandedDisputeHistoryId,
              historyFor: disputeHistory,
              onClearFilters: onClearFilters,
              onBranchChanged: onBranchChanged,
              onStatusChanged: onDisputeStatusChanged,
              onToggleHistory: onToggleDisputeHistory,
              onAction: onDisputeAction,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintsTab extends StatelessWidget {
  const _ComplaintsTab({
    required this.l10n,
    required this.complaints,
    required this.branches,
    required this.branchFilter,
    required this.categoryFilter,
    required this.statusFilter,
    required this.saveBusy,
    required this.expandedHistoryId,
    required this.targetLabel,
    required this.disputeFor,
    required this.historyFor,
    required this.onClearFilters,
    required this.onBranchChanged,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onToggleHistory,
    required this.onAction,
  });

  final AppLocalizations l10n;
  final List<BusinessComplaint> complaints;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessComplaintCategory? categoryFilter;
  final BusinessComplaintStatus? statusFilter;
  final bool saveBusy;
  final String? expandedHistoryId;
  final String Function(BusinessComplaint) targetLabel;
  final BusinessDispute? Function(String) disputeFor;
  final List<BusinessComplaintHistoryEvent> Function(String) historyFor;
  final VoidCallback onClearFilters;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<BusinessComplaintCategory?> onCategoryChanged;
  final ValueChanged<BusinessComplaintStatus?> onStatusChanged;
  final ValueChanged<String> onToggleHistory;
  final void Function(BusinessComplaint, BusinessComplaintStatus) onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppMessageBanner(
          message: l10n.businessComplaintDisputeDemoDisclaimer,
          icon: Icons.info_outline,
          tone: AppMessageTone.info,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.businessComplaintDisputeDemoResolutionNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _FilterRow(
          l10n: l10n,
          branchFilter: branchFilter,
          branches: branches,
          onBranchChanged: onBranchChanged,
          onClearFilters: onClearFilters,
          extra: [
            DropdownButtonFormField<BusinessComplaintCategory?>(
              isExpanded: true,
              initialValue: categoryFilter,
              decoration: InputDecoration(
                labelText: l10n.businessComplaintCategoryFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.businessComplaintAllCategories),
                ),
                for (final c in BusinessComplaintCategory.values)
                  DropdownMenuItem(
                    value: c,
                    child: Text(l10n.businessComplaintCategoryLabel(c)),
                  ),
              ],
              onChanged: onCategoryChanged,
            ),
            DropdownButtonFormField<BusinessComplaintStatus?>(
              isExpanded: true,
              initialValue: statusFilter,
              decoration: InputDecoration(
                labelText: l10n.businessReviewStatusFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.businessReviewAllStatuses),
                ),
                for (final s in BusinessComplaintStatus.values)
                  DropdownMenuItem(
                    value: s,
                    child: Text(l10n.businessComplaintStatusLabel(s)),
                  ),
              ],
              onChanged: onStatusChanged,
            ),
          ],
        ),
        if (complaints.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Text(l10n.businessComplaintEmptyBody),
          ),
        for (final c in complaints) ...[
          const SizedBox(height: AppSpacing.md),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.businessComplaintCardLine(
                    targetLabel(c),
                    l10n.businessComplaintCategoryLabel(c.category),
                    l10n.businessComplaintStatusLabel(c.status),
                  ),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(c.description),
                const SizedBox(height: 4),
                Text(
                  l10n.businessComplaintEvidenceLine(
                    c.syntheticEvidenceReferences.join(', '),
                    c.demoReporterReference,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  l10n.businessComplaintSyntheticBadge,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Builder(
                  builder: (context) {
                    final linked = disputeFor(c.complaintId);
                    return Text(
                      linked != null
                          ? l10n.businessComplaintLinkedDispute(linked.disputeId)
                          : l10n.businessComplaintNoDispute,
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    if (catalogBusinessComplaintTransitionAllowed(
                      from: c.status,
                      to: BusinessComplaintStatus.underReview,
                    ))
                      TextButton(
                        onPressed: saveBusy
                            ? null
                            : () => onAction(
                                  c,
                                  BusinessComplaintStatus.underReview,
                                ),
                        child: Text(l10n.businessComplaintActionBeginReview),
                      ),
                    if (catalogBusinessComplaintTransitionAllowed(
                      from: c.status,
                      to: BusinessComplaintStatus.resolved,
                    ))
                      TextButton(
                        onPressed: saveBusy
                            ? null
                            : () => onAction(
                                  c,
                                  BusinessComplaintStatus.resolved,
                                ),
                        child: Text(l10n.businessComplaintActionResolve),
                      ),
                    if (catalogBusinessComplaintTransitionAllowed(
                      from: c.status,
                      to: BusinessComplaintStatus.dismissed,
                    ))
                      TextButton(
                        onPressed: saveBusy
                            ? null
                            : () => onAction(
                                  c,
                                  BusinessComplaintStatus.dismissed,
                                ),
                        child: Text(l10n.businessComplaintActionDismiss),
                      ),
                    TextButton(
                      onPressed: () => onToggleHistory(c.complaintId),
                      child: Text(l10n.businessComplaintHistoryAction),
                    ),
                  ],
                ),
                if (expandedHistoryId == c.complaintId)
                  for (final e in historyFor(c.complaintId))
                    Text(
                      l10n.businessComplaintHistoryLine(
                        e.previousStatus != null
                            ? l10n.businessComplaintStatusLabel(
                                e.previousStatus!,
                              )
                            : '—',
                        l10n.businessComplaintStatusLabel(e.newStatus),
                        e.recordedAt.toIso8601String(),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DisputesTab extends StatelessWidget {
  const _DisputesTab({
    required this.l10n,
    required this.disputes,
    required this.branches,
    required this.branchFilter,
    required this.statusFilter,
    required this.saveBusy,
    required this.expandedHistoryId,
    required this.historyFor,
    required this.onClearFilters,
    required this.onBranchChanged,
    required this.onStatusChanged,
    required this.onToggleHistory,
    required this.onAction,
  });

  final AppLocalizations l10n;
  final List<BusinessDispute> disputes;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessDisputeStatus? statusFilter;
  final bool saveBusy;
  final String? expandedHistoryId;
  final List<BusinessDisputeHistoryEvent> Function(String) historyFor;
  final VoidCallback onClearFilters;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<BusinessDisputeStatus?> onStatusChanged;
  final ValueChanged<String> onToggleHistory;
  final void Function(BusinessDispute, BusinessDisputeStatus) onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppMessageBanner(
          message: l10n.businessComplaintDisputeDemoDisclaimer,
          icon: Icons.info_outline,
          tone: AppMessageTone.info,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.businessComplaintDisputeDemoResolutionNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _FilterRow(
          l10n: l10n,
          branchFilter: branchFilter,
          branches: branches,
          onBranchChanged: onBranchChanged,
          onClearFilters: onClearFilters,
          extra: [
            DropdownButtonFormField<BusinessDisputeStatus?>(
              isExpanded: true,
              initialValue: statusFilter,
              decoration: InputDecoration(
                labelText: l10n.businessReviewStatusFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.businessReviewAllStatuses),
                ),
                for (final s in BusinessDisputeStatus.values)
                  DropdownMenuItem(
                    value: s,
                    child: Text(l10n.businessDisputeStatusLabel(s)),
                  ),
              ],
              onChanged: onStatusChanged,
            ),
          ],
        ),
        if (disputes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Text(l10n.businessDisputeEmptyBody),
          ),
        for (final d in disputes) ...[
          const SizedBox(height: AppSpacing.md),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.businessDisputeCardLine(
                    d.complaintId,
                    l10n.businessDisputeStatusLabel(d.status),
                  ),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(d.summary),
                Text(
                  l10n.businessComplaintEvidenceLine(
                    d.syntheticEvidenceReferences.join(', '),
                    d.demoBusinessInitiatorReference,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    if (catalogBusinessDisputeTransitionAllowed(
                      from: d.status,
                      to: BusinessDisputeStatus.underReview,
                    ))
                      TextButton(
                        onPressed: saveBusy
                            ? null
                            : () => onAction(
                                  d,
                                  BusinessDisputeStatus.underReview,
                                ),
                        child: Text(l10n.businessDisputeActionBeginReview),
                      ),
                    if (catalogBusinessDisputeTransitionAllowed(
                      from: d.status,
                      to: BusinessDisputeStatus.resolvedForBusiness,
                    ))
                      TextButton(
                        onPressed: saveBusy
                            ? null
                            : () => onAction(
                                  d,
                                  BusinessDisputeStatus.resolvedForBusiness,
                                ),
                        child: Text(l10n.businessDisputeActionResolveBusiness),
                      ),
                    if (catalogBusinessDisputeTransitionAllowed(
                      from: d.status,
                      to: BusinessDisputeStatus.resolvedForReporter,
                    ))
                      TextButton(
                        onPressed: saveBusy
                            ? null
                            : () => onAction(
                                  d,
                                  BusinessDisputeStatus.resolvedForReporter,
                                ),
                        child: Text(
                          l10n.businessDisputeActionResolveReporter,
                        ),
                      ),
                    if (catalogBusinessDisputeTransitionAllowed(
                      from: d.status,
                      to: BusinessDisputeStatus.dismissed,
                    ))
                      TextButton(
                        onPressed: saveBusy
                            ? null
                            : () => onAction(
                                  d,
                                  BusinessDisputeStatus.dismissed,
                                ),
                        child: Text(l10n.businessDisputeActionDismiss),
                      ),
                    TextButton(
                      onPressed: () => onToggleHistory(d.disputeId),
                      child: Text(l10n.businessDisputeHistoryAction),
                    ),
                  ],
                ),
                if (expandedHistoryId == d.disputeId)
                  for (final e in historyFor(d.disputeId))
                    Text(
                      l10n.businessDisputeHistoryLine(
                        e.previousStatus != null
                            ? l10n.businessDisputeStatusLabel(
                                e.previousStatus!,
                              )
                            : '—',
                        l10n.businessDisputeStatusLabel(e.newStatus),
                        e.recordedAt.toIso8601String(),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.l10n,
    required this.branchFilter,
    required this.branches,
    required this.onBranchChanged,
    required this.onClearFilters,
    required this.extra,
  });

  final AppLocalizations l10n;
  final String? branchFilter;
  final List<BusinessBranch> branches;
  final ValueChanged<String?> onBranchChanged;
  final VoidCallback onClearFilters;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String?>(
          isExpanded: true,
          initialValue: branchFilter,
          decoration: InputDecoration(labelText: l10n.businessReviewBranchFilter),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(l10n.businessReviewAllBranches),
            ),
            for (final b in branches)
              DropdownMenuItem(
                value: b.branchId,
                child: Text(b.name),
              ),
          ],
          onChanged: onBranchChanged,
        ),
        ...extra,
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onClearFilters,
            child: Text(l10n.businessComplaintClearFilters),
          ),
        ),
      ],
    );
  }
}
