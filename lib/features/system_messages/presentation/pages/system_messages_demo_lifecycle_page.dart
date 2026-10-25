import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_mutation_result.dart';
import 'package:qoshni/features/system_messages/presentation/qoshni_system_message_controller.dart';
import 'package:qoshni/features/system_messages/presentation/qoshni_system_message_labels.dart';

class SystemMessagesDemoLifecyclePage extends StatelessWidget {
  const SystemMessagesDemoLifecyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<QoshniSystemMessageController>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.systemMessagesDemoLifecycleTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final items = controller.managementList();
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AppMessageBanner(
                  message: l10n.systemMessagesDemoLifecycleDisclaimer,
                  icon: Icons.info_outline,
                  tone: AppMessageTone.info,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final message in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _LifecycleTile(l10n: l10n, message: message),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LifecycleTile extends StatelessWidget {
  const _LifecycleTile({required this.l10n, required this.message});

  final AppLocalizations l10n;
  final QoshniSystemMessage message;

  @override
  Widget build(BuildContext context) {
    final controller = getIt<QoshniSystemMessageController>();
    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.messageKey,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              qoshniSystemMessageLifecycleLabel(l10n, message.lifecycleStatus),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                if (message.lifecycleStatus ==
                    QoshniSystemMessageLifecycleStatus.draft)
                  OutlinedButton(
                    onPressed: () => _mutate(
                      context,
                      controller.publishDraft(message.messageId),
                      l10n.systemMessagePublishAction,
                    ),
                    child: Text(l10n.systemMessagePublishAction),
                  ),
                if (message.lifecycleStatus ==
                    QoshniSystemMessageLifecycleStatus.published)
                  OutlinedButton(
                    onPressed: () => _mutate(
                      context,
                      controller.withdrawMessage(message.messageId),
                      l10n.systemMessageWithdrawAction,
                    ),
                    child: Text(l10n.systemMessageWithdrawAction),
                  ),
                if (message.lifecycleStatus ==
                        QoshniSystemMessageLifecycleStatus.published ||
                    message.lifecycleStatus ==
                        QoshniSystemMessageLifecycleStatus.withdrawn)
                  OutlinedButton(
                    onPressed: () => _mutate(
                      context,
                      controller.archiveMessage(message.messageId),
                      l10n.systemMessageArchiveAction,
                    ),
                    child: Text(l10n.systemMessageArchiveAction),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mutate(
    BuildContext context,
    QoshniSystemMessageMutationResult result,
    String action,
  ) {
    final message = switch (result) {
      QoshniSystemMessageMutationResult.success =>
        '$action: ${l10n.systemMessageMutationSuccess}',
      QoshniSystemMessageMutationResult.invalidTransition =>
        l10n.systemMessageMutationInvalidTransition,
      QoshniSystemMessageMutationResult.validationFailed =>
        l10n.systemMessageMutationValidationFailed,
      QoshniSystemMessageMutationResult.notFound =>
        l10n.systemMessageMutationNotFound,
      QoshniSystemMessageMutationResult.duplicateMessageKey =>
        l10n.systemMessageMutationValidationFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
