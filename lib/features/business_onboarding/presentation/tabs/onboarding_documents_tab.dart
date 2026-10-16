import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_controller.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_messages.dart';

class OnboardingDocumentsTab extends StatelessWidget {
  const OnboardingDocumentsTab({required this.applicationId, super.key});

  final String applicationId;

  Future<void> _register(BuildContext context, String documentType) async {
    final controller = getIt<OnboardingController>();
    final l10n = AppLocalizations.of(context);
    final ok = await controller.registerDocument(
      applicationId: applicationId,
      documentType: documentType,
    );
    if (!context.mounted) {
      return;
    }
    if (!ok && controller.lastFailure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(onboardingFailureMessage(l10n, controller.lastFailure!)),
        ),
      );
    }
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    OwnerDocumentViewDto document,
  ) async {
    final controller = getIt<OnboardingController>();
    if (controller.uploadingDocumentId != null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (!context.mounted || result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingUploadReadFailed)),
      );
      return;
    }
    if (bytes.length > onboardingMaxUploadBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingUploadTooLarge)),
      );
      return;
    }
    final name = file.name.isNotEmpty ? file.name : 'document.bin';
    final ok = await controller.uploadDocument(
      applicationId: applicationId,
      documentId: document.documentId,
      bytes: bytes,
      filename: name,
    );
    if (!context.mounted) {
      return;
    }
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingUploadSuccess)),
      );
    } else if (controller.lastFailure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(onboardingFailureMessage(l10n, controller.lastFailure!)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<OnboardingController>();
    final documents = controller.documents;
    final uploadingId = controller.uploadingDocumentId;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.onboardingDocumentsIntro,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: AppSpacing.md),
              if (controller.documentsBusy && documents.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (documents.isEmpty)
                AppSurfaceCard(
                  child: Text(l10n.onboardingDocumentsEmpty),
                )
              else
                for (final doc in documents) ...[
                  AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _docTypeLabel(l10n, doc.documentType),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          onboardingDocumentLifecycleLabel(l10n, doc.lifecycleState),
                        ),
                        const SizedBox(height: 12),
                        if (doc.lifecycleState == 'awaiting_upload')
                          FilledButton.icon(
                            onPressed: uploadingId != null
                                ? null
                                : () => _pickAndUpload(context, doc),
                            icon: uploadingId == doc.documentId
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.upload_file),
                            label: Text(l10n.onboardingUploadAction),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.onboardingRegisterDocumentTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in OnboardingDocumentTypes.all)
                    OutlinedButton(
                      onPressed: controller.documentsBusy
                          ? null
                          : () => _register(context, type),
                      child: Text(_docTypeLabel(l10n, type)),
                    ),
                ],
              ),
              if (controller.lastFailure != null &&
                  controller.documents.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AppMessageBanner(
                  message: onboardingFailureMessage(l10n, controller.lastFailure!),
                  icon: Icons.error_outline,
                  tone: AppMessageTone.error,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _docTypeLabel(AppLocalizations l10n, String type) {
    return switch (type) {
      OnboardingDocumentTypes.registrationCertificate =>
        l10n.onboardingDocTypeRegistrationCertificate,
      OnboardingDocumentTypes.taxRegistration => l10n.onboardingDocTypeTaxRegistration,
      OnboardingDocumentTypes.authorizedRepresentativeId =>
        l10n.onboardingDocTypeRepresentativeId,
      OnboardingDocumentTypes.otherSupporting => l10n.onboardingDocTypeOtherSupporting,
      _ => type,
    };
  }
}
