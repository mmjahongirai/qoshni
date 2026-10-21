import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_product_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_catalog_service_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_review_demo_transaction_evidence.dart'
    show
        kDemoReviewReviewerA,
        kDemoReviewReviewerB,
        kDemoReviewReviewerC,
        kDemoReviewTxEvidenceBusinessCompleted,
        kDemoReviewTxEvidencePackingCompleted,
        kDemoReviewTxEvidenceSessionCreate;
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_rating_summary.dart';
import 'package:qoshni/features/business_platform/domain/business_review.dart';
import 'package:qoshni/features/business_platform/domain/business_review_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_review_status.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_review_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_product_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_service_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_rating_summary_calculator.dart';
import 'package:qoshni/features/business_platform/presentation/business_review_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_review_labels.dart';
import 'package:qoshni/features/business_platform/presentation/business_review_transitions.dart';

class BusinessReviewsPage extends StatefulWidget {
  const BusinessReviewsPage({super.key});

  @override
  State<BusinessReviewsPage> createState() => _BusinessReviewsPageState();
}

class _BusinessReviewsPageState extends State<BusinessReviewsPage> {
  String? _branchFilter;
  BusinessReviewTargetType? _targetTypeFilter;
  BusinessReviewStatus? _statusFilter;
  String? _expandedHistoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessReviewController>().refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reviewController = getIt<BusinessReviewController>();
    final branchController = getIt<BusinessBranchController>();
    final productController = getIt<BusinessCatalogProductController>();
    final serviceController = getIt<BusinessCatalogServiceController>();

    String targetLabel(BusinessReview review) {
      switch (review.targetType) {
        case BusinessReviewTargetType.business:
          return l10n.businessReviewTargetBusinessScope;
        case BusinessReviewTargetType.product:
          final p = productController.productById(review.targetId);
          return p?.displayName(l10n) ?? review.targetId;
        case BusinessReviewTargetType.service:
          final s = serviceController.serviceById(review.targetId);
          return s?.displayName(l10n) ?? review.targetId;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.businessReviewListTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: reviewController.saveBusy
            ? null
            : () => _openCreateDialog(context, l10n, reviewController),
        icon: const Icon(Icons.rate_review_outlined),
        label: Text(l10n.businessReviewCreateDemoAction),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            reviewController,
            branchController,
            productController,
            serviceController,
          ]),
          builder: (context, _) {
            if (reviewController.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final filtered = reviewController.reviews(
              branchId: _branchFilter,
              targetType: _targetTypeFilter,
              status: _statusFilter,
            );
            final summary = reviewController.ratingSummary(
              branchId: _branchFilter,
              targetType: _targetTypeFilter,
            );

            return ResponsiveLayout(
              phone: _ReviewsBody(
                maxWidth: 520,
                l10n: l10n,
                reviews: filtered,
                summary: summary,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                targetTypeFilter: _targetTypeFilter,
                statusFilter: _statusFilter,
                saveBusy: reviewController.saveBusy,
                expandedHistoryId: _expandedHistoryId,
                targetLabel: targetLabel,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: reviewController.historyFor,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onTargetTypeFilterChanged: (v) =>
                    setState(() => _targetTypeFilter = v),
                onStatusFilterChanged: (v) =>
                    setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onModeration: (review, target) => _moderate(
                  context,
                  l10n,
                  reviewController,
                  review,
                  target,
                ),
              ),
              tablet: _ReviewsBody(
                maxWidth: 720,
                l10n: l10n,
                reviews: filtered,
                summary: summary,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                targetTypeFilter: _targetTypeFilter,
                statusFilter: _statusFilter,
                saveBusy: reviewController.saveBusy,
                expandedHistoryId: _expandedHistoryId,
                targetLabel: targetLabel,
                branchLabel: (id) =>
                    branchController.branchById(id)?.name ?? id,
                historyFor: reviewController.historyFor,
                onBranchFilterChanged: (v) => setState(() => _branchFilter = v),
                onTargetTypeFilterChanged: (v) =>
                    setState(() => _targetTypeFilter = v),
                onStatusFilterChanged: (v) =>
                    setState(() => _statusFilter = v),
                onToggleHistory: (id) => setState(() {
                  _expandedHistoryId = _expandedHistoryId == id ? null : id;
                }),
                onModeration: (review, target) => _moderate(
                  context,
                  l10n,
                  reviewController,
                  review,
                  target,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _moderate(
    BuildContext context,
    AppLocalizations l10n,
    BusinessReviewController controller,
    BusinessReview review,
    BusinessReviewStatus target,
  ) async {
    String? reason;
    if (target == BusinessReviewStatus.rejected ||
        target == BusinessReviewStatus.hidden) {
      reason = await showDialog<String>(
        context: context,
        builder: (context) {
          final c = TextEditingController();
          return AlertDialog(
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
          );
        },
      );
      if (reason == null) {
        return;
      }
    }
    await controller.applyTransition(
      reviewId: review.reviewId,
      request: BusinessReviewTransitionRequest(
        targetStatus: target,
        moderationReason: reason,
      ),
    );
  }

  Future<void> _openCreateDialog(
    BuildContext context,
    AppLocalizations l10n,
    BusinessReviewController controller,
  ) async {
    var targetType = BusinessReviewTargetType.product;
    var targetId = kDemoCatalogProductBreadId;
    var evidence = kDemoReviewTxEvidenceSessionCreate;
    var reviewer = kDemoReviewReviewerA;
    var rating = 5;
    final titleController = TextEditingController(text: 'Demo review title');
    final textController = TextEditingController(
      text: 'Synthetic transaction evidence only.',
    );
    var eligibilityMessage = '';
    var errorMessage = '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void refreshEligibility() {
              final result = controller.previewEligibility(
                BusinessReviewCreateInput(
                  targetType: targetType,
                  targetId: targetId,
                  demoReviewerReference: reviewer,
                  transactionEvidenceReference: evidence,
                  rating: rating,
                  title: titleController.text,
                  reviewText: textController.text,
                ),
              );
              setDialogState(() {
                eligibilityMessage = l10n.businessReviewEligibilityMessage(
                  result.status,
                );
              });
            }

            return AlertDialog(
              title: Text(l10n.businessReviewCreateDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.businessReviewSyntheticEvidenceNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    DropdownButtonFormField<BusinessReviewTargetType>(
                      isExpanded: true,
                      initialValue: targetType,
                      decoration: InputDecoration(
                        labelText: l10n.businessReviewTargetTypeField,
                      ),
                      items: [
                        for (final t in BusinessReviewTargetType.values)
                          DropdownMenuItem(
                            value: t,
                            child: Text(l10n.businessReviewTargetTypeLabel(t)),
                          ),
                      ],
                      onChanged: (v) {
                        if (v == null) {
                          return;
                        }
                        setDialogState(() {
                          targetType = v;
                          switch (v) {
                            case BusinessReviewTargetType.product:
                              targetId = kDemoCatalogProductBreadId;
                              evidence = kDemoReviewTxEvidenceSessionCreate;
                              reviewer = kDemoReviewReviewerA;
                            case BusinessReviewTargetType.service:
                              targetId = kDemoCatalogServicePackingId;
                              evidence = kDemoReviewTxEvidencePackingCompleted;
                              reviewer = kDemoReviewReviewerB;
                            case BusinessReviewTargetType.business:
                              targetId = controller
                                  .reviews()
                                  .first
                                  .businessScopeId;
                              evidence =
                                  kDemoReviewTxEvidenceBusinessCompleted;
                              reviewer = kDemoReviewReviewerC;
                          }
                        });
                        refreshEligibility();
                      },
                    ),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.businessReviewTargetIdField,
                        helperText: targetId,
                      ),
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: rating,
                      decoration: InputDecoration(
                        labelText: l10n.businessReviewRatingField,
                      ),
                      items: [
                        for (var i = 1; i <= 5; i++)
                          DropdownMenuItem(value: i, child: Text('$i')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => rating = v);
                          refreshEligibility();
                        }
                      },
                    ),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: l10n.businessReviewTitleField,
                      ),
                    ),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: l10n.businessReviewTextField,
                      ),
                      maxLines: 3,
                    ),
                    if (eligibilityMessage.isNotEmpty)
                      Text(eligibilityMessage),
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
                TextButton(
                  onPressed: refreshEligibility,
                  child: Text(l10n.businessReviewCheckEligibilityAction),
                ),
                FilledButton(
                  onPressed: () async {
                    final result = await controller.createReview(
                      BusinessReviewCreateInput(
                        targetType: targetType,
                        targetId: targetId,
                        demoReviewerReference: reviewer,
                        transactionEvidenceReference: evidence,
                        rating: rating,
                        title: titleController.text,
                        reviewText: textController.text,
                      ),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    switch (result) {
                      case BusinessReviewCreateResult.success:
                        Navigator.pop(context);
                      case BusinessReviewCreateResult.ineligible:
                        setDialogState(() {
                          errorMessage = l10n.businessReviewCreateIneligible;
                        });
                      case BusinessReviewCreateResult.failure:
                        setDialogState(() {
                          errorMessage = l10n.businessReviewSaveError;
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
    titleController.dispose();
    textController.dispose();
  }
}

class _ReviewsBody extends StatelessWidget {
  const _ReviewsBody({
    required this.maxWidth,
    required this.l10n,
    required this.reviews,
    required this.summary,
    required this.branches,
    required this.branchFilter,
    required this.targetTypeFilter,
    required this.statusFilter,
    required this.saveBusy,
    required this.expandedHistoryId,
    required this.targetLabel,
    required this.branchLabel,
    required this.historyFor,
    required this.onBranchFilterChanged,
    required this.onTargetTypeFilterChanged,
    required this.onStatusFilterChanged,
    required this.onToggleHistory,
    required this.onModeration,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessReview> reviews;
  final BusinessRatingSummary summary;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessReviewTargetType? targetTypeFilter;
  final BusinessReviewStatus? statusFilter;
  final bool saveBusy;
  final String? expandedHistoryId;
  final String Function(BusinessReview) targetLabel;
  final String Function(String) branchLabel;
  final List<BusinessReviewHistoryEvent> Function(String) historyFor;
  final ValueChanged<String?> onBranchFilterChanged;
  final ValueChanged<BusinessReviewTargetType?> onTargetTypeFilterChanged;
  final ValueChanged<BusinessReviewStatus?> onStatusFilterChanged;
  final ValueChanged<String> onToggleHistory;
  final void Function(BusinessReview, BusinessReviewStatus) onModeration;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final avg = formatBusinessRatingAverageForDisplay(summary.averageRating);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.businessReviewDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppMessageBanner(
              message: l10n.businessReviewDemoRatingNote,
              icon: Icons.science_outlined,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.businessReviewSummaryTitle,
                    style: textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(l10n.businessReviewSummaryAverage(avg)),
                  Text(
                    l10n.businessReviewSummaryCount(
                      summary.publishedReviewCount,
                    ),
                  ),
                  for (var star = 5; star >= 1; star--)
                    Text(
                      l10n.businessReviewDistributionLine(
                        star,
                        summary.distribution[star] ?? 0,
                      ),
                      style: textTheme.bodySmall,
                    ),
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
                      labelText: l10n.businessReviewBranchFilter,
                    ),
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
                    onChanged: saveBusy ? null : onBranchFilterChanged,
                  ),
                  DropdownButtonFormField<BusinessReviewTargetType?>(
                    isExpanded: true,
                    value: targetTypeFilter,
                    decoration: InputDecoration(
                      labelText: l10n.businessReviewTargetTypeFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.businessReviewAllTargetTypes),
                      ),
                      for (final t in BusinessReviewTargetType.values)
                        DropdownMenuItem(
                          value: t,
                          child: Text(l10n.businessReviewTargetTypeLabel(t)),
                        ),
                    ],
                    onChanged: saveBusy ? null : onTargetTypeFilterChanged,
                  ),
                  DropdownButtonFormField<BusinessReviewStatus?>(
                    isExpanded: true,
                    value: statusFilter,
                    decoration: InputDecoration(
                      labelText: l10n.businessReviewStatusFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.businessReviewAllStatuses),
                      ),
                      for (final s in BusinessReviewStatus.values)
                        DropdownMenuItem(
                          value: s,
                          child: Text(l10n.businessReviewStatusLabel(s)),
                        ),
                    ],
                    onChanged: saveBusy ? null : onStatusFilterChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (reviews.isEmpty)
              AppSurfaceCard(child: Text(l10n.businessReviewEmptyBody))
            else
              for (final review in reviews)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.businessReviewCardLine(
                            targetLabel(review),
                            l10n.businessReviewTargetTypeLabel(
                              review.targetType,
                            ),
                            '${review.rating}',
                            l10n.businessReviewStatusLabel(review.status),
                          ),
                          style: textTheme.titleSmall,
                        ),
                        if (review.branchId != null)
                          Text(branchLabel(review.branchId!)),
                        if (review.title != null) Text(review.title!),
                        if (review.reviewText != null)
                          Text(
                            review.reviewText!,
                            style: textTheme.bodySmall,
                          ),
                        Text(
                          l10n.businessReviewProvenanceLine(
                            review.transactionEvidenceReference,
                            review.demoReviewerReference,
                          ),
                          style: textTheme.labelSmall,
                        ),
                        if (review.isSyntheticDemo)
                          Text(
                            l10n.businessReviewSyntheticBadge,
                            style: textTheme.labelSmall,
                          ),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            for (final target
                                in BusinessReviewStatus.values)
                              if (catalogBusinessReviewTransitionAllowed(
                                from: review.status,
                                to: target,
                              ))
                                OutlinedButton(
                                  onPressed: saveBusy
                                      ? null
                                      : () => onModeration(review, target),
                                  child: Text(
                                    l10n.businessReviewModerationActionLabel(
                                      target,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => onToggleHistory(review.reviewId),
                          child: Text(l10n.businessReviewHistoryAction),
                        ),
                        if (expandedHistoryId == review.reviewId)
                          for (final event in historyFor(review.reviewId))
                            Text(
                              l10n.businessReviewHistoryLine(
                                event.previousStatus == null
                                    ? '—'
                                    : l10n.businessReviewStatusLabel(
                                        event.previousStatus!,
                                      ),
                                l10n.businessReviewStatusLabel(event.newStatus),
                                event.recordedAt.toIso8601String(),
                              ),
                              style: textTheme.bodySmall,
                            ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
