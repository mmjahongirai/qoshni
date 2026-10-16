import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_controller.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_messages.dart';

class OnboardingVerificationTab extends StatelessWidget {
  const OnboardingVerificationTab({required this.applicationId, super.key});

  final String applicationId;

  String _formatDate(BuildContext context, DateTime? value) {
    if (value == null) {
      return '—';
    }
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).add_jm().format(value.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<OnboardingController>();
    final status = controller.verificationStatus;
    final app = controller.selectedApplication;

    if (controller.detailBusy && status == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final verificationStatus =
        status?.verificationStatus ?? app?.verificationStatus ?? 'draft';
    final rejection = status?.rejectionReasonCode ?? app?.rejectionReasonCode;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.onboardingVerificationCurrentStatus,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  onboardingStatusLabel(l10n, verificationStatus),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                _RowLabel(
                  label: l10n.onboardingVerificationSubmittedAt,
                  value: _formatDate(context, status?.submittedAt ?? app?.submittedAt),
                ),
                const SizedBox(height: 8),
                _RowLabel(
                  label: l10n.onboardingVerificationReviewedAt,
                  value: _formatDate(context, status?.reviewedAt ?? app?.reviewedAt),
                ),
                if (rejection != null && rejection.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.onboardingVerificationRejectionTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(onboardingRejectionLabel(l10n, rejection)),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _nextSteps(l10n, verificationStatus),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _nextSteps(AppLocalizations l10n, String status) {
    return switch (status) {
      'draft' => l10n.onboardingNextStepsDraft,
      'submitted' => l10n.onboardingNextStepsSubmitted,
      'under_review' => l10n.onboardingNextStepsUnderReview,
      'verified' => l10n.onboardingNextStepsVerified,
      'rejected' => l10n.onboardingNextStepsRejected,
      'suspended' => l10n.onboardingNextStepsSuspended,
      _ => l10n.onboardingNextStepsGeneric,
    };
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(value),
        ),
      ],
    );
  }
}
