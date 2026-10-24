import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_dispatch_demo_scenarios.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_template_demo_variables.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_template_repository.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_template_labels.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_audit_record.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_date_format.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_dispatch_controller.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_dispatch_labels.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_eligibility_labels.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_labels.dart';

class NotificationDispatchDiagnosticsPage extends StatefulWidget {
  const NotificationDispatchDiagnosticsPage({super.key});

  @override
  State<NotificationDispatchDiagnosticsPage> createState() =>
      _NotificationDispatchDiagnosticsPageState();
}

class _NotificationDispatchDiagnosticsPageState
    extends State<NotificationDispatchDiagnosticsPage> {
  String? _selectedTemplateId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final controller = getIt<QoshniNotificationDispatchController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.notificationDispatchDiagnosticsTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final records = controller.auditRecords;
            final last = controller.lastAuditRecord;

            return ResponsiveLayout(
              phone: _Body(
                maxWidth: 520,
                l10n: l10n,
                locale: locale,
                controller: controller,
                records: records,
                lastRecord: last,
                lastOutcome: controller.lastOutcome,
                selectedTemplateId: _selectedTemplateId,
                onTemplateSelected: (id) =>
                    setState(() => _selectedTemplateId = id),
              ),
              tablet: _Body(
                maxWidth: 720,
                l10n: l10n,
                locale: locale,
                controller: controller,
                records: records,
                lastRecord: last,
                lastOutcome: controller.lastOutcome,
                selectedTemplateId: _selectedTemplateId,
                onTemplateSelected: (id) =>
                    setState(() => _selectedTemplateId = id),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.maxWidth,
    required this.l10n,
    required this.locale,
    required this.controller,
    required this.records,
    required this.lastRecord,
    required this.lastOutcome,
    required this.selectedTemplateId,
    required this.onTemplateSelected,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final String locale;
  final QoshniNotificationDispatchController controller;
  final List<QoshniNotificationDispatchAuditRecord> records;
  final QoshniNotificationDispatchAuditRecord? lastRecord;
  final QoshniNotificationDispatchOutcome? lastOutcome;
  final String? selectedTemplateId;
  final ValueChanged<String?> onTemplateSelected;

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
              message: l10n.notificationDispatchDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notificationDispatchScenariosSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final scenario in QoshniNotificationDispatchDemoScenario.values)
                  OutlinedButton(
                    onPressed: () {
                      controller.runDemoScenario(scenario);
                      final outcome = controller.lastOutcome;
                      if (outcome != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              qoshniNotificationDispatchOutcomeLabel(
                                l10n,
                                outcome,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(_scenarioLabel(l10n, scenario)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notificationDispatchTemplatesSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Builder(
              builder: (context) {
                final templateRepo = getIt<QoshniNotificationTemplateRepository>();
                final activeTemplates = templateRepo.list(
                  status: QoshniNotificationTemplateStatus.active,
                  channel: QoshniNotificationChannel.inApp,
                );
                final distinctKeys = <String>{};
                final options = <QoshniNotificationTemplateDefinition>[];
                for (final t in activeTemplates) {
                  if (distinctKeys.add(t.templateKey)) {
                    options.add(t);
                  }
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String?>(
                      isExpanded: true,
                      initialValue: selectedTemplateId,
                      decoration: InputDecoration(
                        labelText: l10n.notificationTemplatesTitle,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.notificationDispatchFilterAll),
                        ),
                        for (final template in options)
                          DropdownMenuItem(
                            value: template.templateId,
                            child: Text(template.templateKey),
                          ),
                      ],
                      onChanged: onTemplateSelected,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton(
                      onPressed: selectedTemplateId == null
                          ? null
                          : () {
                              final template =
                                  templateRepo.getById(selectedTemplateId!);
                              if (template == null) {
                                return;
                              }
                              final variables =
                                  qoshniNotificationTemplateDemoVariablesForKey(
                                template.templateKey,
                              );
                              final result = controller.dispatchFromTemplate(
                                template: template,
                                variables: variables,
                                evaluationLocalDateTime:
                                    DateTime(2025, 4, 10, 12, 0),
                              );
                              if (result == null) {
                                final failure =
                                    controller.lastTemplateRenderResult
                                        ?.failureOrNull;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      failure == null
                                          ? l10n
                                              .notificationDispatchTemplateRenderFailed
                                          : qoshniNotificationTemplateRenderErrorLabel(
                                              l10n,
                                              failure.errorCode,
                                              missingVariables:
                                                  failure.missingVariables,
                                            ),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final outcome = controller.lastOutcome;
                              if (outcome != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      qoshniNotificationDispatchOutcomeLabel(
                                        l10n,
                                        outcome,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                      child: Text(
                        l10n.notificationDispatchTemplateSimulateAction,
                      ),
                    ),
                  ],
                );
              },
            ),
            if (lastRecord != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notificationDispatchLastResultTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (lastOutcome != null)
                        Text(
                          qoshniNotificationDispatchOutcomeLabel(
                            l10n,
                            lastOutcome!,
                          ),
                        ),
                      Text(
                        qoshniNotificationEligibilityReasonLabel(
                          l10n,
                          lastRecord!.eligibilityReason,
                        ),
                      ),
                      Text(lastRecord!.channelSimulationMessage),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<QoshniNotificationDispatchOutcome?>(
              isExpanded: true,
              initialValue: controller.outcomeFilter,
              decoration: InputDecoration(
                labelText: l10n.notificationDispatchOutcomeFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.notificationDispatchFilterAll),
                ),
                for (final outcome in QoshniNotificationDispatchOutcome.values)
                  DropdownMenuItem(
                    value: outcome,
                    child: Text(
                      qoshniNotificationDispatchOutcomeLabel(l10n, outcome),
                    ),
                  ),
              ],
              onChanged: controller.setOutcomeFilter,
            ),
            DropdownButtonFormField<QoshniNotificationCategory?>(
              isExpanded: true,
              initialValue: controller.categoryFilter,
              decoration: InputDecoration(
                labelText: l10n.notificationCategoryFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.notificationCategoryAll),
                ),
                for (final category in QoshniNotificationCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(
                      qoshniNotificationCategoryLabel(l10n, category),
                    ),
                  ),
              ],
              onChanged: controller.setCategoryFilter,
            ),
            DropdownButtonFormField<QoshniNotificationChannel?>(
              isExpanded: true,
              initialValue: controller.channelFilter,
              decoration: InputDecoration(
                labelText: l10n.notificationPreferencesPreviewChannel,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.notificationDispatchFilterAll),
                ),
                for (final channel in QoshniNotificationChannel.values)
                  DropdownMenuItem(
                    value: channel,
                    child: Text(
                      qoshniNotificationChannelLabel(l10n, channel),
                    ),
                  ),
              ],
              onChanged: controller.setChannelFilter,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: controller.clearFilters,
                child: Text(l10n.notificationClearFilters),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notificationDispatchAuditSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (records.isEmpty)
              AppSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(l10n.notificationDispatchAuditEmpty),
                ),
              )
            else
              ...records.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppSurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.titleSummary,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            l10n.notificationDispatchAuditMetaLine(
                              qoshniNotificationDispatchOutcomeLabel(
                                l10n,
                                record.outcome,
                              ),
                              qoshniNotificationCategoryLabel(
                                l10n,
                                record.category,
                              ),
                              qoshniNotificationChannelLabel(
                                l10n,
                                record.channel,
                              ),
                              formatQoshniNotificationTimestamp(
                                record.recordedAt,
                                locale,
                              ),
                            ),
                          ),
                          Text(
                            qoshniNotificationEligibilityReasonLabel(
                              l10n,
                              record.eligibilityReason,
                            ),
                          ),
                          Text(record.channelSimulationMessage),
                          if (record.inboxNotificationId != null)
                            Text(
                              l10n.notificationDispatchInboxLinkLine(
                                record.inboxNotificationId!,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _scenarioLabel(
    AppLocalizations l10n,
    QoshniNotificationDispatchDemoScenario scenario,
  ) {
    return switch (scenario) {
      QoshniNotificationDispatchDemoScenario.orderInAppMidday =>
        l10n.notificationDispatchScenarioOrderMidday,
      QoshniNotificationDispatchDemoScenario.orderInAppQuietHours =>
        l10n.notificationDispatchScenarioOrderQuiet,
      QoshniNotificationDispatchDemoScenario.promotionPushPreview =>
        l10n.notificationDispatchScenarioPromotion,
      QoshniNotificationDispatchDemoScenario.securityInAppQuietHours =>
        l10n.notificationDispatchScenarioSecurityQuiet,
    };
  }
}
