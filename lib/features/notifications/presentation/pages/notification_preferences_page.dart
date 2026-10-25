import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/notifications/domain/qoshni_local_time.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_preferences.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_quiet_hours.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_preference_repository.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_eligibility_labels.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_labels.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_local_time_format.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_preference_controller.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  QoshniNotificationCategory _previewCategory =
      QoshniNotificationCategory.orders;
  QoshniNotificationChannel _previewChannel =
      QoshniNotificationChannel.inApp;
  QoshniNotificationPriority _previewPriority =
      QoshniNotificationPriority.normal;
  DateTime _previewLocalDateTime = DateTime(2025, 4, 10, 23, 30);
  QoshniNotificationEligibilityResult? _previewResult;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _operationMessage(AppLocalizations l10n, String? key) {
    return switch (key) {
      'preferenceSaveSuccess' => l10n.notificationPreferenceSaveSuccess,
      'preferenceSaveInvalid' => l10n.notificationPreferenceSaveInvalid,
      'preferenceSaveFailure' => l10n.notificationPreferenceSaveFailure,
      'preferenceRestoreSuccess' => l10n.notificationPreferenceRestoreSuccess,
      _ => null,
    };
  }

  Future<void> _pickLocalTime({
    required QoshniLocalTime initial,
    required ValueChanged<QoshniLocalTime> onSelected,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    if (picked == null) {
      return;
    }
    onSelected(QoshniLocalTime(hour: picked.hour, minute: picked.minute));
  }

  Future<void> _pickPreviewEvaluationTime() async {
    final initial = TimeOfDay(
      hour: _previewLocalDateTime.hour,
      minute: _previewLocalDateTime.minute,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) {
      return;
    }
    setState(() {
      _previewLocalDateTime = DateTime(
        _previewLocalDateTime.year,
        _previewLocalDateTime.month,
        _previewLocalDateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _runPreview(QoshniNotificationPreferenceController controller) {
    final result = controller.evaluateHypothetical(
      scenario: QoshniNotificationEligibilityInput(
        category: _previewCategory,
        channel: _previewChannel,
        priority: _previewPriority,
      ),
      evaluationLocalDateTime: _previewLocalDateTime,
    );
    setState(() => _previewResult = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final controller = getIt<QoshniNotificationPreferenceController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.notificationPreferencesTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final prefs = controller.preferences;
            final quiet = prefs.quietHours;

            return ResponsiveLayout(
              phone: _PreferencesBody(
                maxWidth: 520,
                l10n: l10n,
                locale: locale,
                controller: controller,
                prefs: prefs,
                quiet: quiet,
                previewCategory: _previewCategory,
                previewChannel: _previewChannel,
                previewPriority: _previewPriority,
                previewLocalDateTime: _previewLocalDateTime,
                previewResult: _previewResult,
                onPreviewCategoryChanged: (v) =>
                    setState(() => _previewCategory = v),
                onPreviewChannelChanged: (v) =>
                    setState(() => _previewChannel = v),
                onPreviewPriorityChanged: (v) =>
                    setState(() => _previewPriority = v),
                onPickPreviewTime: _pickPreviewEvaluationTime,
                onRunPreview: () => _runPreview(controller),
                onPickQuietStart: () => _pickLocalTime(
                  initial: quiet.start,
                  onSelected: (time) {
                    final result = controller.setQuietHours(
                      enabled: quiet.enabled,
                      start: time,
                      end: quiet.end,
                    );
                    final msg = _operationMessage(
                      l10n,
                      controller.lastOperationMessageKey,
                    );
                    if (msg != null) {
                      _showSnack(msg);
                    }
                    if (result ==
                        QoshniNotificationPreferenceUpdateResult.invalidInput) {
                      return;
                    }
                  },
                ),
                onPickQuietEnd: () => _pickLocalTime(
                  initial: quiet.end,
                  onSelected: (time) {
                    controller.setQuietHours(
                      enabled: quiet.enabled,
                      start: quiet.start,
                      end: time,
                    );
                    final msg = _operationMessage(
                      l10n,
                      controller.lastOperationMessageKey,
                    );
                    if (msg != null) {
                      _showSnack(msg);
                    }
                  },
                ),
                onRestoreDefaults: () {
                  controller.restoreDemoDefaults();
                  final msg = _operationMessage(
                    l10n,
                    controller.lastOperationMessageKey,
                  );
                  if (msg != null) {
                    _showSnack(msg);
                  }
                },
              ),
              tablet: _PreferencesBody(
                maxWidth: 720,
                l10n: l10n,
                locale: locale,
                controller: controller,
                prefs: prefs,
                quiet: quiet,
                previewCategory: _previewCategory,
                previewChannel: _previewChannel,
                previewPriority: _previewPriority,
                previewLocalDateTime: _previewLocalDateTime,
                previewResult: _previewResult,
                onPreviewCategoryChanged: (v) =>
                    setState(() => _previewCategory = v),
                onPreviewChannelChanged: (v) =>
                    setState(() => _previewChannel = v),
                onPreviewPriorityChanged: (v) =>
                    setState(() => _previewPriority = v),
                onPickPreviewTime: _pickPreviewEvaluationTime,
                onRunPreview: () => _runPreview(controller),
                onPickQuietStart: () => _pickLocalTime(
                  initial: quiet.start,
                  onSelected: (time) {
                    controller.setQuietHours(
                      enabled: quiet.enabled,
                      start: time,
                      end: quiet.end,
                    );
                  },
                ),
                onPickQuietEnd: () => _pickLocalTime(
                  initial: quiet.end,
                  onSelected: (time) {
                    controller.setQuietHours(
                      enabled: quiet.enabled,
                      start: quiet.start,
                      end: time,
                    );
                  },
                ),
                onRestoreDefaults: () {
                  controller.restoreDemoDefaults();
                  final msg = _operationMessage(
                    l10n,
                    controller.lastOperationMessageKey,
                  );
                  if (msg != null) {
                    _showSnack(msg);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PreferencesBody extends StatelessWidget {
  const _PreferencesBody({
    required this.maxWidth,
    required this.l10n,
    required this.locale,
    required this.controller,
    required this.prefs,
    required this.quiet,
    required this.previewCategory,
    required this.previewChannel,
    required this.previewPriority,
    required this.previewLocalDateTime,
    required this.previewResult,
    required this.onPreviewCategoryChanged,
    required this.onPreviewChannelChanged,
    required this.onPreviewPriorityChanged,
    required this.onPickPreviewTime,
    required this.onRunPreview,
    required this.onPickQuietStart,
    required this.onPickQuietEnd,
    required this.onRestoreDefaults,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final String locale;
  final QoshniNotificationPreferenceController controller;
  final QoshniNotificationPreferences prefs;
  final QoshniNotificationQuietHours quiet;
  final QoshniNotificationCategory previewCategory;
  final QoshniNotificationChannel previewChannel;
  final QoshniNotificationPriority previewPriority;
  final DateTime previewLocalDateTime;
  final QoshniNotificationEligibilityResult? previewResult;
  final ValueChanged<QoshniNotificationCategory> onPreviewCategoryChanged;
  final ValueChanged<QoshniNotificationChannel> onPreviewChannelChanged;
  final ValueChanged<QoshniNotificationPriority> onPreviewPriorityChanged;
  final VoidCallback onPickPreviewTime;
  final VoidCallback onRunPreview;
  final VoidCallback onPickQuietStart;
  final VoidCallback onPickQuietEnd;
  final VoidCallback onRestoreDefaults;

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
              message: l10n.notificationPreferencesDemoDisclaimer,
              icon: Icons.info_outline,
              tone: AppMessageTone.info,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.notificationPreferencesInMemoryNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notificationPreferencesCategoriesSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            AppSurfaceCard(
              child: Column(
                children: [
                  for (final category in QoshniNotificationCategory.values)
                    SwitchListTile(
                      title: Text(
                        qoshniNotificationCategoryLabel(l10n, category),
                      ),
                      value: prefs.isCategoryEnabled(category),
                      onChanged: (value) {
                        controller.setCategoryEnabled(
                          category: category,
                          enabled: value,
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notificationPreferencesChannelsSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            AppSurfaceCard(
              child: Column(
                children: [
                  for (final channel in QoshniNotificationChannel.values)
                    SwitchListTile(
                      title: Text(
                        qoshniNotificationChannelLabel(l10n, channel),
                      ),
                      subtitle: Text(l10n.notificationChannelPreviewNote),
                      value: prefs.isChannelEnabled(channel),
                      onChanged: (value) {
                        controller.setChannelEnabled(
                          channel: channel,
                          enabled: value,
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: SwitchListTile(
                title: Text(l10n.notificationPromotionalConsentTitle),
                subtitle: Text(l10n.notificationPromotionalConsentBody),
                value: prefs.promotionalMarketingConsent,
                onChanged: controller.setPromotionalMarketingConsent,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.notificationQuietHoursSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            AppSurfaceCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.notificationQuietHoursEnabled),
                    subtitle: Text(l10n.notificationQuietHoursLocalTimeNote),
                    value: quiet.enabled,
                    onChanged: (enabled) {
                      controller.setQuietHours(
                        enabled: enabled,
                        start: quiet.start,
                        end: quiet.end,
                      );
                    },
                  ),
                  ListTile(
                    title: Text(l10n.notificationQuietHoursStart),
                    subtitle: Text(formatQoshniLocalTime(quiet.start, locale)),
                    trailing: const Icon(Icons.schedule),
                    onTap: onPickQuietStart,
                  ),
                  ListTile(
                    title: Text(l10n.notificationQuietHoursEnd),
                    subtitle: Text(formatQoshniLocalTime(quiet.end, locale)),
                    trailing: const Icon(Icons.schedule),
                    onTap: onPickQuietEnd,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRestoreDefaults,
              icon: const Icon(Icons.restore_outlined),
              label: Text(l10n.notificationPreferencesRestoreDefaults),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.notificationEligibilityPreviewSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSurfaceCard(
              child: Column(
                children: [
                  DropdownButtonFormField<QoshniNotificationCategory>(
                    isExpanded: true,
                    initialValue: previewCategory,
                    decoration: InputDecoration(
                      labelText: l10n.notificationCategoryFilter,
                    ),
                    items: [
                      for (final category in QoshniNotificationCategory.values)
                        DropdownMenuItem(
                          value: category,
                          child: Text(
                            qoshniNotificationCategoryLabel(l10n, category),
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onPreviewCategoryChanged(value);
                      }
                    },
                  ),
                  DropdownButtonFormField<QoshniNotificationChannel>(
                    isExpanded: true,
                    initialValue: previewChannel,
                    decoration: InputDecoration(
                      labelText: l10n.notificationPreferencesPreviewChannel,
                    ),
                    items: [
                      for (final channel in QoshniNotificationChannel.values)
                        DropdownMenuItem(
                          value: channel,
                          child: Text(
                            qoshniNotificationChannelLabel(l10n, channel),
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onPreviewChannelChanged(value);
                      }
                    },
                  ),
                  DropdownButtonFormField<QoshniNotificationPriority>(
                    isExpanded: true,
                    initialValue: previewPriority,
                    decoration: InputDecoration(
                      labelText: l10n.notificationPreferencesPreviewPriority,
                    ),
                    items: [
                      for (final priority in QoshniNotificationPriority.values)
                        DropdownMenuItem(
                          value: priority,
                          child: Text(
                            qoshniNotificationPriorityLabel(l10n, priority),
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onPreviewPriorityChanged(value);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(l10n.notificationEligibilityPreviewTime),
                    subtitle: Text(formatQoshniLocalTime(
                      qoshniLocalTimeFromDateTime(previewLocalDateTime),
                      locale,
                    )),
                    trailing: const Icon(Icons.access_time),
                    onTap: onPickPreviewTime,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: onRunPreview,
                    child: Text(l10n.notificationEligibilityPreviewAction),
                  ),
                  if (previewResult != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      previewResult!.isEligible
                          ? l10n.notificationEligibilityPreviewEligible
                          : l10n.notificationEligibilityPreviewSuppressed,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      qoshniNotificationEligibilityReasonLabel(
                        l10n,
                        previewResult!.reason,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
