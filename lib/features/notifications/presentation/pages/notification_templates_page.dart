import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_labels.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_template_controller.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_template_labels.dart';

class NotificationTemplatesPage extends StatefulWidget {
  const NotificationTemplatesPage({super.key});

  @override
  State<NotificationTemplatesPage> createState() =>
      _NotificationTemplatesPageState();
}

class _NotificationTemplatesPageState extends State<NotificationTemplatesPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<QoshniNotificationTemplateController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.notificationTemplatesTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return ResponsiveLayout(
              phone: _Body(maxWidth: 520, l10n: l10n, controller: controller),
              tablet: _Body(maxWidth: 720, l10n: l10n, controller: controller),
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
    required this.controller,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final QoshniNotificationTemplateController controller;

  @override
  Widget build(BuildContext context) {
    final templates = controller.templates;
    final preview = controller.lastPreviewResult;
    final localeResolution = controller.lastLocaleResolution;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppMessageBanner(
              message: l10n.notificationTemplatesDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notificationTemplatesFiltersSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<QoshniNotificationCategory?>(
              isExpanded: true,
              initialValue: controller.categoryFilter,
              decoration: InputDecoration(
                labelText: l10n.notificationCategoryFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.notificationDispatchFilterAll),
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
            DropdownButtonFormField<QoshniNotificationTemplateStatus?>(
              isExpanded: true,
              initialValue: controller.statusFilter,
              decoration: InputDecoration(
                labelText: l10n.notificationTemplateStatusFilter,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.notificationDispatchFilterAll),
                ),
                for (final status in QoshniNotificationTemplateStatus.values)
                  DropdownMenuItem(
                    value: status,
                    child: Text(
                      qoshniNotificationTemplateStatusLabel(l10n, status),
                    ),
                  ),
              ],
              onChanged: controller.setStatusFilter,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.clearFilters,
                child: Text(l10n.notificationTemplatesClearFilters),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notificationTemplatesLocaleSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<QoshniNotificationTemplateLocale>(
              segments: [
                for (final locale in QoshniNotificationTemplateLocale.values)
                  ButtonSegment(
                    value: locale,
                    label: Text(
                      qoshniNotificationTemplateLocaleLabel(l10n, locale),
                    ),
                  ),
              ],
              selected: {controller.previewLocale},
              onSelectionChanged: (selected) {
                controller.setPreviewLocale(selected.first);
              },
            ),
            if (localeResolution != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                localeResolution.usedFallback
                    ? l10n.notificationTemplatesLocaleFallbackLine(
                        qoshniNotificationTemplateLocaleLabel(
                          l10n,
                          localeResolution.requestedLocale,
                        ),
                        qoshniNotificationTemplateLocaleLabel(
                          l10n,
                          localeResolution.resolvedLocale,
                        ),
                      )
                    : l10n.notificationTemplatesLocaleExactLine(
                        qoshniNotificationTemplateLocaleLabel(
                          l10n,
                          localeResolution.resolvedLocale,
                        ),
                      ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notificationTemplatesCatalogSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (templates.isEmpty)
              AppSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(l10n.notificationTemplatesEmpty),
                ),
              )
            else
              for (final template in templates)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _TemplateTile(
                    l10n: l10n,
                    template: template,
                    selected: controller.selectedTemplateId == template.templateId,
                    onTap: () => controller.selectTemplate(template.templateId),
                  ),
                ),
            if (controller.selectedTemplate != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.notificationTemplatesPreviewSection,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (preview?.successOrNull != null) ...[
                AppSurfaceCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preview!.successOrNull!.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(preview.successOrNull!.body),
                      ],
                    ),
                  ),
                ),
              ] else if (preview?.failureOrNull != null) ...[
                AppMessageBanner(
                  message: qoshniNotificationTemplateRenderErrorLabel(
                    l10n,
                    preview!.failureOrNull!.errorCode,
                    missingVariables:
                        preview.failureOrNull!.missingVariables,
                    undeclaredPlaceholders:
                        preview.failureOrNull!.undeclaredPlaceholders,
                  ),
                  icon: Icons.error_outline,
                  tone: AppMessageTone.warning,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.l10n,
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final QoshniNotificationTemplateDefinition template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.templateKey,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    l10n.notificationTemplatesMetaLine(
                      qoshniNotificationCategoryLabel(l10n, template.category),
                      qoshniNotificationChannelLabel(l10n, template.channel),
                      qoshniNotificationTemplateStatusLabel(
                        l10n,
                        template.status,
                      ),
                      qoshniNotificationTemplateLocaleLabel(
                        l10n,
                        template.locale,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
