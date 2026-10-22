import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_task_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_exception_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_proof_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_task_controller.dart';
import 'package:qoshni/features/business_platform/presentation/widgets/business_delivery_task_exception_proof_panel.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_task_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_task_transitions.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_task_validation.dart';

class BusinessDeliveryTaskPage extends StatefulWidget {
  const BusinessDeliveryTaskPage({super.key});

  @override
  State<BusinessDeliveryTaskPage> createState() =>
      _BusinessDeliveryTaskPageState();
}

class _BusinessDeliveryTaskPageState extends State<BusinessDeliveryTaskPage> {
  String? _branchFilter;
  BusinessDeliveryTaskStatus? _statusFilter;
  String? _expandedHistoryId;
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessDeliveryTaskController>().refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final taskController = getIt<BusinessDeliveryTaskController>();
    final exceptionController = getIt<BusinessDeliveryExceptionController>();
    final proofController = getIt<BusinessDeliveryProofController>();
    final branchController = getIt<BusinessBranchController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.businessDeliveryTaskListTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            taskController,
            exceptionController,
            proofController,
            branchController,
          ]),
          builder: (context, _) {
            if (taskController.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = taskController.tasks();
            final filtered = taskController.tasks(
              branchId: _branchFilter,
              status: _statusFilter,
            );

            return ResponsiveLayout(
              phone: _DeliveryTaskBody(
                maxWidth: 520,
                l10n: l10n,
                tasks: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                transitionBusy: taskController.transitionBusy ||
                    exceptionController.saveBusy ||
                    proofController.saveBusy,
                errorMessage: _lastErrorMessage,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: taskController.historyFor,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onStatusFilterChanged: (v) =>
                    setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onTransition: (task, target) =>
                    _handleTransition(context, l10n, task, target),
              ),
              tablet: _DeliveryTaskBody(
                maxWidth: 720,
                l10n: l10n,
                tasks: filtered,
                allCount: all.length,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                statusFilter: _statusFilter,
                expandedHistoryId: _expandedHistoryId,
                transitionBusy: taskController.transitionBusy ||
                    exceptionController.saveBusy ||
                    proofController.saveBusy,
                errorMessage: _lastErrorMessage,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: taskController.historyFor,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onStatusFilterChanged: (v) =>
                    setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onTransition: (task, target) =>
                    _handleTransition(context, l10n, task, target),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleTransition(
    BuildContext context,
    AppLocalizations l10n,
    BusinessDeliveryTask task,
    BusinessDeliveryTaskStatus target,
  ) async {
    setState(() => _lastErrorMessage = null);

    String? failureReason;
    if (target == BusinessDeliveryTaskStatus.failed) {
      failureReason = await _promptFailureReason(context, l10n);
      if (failureReason == null) {
        return;
      }
      final validation =
          catalogDeliveryTaskFailureReasonValidationError(failureReason);
      if (validation != null) {
        setState(() => _lastErrorMessage = l10n.businessDeliveryTaskFailureReasonInvalid);
        return;
      }
    }

    final controller = getIt<BusinessDeliveryTaskController>();
    final beforeStatus = task.status;
    final result = await controller.applyTransition(
      deliveryTaskId: task.deliveryTaskId,
      request: BusinessDeliveryTaskTransitionRequest(
        targetStatus: target,
        failureReason: failureReason,
      ),
    );

    if (!context.mounted) {
      return;
    }

    final after = controller.taskById(task.deliveryTaskId);
    switch (result) {
      case BusinessDeliveryTaskTransitionResult.success:
        setState(() => _lastErrorMessage = null);
      case BusinessDeliveryTaskTransitionResult.failureReasonRequired:
        setState(
          () => _lastErrorMessage = l10n.businessDeliveryTaskFailureReasonInvalid,
        );
      case BusinessDeliveryTaskTransitionResult.failure:
        setState(
          () => _lastErrorMessage = l10n.businessDeliveryTaskTransitionSaveError,
        );
        assert(after?.status == beforeStatus);
      case BusinessDeliveryTaskTransitionResult.invalidTransition:
      case BusinessDeliveryTaskTransitionResult.terminalTask:
      case BusinessDeliveryTaskTransitionResult.duplicateStatus:
        setState(
          () => _lastErrorMessage = l10n.businessDeliveryTaskTransitionInvalid,
        );
      case BusinessDeliveryTaskTransitionResult.notFound:
        setState(
          () => _lastErrorMessage = l10n.businessDeliveryTaskTransitionSaveError,
        );
    }
  }

  Future<String?> _promptFailureReason(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.businessDeliveryTaskFailureDialogTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.businessDeliveryTaskFailureReasonLabel,
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.businessDeliveryTaskFailureDialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(l10n.businessDeliveryTaskFailureDialogConfirm),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }
}

class _DeliveryTaskBody extends StatelessWidget {
  const _DeliveryTaskBody({
    required this.maxWidth,
    required this.l10n,
    required this.tasks,
    required this.allCount,
    required this.branches,
    required this.branchFilter,
    required this.statusFilter,
    required this.expandedHistoryId,
    required this.transitionBusy,
    required this.errorMessage,
    required this.branchLabel,
    required this.historyFor,
    required this.onBranchFilterChanged,
    required this.onStatusFilterChanged,
    required this.onToggleHistory,
    required this.onTransition,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessDeliveryTask> tasks;
  final int allCount;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessDeliveryTaskStatus? statusFilter;
  final String? expandedHistoryId;
  final bool transitionBusy;
  final String? errorMessage;
  final String Function(String id) branchLabel;
  final List<BusinessDeliveryTaskHistoryEvent> Function(String) historyFor;
  final ValueChanged<String?> onBranchFilterChanged;
  final ValueChanged<BusinessDeliveryTaskStatus?> onStatusFilterChanged;
  final ValueChanged<String> onToggleHistory;
  final void Function(
    BusinessDeliveryTask task,
    BusinessDeliveryTaskStatus target,
  ) onTransition;

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
              message: l10n.businessDeliveryTaskDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppMessageBanner(
                message: errorMessage!,
                icon: Icons.error_outline,
                tone: AppMessageTone.error,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    value: branchFilter,
                    decoration: InputDecoration(
                      labelText: l10n.businessDeliveryTaskBranchFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.businessDeliveryTaskAllBranches),
                      ),
                      for (final b in branches)
                        DropdownMenuItem(
                          value: b.branchId,
                          child: Text(b.name),
                        ),
                    ],
                    onChanged: transitionBusy ? null : onBranchFilterChanged,
                  ),
                  DropdownButtonFormField<BusinessDeliveryTaskStatus?>(
                    isExpanded: true,
                    value: statusFilter,
                    decoration: InputDecoration(
                      labelText: l10n.businessDeliveryTaskStatusFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.businessDeliveryTaskAllStatuses),
                      ),
                      for (final s in BusinessDeliveryTaskStatus.values)
                        DropdownMenuItem(
                          value: s,
                          child: Text(l10n.businessDeliveryTaskStatusLabel(s)),
                        ),
                    ],
                    onChanged: transitionBusy ? null : onStatusFilterChanged,
                  ),
                  Text(
                    l10n.catalogListingFilteredCount(tasks.length, allCount),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (tasks.isEmpty)
              AppSurfaceCard(child: Text(l10n.businessDeliveryTaskEmptyBody))
            else
              for (final task in tasks) ...[
                _TaskCard(
                  l10n: l10n,
                  task: task,
                  branchName: branchLabel(task.branchId),
                  historyExpanded: expandedHistoryId == task.deliveryTaskId,
                  history: historyFor(task.deliveryTaskId),
                  transitionBusy: transitionBusy,
                  onToggleHistory: () => onToggleHistory(task.deliveryTaskId),
                  onTransition: (target) => onTransition(task, target),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.l10n,
    required this.task,
    required this.branchName,
    required this.historyExpanded,
    required this.history,
    required this.transitionBusy,
    required this.onToggleHistory,
    required this.onTransition,
  });

  final AppLocalizations l10n;
  final BusinessDeliveryTask task;
  final String branchName;
  final bool historyExpanded;
  final List<BusinessDeliveryTaskHistoryEvent> history;
  final bool transitionBusy;
  final VoidCallback onToggleHistory;
  final ValueChanged<BusinessDeliveryTaskStatus> onTransition;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final allowed = catalogDeliveryTaskAllowedTargets(task.status);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            task.demoTaskReference,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(l10n.businessDeliveryTaskBranchLabel(branchName)),
          Text(l10n.businessDeliveryTaskStatusLine(
            l10n.businessDeliveryTaskStatusLabel(task.status),
          )),
          Text(l10n.businessDeliveryTaskPickupLabel(task.demoPickupLabel)),
          Text(l10n.businessDeliveryTaskDropOffLabel(task.demoDropOffLabel)),
          if (task.demoAssignmentReference != null)
            Text(l10n.businessDeliveryTaskAssignmentLabel(
              task.demoAssignmentReference!,
            )),
          if (task.failureReason != null)
            Text(l10n.businessDeliveryTaskFailureLine(task.failureReason!)),
          Text(
            l10n.businessDeliveryTaskUpdatedAt(
              task.updatedAt.toIso8601String(),
            ),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final target in allowed)
                OutlinedButton(
                  onPressed: transitionBusy
                      ? null
                      : () => onTransition(target),
                  child: Text(l10n.businessDeliveryTaskActionLabel(target)),
                ),
            ],
          ),
          TextButton(
            onPressed: onToggleHistory,
            child: Text(
              historyExpanded
                  ? l10n.businessDeliveryTaskHideHistoryAction
                  : l10n.businessDeliveryTaskShowHistoryAction,
            ),
          ),
          if (historyExpanded)
            for (final event in history)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  l10n.businessDeliveryTaskHistoryLine(
                    event.previousStatus == null
                        ? '—'
                        : l10n.businessDeliveryTaskStatusLabel(
                            event.previousStatus!,
                          ),
                    l10n.businessDeliveryTaskStatusLabel(event.newStatus),
                    event.recordedAt.toIso8601String(),
                  ),
                  style: textTheme.bodySmall,
                ),
              ),
          BusinessDeliveryTaskExceptionProofPanel(
            task: task,
            busy: transitionBusy,
          ),
        ],
      ),
    );
  }
}
