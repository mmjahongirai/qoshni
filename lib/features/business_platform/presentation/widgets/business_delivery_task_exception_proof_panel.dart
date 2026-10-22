import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_category.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_status.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_method.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_of_delivery.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_status.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_exception_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_proof_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_exception_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_exception_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_proof_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_delivery_proof_labels.dart';

class BusinessDeliveryTaskExceptionProofPanel extends StatefulWidget {
  const BusinessDeliveryTaskExceptionProofPanel({
    super.key,
    required this.task,
    required this.busy,
  });

  final BusinessDeliveryTask task;
  final bool busy;

  @override
  State<BusinessDeliveryTaskExceptionProofPanel> createState() =>
      _BusinessDeliveryTaskExceptionProofPanelState();
}

class _BusinessDeliveryTaskExceptionProofPanelState
    extends State<BusinessDeliveryTaskExceptionProofPanel> {
  String? _expandedExceptionId;
  String? _expandedProofId;

  bool get _canAddProof {
    switch (widget.task.status) {
      case BusinessDeliveryTaskStatus.pickedUp:
      case BusinessDeliveryTaskStatus.inTransit:
      case BusinessDeliveryTaskStatus.delivered:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final exceptionController = getIt<BusinessDeliveryExceptionController>();
    final proofController = getIt<BusinessDeliveryProofController>();
    final textTheme = Theme.of(context).textTheme;

    final exceptions = exceptionController.exceptions(
      deliveryTaskId: widget.task.deliveryTaskId,
    );
    final proofs = proofController.proofs(
      deliveryTaskId: widget.task.deliveryTaskId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: AppSpacing.lg),
        Text(
          l10n.businessDeliveryExceptionSectionTitle,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          l10n.businessDeliveryExceptionDemoDisclaimer,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (exceptions.isEmpty)
          Text(l10n.businessDeliveryExceptionEmptyForTask)
        else
          for (final ex in exceptions)
            _ExceptionTile(
              l10n: l10n,
              exception: ex,
              busy: widget.busy || exceptionController.saveBusy,
              historyExpanded: _expandedExceptionId == ex.exceptionId,
              history: exceptionController.historyFor(ex.exceptionId),
              onToggleHistory: () => setState(() {
                _expandedExceptionId =
                    _expandedExceptionId == ex.exceptionId
                        ? null
                        : ex.exceptionId;
              }),
              onResolve: () => _resolveException(context, l10n, ex),
              onDismiss: () => _dismissException(context, l10n, ex),
              onReopen: () => _reopenException(context, l10n, ex),
            ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.busy || exceptionController.saveBusy
                ? null
                : () => _createException(context, l10n),
            icon: const Icon(Icons.report_outlined, size: 18),
            label: Text(l10n.businessDeliveryExceptionAddAction),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.businessDeliveryProofSectionTitle,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          l10n.businessDeliveryProofDemoDisclaimer,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (proofs.isEmpty)
          Text(l10n.businessDeliveryProofEmptyForTask)
        else
          for (final proof in proofs)
            _ProofTile(
              l10n: l10n,
              proof: proof,
              busy: widget.busy || proofController.saveBusy,
              historyExpanded: _expandedProofId == proof.proofId,
              history: proofController.historyFor(proof.proofId),
              onToggleHistory: () => setState(() {
                _expandedProofId =
                    _expandedProofId == proof.proofId ? null : proof.proofId;
              }),
              onVerify: () => _verifyProof(context, l10n, proof, verified: true),
              onReject: () => _verifyProof(context, l10n, proof, verified: false),
            ),
        if (_canAddProof)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.busy || proofController.saveBusy
                  ? null
                  : () => _createProof(context, l10n),
              icon: const Icon(Icons.verified_outlined, size: 18),
              label: Text(l10n.businessDeliveryProofAddAction),
            ),
          ),
      ],
    );
  }

  Future<void> _createException(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    var category = BusinessDeliveryExceptionCategory.other;
    final reasonController = TextEditingController();
    var errorText = '';

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.businessDeliveryExceptionCreateTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<
                        BusinessDeliveryExceptionCategory>(
                      isExpanded: true,
                      initialValue: category,
                      decoration: InputDecoration(
                        labelText: l10n.businessDeliveryExceptionCategoryField,
                      ),
                      items: [
                        for (final c
                            in BusinessDeliveryExceptionCategory.values)
                          DropdownMenuItem(
                            value: c,
                            child: Text(
                              l10n.businessDeliveryExceptionCategoryLabel(c),
                            ),
                          ),
                      ],
                      onChanged: widget.busy
                          ? null
                          : (v) => setDialogState(() {
                                if (v != null) {
                                  category = v;
                                }
                              }),
                    ),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: l10n.businessDeliveryExceptionReasonField,
                      ),
                      maxLines: 3,
                    ),
                    if (errorText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          errorText,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.businessDeliveryDialogCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final controller =
                        getIt<BusinessDeliveryExceptionController>();
                    final result = await controller.createException(
                      BusinessDeliveryExceptionCreateInput(
                        deliveryTaskId: widget.task.deliveryTaskId,
                        category: category,
                        reason: reasonController.text,
                      ),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    switch (result) {
                      case BusinessDeliveryExceptionCreateResult.success:
                        Navigator.pop(context, true);
                      case BusinessDeliveryExceptionCreateResult.invalidReason:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryExceptionValidationError;
                        });
                      case BusinessDeliveryExceptionCreateResult.failure:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryExceptionSaveError;
                        });
                      default:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryExceptionValidationError;
                        });
                    }
                  },
                  child: Text(l10n.businessDeliveryDialogSave),
                ),
              ],
            );
          },
        );
      },
    );
    reasonController.dispose();
    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _resolveException(
    BuildContext context,
    AppLocalizations l10n,
    BusinessDeliveryException ex,
  ) async {
    final noteController = TextEditingController();
    var errorText = '';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.businessDeliveryExceptionResolveTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: l10n.businessDeliveryExceptionResolutionField,
                    ),
                    maxLines: 3,
                  ),
                  if (errorText.isNotEmpty)
                    Text(
                      errorText,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.businessDeliveryDialogCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final result = await getIt<
                            BusinessDeliveryExceptionController>()
                        .applyTransition(
                      exceptionId: ex.exceptionId,
                      request: BusinessDeliveryExceptionTransitionRequest(
                        targetStatus: BusinessDeliveryExceptionStatus.resolved,
                        resolutionNote: noteController.text,
                      ),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    switch (result) {
                      case BusinessDeliveryExceptionTransitionResult.success:
                        Navigator.pop(context, true);
                      case BusinessDeliveryExceptionTransitionResult
                            .resolutionNoteRequired:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryExceptionValidationError;
                        });
                      case BusinessDeliveryExceptionTransitionResult.failure:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryExceptionSaveError;
                        });
                      default:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryExceptionValidationError;
                        });
                    }
                  },
                  child: Text(l10n.businessDeliveryDialogConfirm),
                ),
              ],
            );
          },
        );
      },
    );
    noteController.dispose();
    if (ok == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _dismissException(
    BuildContext context,
    AppLocalizations l10n,
    BusinessDeliveryException ex,
  ) async {
    final result = await getIt<BusinessDeliveryExceptionController>()
        .applyTransition(
      exceptionId: ex.exceptionId,
      request: const BusinessDeliveryExceptionTransitionRequest(
        targetStatus: BusinessDeliveryExceptionStatus.dismissed,
      ),
    );
    if (mounted && result == BusinessDeliveryExceptionTransitionResult.success) {
      setState(() {});
    }
  }

  Future<void> _reopenException(
    BuildContext context,
    AppLocalizations l10n,
    BusinessDeliveryException ex,
  ) async {
    final result = await getIt<BusinessDeliveryExceptionController>()
        .applyTransition(
      exceptionId: ex.exceptionId,
      request: const BusinessDeliveryExceptionTransitionRequest(
        targetStatus: BusinessDeliveryExceptionStatus.open,
      ),
    );
    if (mounted && result == BusinessDeliveryExceptionTransitionResult.success) {
      setState(() {});
    }
  }

  Future<void> _createProof(BuildContext context, AppLocalizations l10n) async {
    var method = BusinessDeliveryProofMethod.recipientConfirmation;
    final evidenceController = TextEditingController(
      text: 'demo-evidence-new-${widget.task.demoTaskReference}',
    );
    final descriptionController = TextEditingController(
      text: 'Demo proof metadata only',
    );
    var errorText = '';

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.businessDeliveryProofCreateTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<BusinessDeliveryProofMethod>(
                      isExpanded: true,
                      initialValue: method,
                      decoration: InputDecoration(
                        labelText: l10n.businessDeliveryProofMethodField,
                      ),
                      items: [
                        for (final m in BusinessDeliveryProofMethod.values)
                          DropdownMenuItem(
                            value: m,
                            child: Text(l10n.businessDeliveryProofMethodLabel(m)),
                          ),
                      ],
                      onChanged: (v) => setDialogState(() {
                        if (v != null) {
                          method = v;
                        }
                      }),
                    ),
                    TextField(
                      controller: evidenceController,
                      decoration: InputDecoration(
                        labelText: l10n.businessDeliveryProofEvidenceField,
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.businessDeliveryProofDescriptionField,
                      ),
                      maxLines: 2,
                    ),
                    if (errorText.isNotEmpty)
                      Text(
                        errorText,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.businessDeliveryDialogCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final result =
                        await getIt<BusinessDeliveryProofController>().createProof(
                      BusinessDeliveryProofCreateInput(
                        deliveryTaskId: widget.task.deliveryTaskId,
                        method: method,
                        demoEvidenceReference: evidenceController.text,
                        description: descriptionController.text,
                      ),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    switch (result) {
                      case BusinessDeliveryProofCreateResult.success:
                        Navigator.pop(context, true);
                      case BusinessDeliveryProofCreateResult.failure:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryProofSaveError;
                        });
                      default:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryProofValidationError;
                        });
                    }
                  },
                  child: Text(l10n.businessDeliveryDialogSave),
                ),
              ],
            );
          },
        );
      },
    );
    evidenceController.dispose();
    descriptionController.dispose();
    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _verifyProof(
    BuildContext context,
    AppLocalizations l10n,
    BusinessDeliveryProofOfDelivery proof, {
    required bool verified,
  }) async {
    final noteController = TextEditingController(
      text: verified ? 'Demo operator verified' : 'Demo operator rejected',
    );
    var errorText = '';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.businessDeliveryProofVerifyTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText:
                          l10n.businessDeliveryProofVerificationReasonField,
                    ),
                  ),
                  if (errorText.isNotEmpty)
                    Text(
                      errorText,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.businessDeliveryDialogCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final result =
                        await getIt<BusinessDeliveryProofController>()
                            .applyTransition(
                      proofId: proof.proofId,
                      request: BusinessDeliveryProofTransitionRequest(
                        targetStatus: verified
                            ? BusinessDeliveryProofStatus.verified
                            : BusinessDeliveryProofStatus.rejected,
                        demoVerificationReason: noteController.text,
                      ),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    switch (result) {
                      case BusinessDeliveryProofTransitionResult.success:
                        Navigator.pop(context, true);
                      case BusinessDeliveryProofTransitionResult.failure:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryProofSaveError;
                        });
                      default:
                        setDialogState(() {
                          errorText = l10n.businessDeliveryProofValidationError;
                        });
                    }
                  },
                  child: Text(l10n.businessDeliveryDialogConfirm),
                ),
              ],
            );
          },
        );
      },
    );
    noteController.dispose();
    if (ok == true && mounted) {
      setState(() {});
    }
  }
}

class _ExceptionTile extends StatelessWidget {
  const _ExceptionTile({
    required this.l10n,
    required this.exception,
    required this.busy,
    required this.historyExpanded,
    required this.history,
    required this.onToggleHistory,
    required this.onResolve,
    required this.onDismiss,
    required this.onReopen,
  });

  final AppLocalizations l10n;
  final BusinessDeliveryException exception;
  final bool busy;
  final bool historyExpanded;
  final List<BusinessDeliveryExceptionHistoryEvent> history;
  final VoidCallback onToggleHistory;
  final VoidCallback onResolve;
  final VoidCallback onDismiss;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.businessDeliveryExceptionLine(
              l10n.businessDeliveryExceptionCategoryLabel(exception.category),
              l10n.businessDeliveryExceptionStatusLabel(exception.status),
              exception.reason,
            ),
            style: textTheme.bodySmall,
          ),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              if (exception.status == BusinessDeliveryExceptionStatus.open) ...[
                TextButton(
                  onPressed: busy ? null : onResolve,
                  child: Text(l10n.businessDeliveryExceptionResolveAction),
                ),
                TextButton(
                  onPressed: busy ? null : onDismiss,
                  child: Text(l10n.businessDeliveryExceptionDismissAction),
                ),
              ],
              if (exception.status != BusinessDeliveryExceptionStatus.open)
                TextButton(
                  onPressed: busy ? null : onReopen,
                  child: Text(l10n.businessDeliveryExceptionReopenAction),
                ),
              TextButton(
                onPressed: onToggleHistory,
                child: Text(l10n.businessDeliveryExceptionHistoryAction),
              ),
            ],
          ),
          if (historyExpanded)
            for (final event in history)
              Text(
                '${event.newStatus.name} · ${event.recordedAt.toIso8601String()}',
                style: textTheme.labelSmall,
              ),
        ],
      ),
    );
  }
}

class _ProofTile extends StatelessWidget {
  const _ProofTile({
    required this.l10n,
    required this.proof,
    required this.busy,
    required this.historyExpanded,
    required this.history,
    required this.onToggleHistory,
    required this.onVerify,
    required this.onReject,
  });

  final AppLocalizations l10n;
  final BusinessDeliveryProofOfDelivery proof;
  final bool busy;
  final bool historyExpanded;
  final List<BusinessDeliveryProofHistoryEvent> history;
  final VoidCallback onToggleHistory;
  final VoidCallback onVerify;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.businessDeliveryProofLine(
              l10n.businessDeliveryProofMethodLabel(proof.method),
              l10n.businessDeliveryProofStatusLabel(proof.status),
              proof.demoEvidenceReference,
            ),
            style: textTheme.bodySmall,
          ),
          Text(proof.description, style: textTheme.labelSmall),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              if (proof.status == BusinessDeliveryProofStatus.pending) ...[
                TextButton(
                  onPressed: busy ? null : onVerify,
                  child: Text(l10n.businessDeliveryProofVerifyDemoAction),
                ),
                TextButton(
                  onPressed: busy ? null : onReject,
                  child: Text(l10n.businessDeliveryProofRejectDemoAction),
                ),
              ],
              TextButton(
                onPressed: onToggleHistory,
                child: Text(l10n.businessDeliveryProofHistoryAction),
              ),
            ],
          ),
          if (historyExpanded)
            for (final event in history)
              Text(
                '${event.newStatus.name} · ${event.recordedAt.toIso8601String()}',
                style: textTheme.labelSmall,
              ),
        ],
      ),
    );
  }
}
