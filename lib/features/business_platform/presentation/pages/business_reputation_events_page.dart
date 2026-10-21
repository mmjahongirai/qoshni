import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_reputation_event_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_reputation_event_labels.dart';

class BusinessReputationEventsPage extends StatefulWidget {
  const BusinessReputationEventsPage({super.key});

  @override
  State<BusinessReputationEventsPage> createState() =>
      _BusinessReputationEventsPageState();
}

class _BusinessReputationEventsPageState
    extends State<BusinessReputationEventsPage> {
  String? _branchFilter;
  BusinessReputationEventSourceDomain? _sourceFilter;
  BusinessReputationEventType? _eventTypeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<BusinessReputationEventController>().refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final eventController = getIt<BusinessReputationEventController>();
    final branchController = getIt<BusinessBranchController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.businessReputationEventsTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([eventController, branchController]),
          builder: (context, _) {
            if (eventController.listLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final events = eventController.events(
              branchId: _branchFilter,
              sourceDomain: _sourceFilter,
              eventType: _eventTypeFilter,
            );

            return ResponsiveLayout(
              phone: _EventsBody(
                maxWidth: 520,
                l10n: l10n,
                events: events,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                sourceFilter: _sourceFilter,
                eventTypeFilter: _eventTypeFilter,
                onClearFilters: () => setState(() {
                  _branchFilter = null;
                  _sourceFilter = null;
                  _eventTypeFilter = null;
                }),
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onSourceChanged: (v) => setState(() => _sourceFilter = v),
                onEventTypeChanged: (v) =>
                    setState(() => _eventTypeFilter = v),
              ),
              tablet: _EventsBody(
                maxWidth: 720,
                l10n: l10n,
                events: events,
                branches: branchController.branches,
                branchFilter: _branchFilter,
                sourceFilter: _sourceFilter,
                eventTypeFilter: _eventTypeFilter,
                onClearFilters: () => setState(() {
                  _branchFilter = null;
                  _sourceFilter = null;
                  _eventTypeFilter = null;
                }),
                onBranchChanged: (v) => setState(() => _branchFilter = v),
                onSourceChanged: (v) => setState(() => _sourceFilter = v),
                onEventTypeChanged: (v) =>
                    setState(() => _eventTypeFilter = v),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EventsBody extends StatelessWidget {
  const _EventsBody({
    required this.maxWidth,
    required this.l10n,
    required this.events,
    required this.branches,
    required this.branchFilter,
    required this.sourceFilter,
    required this.eventTypeFilter,
    required this.onClearFilters,
    required this.onBranchChanged,
    required this.onSourceChanged,
    required this.onEventTypeChanged,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final List<BusinessReputationEvent> events;
  final List<BusinessBranch> branches;
  final String? branchFilter;
  final BusinessReputationEventSourceDomain? sourceFilter;
  final BusinessReputationEventType? eventTypeFilter;
  final VoidCallback onClearFilters;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<BusinessReputationEventSourceDomain?> onSourceChanged;
  final ValueChanged<BusinessReputationEventType?> onEventTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.businessReputationEventsDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.businessReputationEventsInformationalNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: branchFilter,
              decoration: InputDecoration(
                labelText: l10n.businessReviewBranchFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.businessReviewAllBranches),
                ),
                for (final b in branches)
                  DropdownMenuItem(value: b.branchId, child: Text(b.name)),
              ],
              onChanged: onBranchChanged,
            ),
            DropdownButtonFormField<BusinessReputationEventSourceDomain?>(
              isExpanded: true,
              initialValue: sourceFilter,
              decoration: InputDecoration(
                labelText: l10n.businessReputationEventSourceFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.businessReputationEventAllSources),
                ),
                for (final s in BusinessReputationEventSourceDomain.values)
                  DropdownMenuItem(
                    value: s,
                    child: Text(l10n.businessReputationEventSourceLabel(s)),
                  ),
              ],
              onChanged: onSourceChanged,
            ),
            DropdownButtonFormField<BusinessReputationEventType?>(
              isExpanded: true,
              initialValue: eventTypeFilter,
              decoration: InputDecoration(
                labelText: l10n.businessReputationEventTypeFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.businessReputationEventAllTypes),
                ),
                for (final t in BusinessReputationEventType.values)
                  DropdownMenuItem(
                    value: t,
                    child: Text(l10n.businessReputationEventTypeLabel(t)),
                  ),
              ],
              onChanged: onEventTypeChanged,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onClearFilters,
                child: Text(l10n.businessComplaintClearFilters),
              ),
            ),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Text(l10n.businessReputationEventsEmptyBody),
              ),
            for (final e in events) ...[
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.businessReputationEventCardLine(
                        l10n.businessReputationEventTypeLabel(e.eventType),
                        l10n.businessReputationEventSourceLabel(e.sourceDomain),
                        e.sourceRecordId,
                      ),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.businessReputationEventTargetLine(
                        e.targetType.name,
                        e.targetId,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (e.previousStatusLabel != null ||
                        e.newStatusLabel != null)
                      Text(
                        l10n.businessReputationEventStatusLine(
                          e.previousStatusLabel ?? '—',
                          e.newStatusLabel ?? '—',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    Text(
                      l10n.businessReputationEventTimestampsLine(
                        e.occurredAt.toIso8601String(),
                        e.recordedAt.toIso8601String(),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      l10n.businessReputationEventProvenanceLine(
                        e.correlationReferenceId,
                      ),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      l10n.businessReputationEventSyntheticBadge,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
