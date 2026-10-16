import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_onboarding/data/onboarding_dtos.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_controller.dart';
import 'package:qoshni/features/business_onboarding/presentation/onboarding_messages.dart';

class OnboardingFormTab extends StatefulWidget {
  const OnboardingFormTab({
    required this.applicationId,
    required this.application,
    super.key,
  });

  final String applicationId;
  final OwnerApplicationViewDto application;

  @override
  State<OnboardingFormTab> createState() => _OnboardingFormTabState();
}

class _OnboardingFormTabState extends State<OnboardingFormTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _legalNameController;
  late final TextEditingController _tradeNameController;
  late final TextEditingController _jurisdictionController;
  late final TextEditingController _registrationIdController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _emailController;
  String? _serviceCategory;

  bool get _editable => widget.application.isDraft;

  @override
  void initState() {
    super.initState();
    final app = widget.application;
    _legalNameController = TextEditingController(text: app.legalBusinessName ?? '');
    _tradeNameController = TextEditingController(text: app.tradeDisplayName ?? '');
    _jurisdictionController =
        TextEditingController(text: app.registrationJurisdiction);
    _registrationIdController =
        TextEditingController(text: app.registrationIdentifier ?? '');
    _taxIdController = TextEditingController(text: app.taxIdentifier ?? '');
    _emailController = TextEditingController(text: app.businessContactEmail ?? '');
    _serviceCategory = app.serviceCategory;
  }

  @override
  void didUpdateWidget(covariant OnboardingFormTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.application.updatedAt != widget.application.updatedAt) {
      final app = widget.application;
      _legalNameController.text = app.legalBusinessName ?? '';
      _tradeNameController.text = app.tradeDisplayName ?? '';
      _jurisdictionController.text = app.registrationJurisdiction;
      _registrationIdController.text = app.registrationIdentifier ?? '';
      _taxIdController.text = app.taxIdentifier ?? '';
      _emailController.text = app.businessContactEmail ?? '';
      _serviceCategory = app.serviceCategory;
    }
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _tradeNameController.dispose();
    _jurisdictionController.dispose();
    _registrationIdController.dispose();
    _taxIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.length < 3 || !trimmed.contains('@')) {
      return AppLocalizations.of(context).onboardingValidationEmailInvalid;
    }
    return null;
  }

  Future<void> _saveDraft() async {
    if (!_editable) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final controller = getIt<OnboardingController>();
    final ok = await controller.saveDraft(
      applicationId: widget.applicationId,
      request: OnboardingApplicationDraftUpdateRequestDto(
        legalBusinessName: _legalNameController.text.trim(),
        tradeDisplayName: _tradeNameController.text.trim().isEmpty
            ? null
            : _tradeNameController.text.trim(),
        serviceCategory: _serviceCategory,
        registrationJurisdiction: _jurisdictionController.text.trim().toUpperCase(),
        registrationIdentifier: _registrationIdController.text.trim().isEmpty
            ? null
            : _registrationIdController.text.trim(),
        taxIdentifier: _taxIdController.text.trim().isEmpty
            ? null
            : _taxIdController.text.trim(),
        businessContactEmail: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      ),
    );
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingDraftSaved)),
      );
    } else if (controller.lastFailure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(onboardingFailureMessage(l10n, controller.lastFailure!)),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_editable) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    if (_legalNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingValidationLegalNameRequired)),
      );
      return;
    }
    if (_serviceCategory == null || _serviceCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingValidationCategoryRequired)),
      );
      return;
    }
    await _saveDraft();
    if (!mounted) {
      return;
    }
    final controller = getIt<OnboardingController>();
    final ok = await controller.submitApplication(widget.applicationId);
    if (!mounted) {
      return;
    }
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingSubmitSuccess)),
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
    final busy = controller.saveBusy || controller.submitBusy;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_editable)
                  AppMessageBanner(
                    message: l10n.onboardingFormReadOnlyNotice,
                    icon: Icons.info_outline,
                  ),
                if (!_editable) const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _legalNameController,
                  readOnly: !_editable,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldLegalName,
                  ),
                  validator: (v) {
                    if (!_editable) {
                      return null;
                    }
                    if (v == null || v.trim().isEmpty) {
                      return l10n.onboardingValidationLegalNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tradeNameController,
                  readOnly: !_editable,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldTradeName,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _serviceCategory,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldServiceCategory,
                  ),
                  items: [
                    for (final cat in OnboardingServiceCategories.all)
                      DropdownMenuItem(
                        value: cat,
                        child: Text(_categoryLabel(l10n, cat)),
                      ),
                  ],
                  onChanged: !_editable
                      ? null
                      : (value) => setState(() => _serviceCategory = value),
                  validator: (v) {
                    if (!_editable) {
                      return null;
                    }
                    if (v == null || v.isEmpty) {
                      return l10n.onboardingValidationCategoryRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jurisdictionController,
                  readOnly: !_editable,
                  maxLength: 2,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldJurisdiction,
                    counterText: '',
                  ),
                  validator: (v) {
                    if (!_editable) {
                      return null;
                    }
                    final j = v?.trim() ?? '';
                    if (j.length != 2) {
                      return l10n.onboardingValidationJurisdictionInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _registrationIdController,
                  readOnly: !_editable,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldRegistrationId,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _taxIdController,
                  readOnly: !_editable,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldTaxIdOptional,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  readOnly: !_editable,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldContactEmailOptional,
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_editable) ...[
                  FilledButton(
                    onPressed: busy ? null : _saveDraft,
                    child: Text(
                      busy ? l10n.userProfileSaving : l10n.onboardingSaveDraftAction,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: busy ? null : _submit,
                    child: Text(l10n.onboardingSubmitAction),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _categoryLabel(AppLocalizations l10n, String cat) {
    return switch (cat) {
      OnboardingServiceCategories.groceries => l10n.onboardingCategoryGroceries,
      OnboardingServiceCategories.restaurants => l10n.onboardingCategoryRestaurants,
      OnboardingServiceCategories.pharmacy => l10n.onboardingCategoryPharmacy,
      OnboardingServiceCategories.shops => l10n.onboardingCategoryShops,
      OnboardingServiceCategories.masters => l10n.onboardingCategoryMasters,
      OnboardingServiceCategories.rent => l10n.onboardingCategoryRent,
      _ => cat,
    };
  }
}
