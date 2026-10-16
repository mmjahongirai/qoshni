import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile.dart';
import 'package:qoshni/features/business_platform/domain/business_owner_profile_status.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_owner_profile_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_owner_profile_validation.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

class BusinessOwnerProfileEditorPage extends StatefulWidget {
  const BusinessOwnerProfileEditorPage({super.key});

  @override
  State<BusinessOwnerProfileEditorPage> createState() =>
      _BusinessOwnerProfileEditorPageState();
}

class _BusinessOwnerProfileEditorPageState
    extends State<BusinessOwnerProfileEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _legalNameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late ServiceCategoryId _categoryId;
  late BusinessOwnerProfileVisibility _visibility;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final profile = getIt<BusinessOwnerProfileController>().profile;
    _legalNameController = TextEditingController(text: profile.legalBusinessName);
    _displayNameController = TextEditingController(text: profile.displayName);
    _descriptionController = TextEditingController(text: profile.description);
    _phoneController = TextEditingController(text: profile.contactPhone ?? '');
    _emailController = TextEditingController(text: profile.contactEmail ?? '');
    _websiteController = TextEditingController(text: profile.websiteUrl ?? '');
    _categoryId = profile.categoryId;
    _visibility = profile.visibility;
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
    }
  }

  BusinessOwnerProfileInput _buildInput() {
    return BusinessOwnerProfileInput(
      legalBusinessName: _legalNameController.text,
      displayName: _displayNameController.text,
      description: _descriptionController.text,
      categoryId: _categoryId,
      contactPhone: _phoneController.text,
      contactEmail: _emailController.text,
      websiteUrl: _websiteController.text,
      visibility: _visibility,
    );
  }

  Future<void> _onCancel() async {
    if (!_dirty) {
      if (mounted) {
        context.pop();
      }
      return;
    }
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ownerProfileDiscardConfirmTitle),
        content: Text(l10n.ownerProfileDiscardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.ownerProfileCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.ownerProfileDiscardConfirmAction),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      context.pop();
    }
  }

  Future<void> _onSave() async {
    final l10n = AppLocalizations.of(context);
    final input = _buildInput();
    final validation = validateBusinessOwnerProfileInput(
      input,
      legalNameRequired: () => l10n.ownerProfileValidationLegalName,
      displayNameRequired: () => l10n.ownerProfileValidationDisplayName,
      descriptionRequired: () => l10n.ownerProfileValidationDescription,
      emailInvalid: () => l10n.ownerProfileValidationEmail,
      websiteInvalid: () => l10n.ownerProfileValidationWebsite,
    );
    if (!validation.isValid) {
      _formKey.currentState?.validate();
      setState(() {});
      return;
    }

    final controller = getIt<BusinessOwnerProfileController>();
    final result = await controller.save(input);
    if (!mounted) {
      return;
    }
    if (result == BusinessOwnerProfileSaveResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ownerProfileSaveSuccess)),
      );
      context.pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.ownerProfileSaveFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = getIt<BusinessOwnerProfileController>();

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _onCancel();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _onCancel),
          title: Text(l10n.ownerProfileEditorTitle),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return ResponsiveLayout(
                phone: _EditorForm(
                  maxWidth: 520,
                  formKey: _formKey,
                  saveBusy: controller.saveBusy,
                  legalNameController: _legalNameController,
                  displayNameController: _displayNameController,
                  descriptionController: _descriptionController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  websiteController: _websiteController,
                  categoryId: _categoryId,
                  visibility: _visibility,
                  onCategoryChanged: (value) {
                    setState(() => _categoryId = value);
                    _markDirty();
                  },
                  onVisibilityChanged: (value) {
                    setState(() => _visibility = value);
                    _markDirty();
                  },
                  onFieldChanged: _markDirty,
                  onSave: controller.saveBusy ? null : _onSave,
                  onCancel: _onCancel,
                ),
                tablet: _EditorForm(
                  maxWidth: 760,
                  formKey: _formKey,
                  saveBusy: controller.saveBusy,
                  legalNameController: _legalNameController,
                  displayNameController: _displayNameController,
                  descriptionController: _descriptionController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  websiteController: _websiteController,
                  categoryId: _categoryId,
                  visibility: _visibility,
                  onCategoryChanged: (value) {
                    setState(() => _categoryId = value);
                    _markDirty();
                  },
                  onVisibilityChanged: (value) {
                    setState(() => _visibility = value);
                    _markDirty();
                  },
                  onFieldChanged: _markDirty,
                  onSave: controller.saveBusy ? null : _onSave,
                  onCancel: _onCancel,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditorForm extends StatelessWidget {
  const _EditorForm({
    required this.maxWidth,
    required this.formKey,
    required this.saveBusy,
    required this.legalNameController,
    required this.displayNameController,
    required this.descriptionController,
    required this.phoneController,
    required this.emailController,
    required this.websiteController,
    required this.categoryId,
    required this.visibility,
    required this.onCategoryChanged,
    required this.onVisibilityChanged,
    required this.onFieldChanged,
    required this.onSave,
    required this.onCancel,
  });

  final double maxWidth;
  final GlobalKey<FormState> formKey;
  final bool saveBusy;
  final TextEditingController legalNameController;
  final TextEditingController displayNameController;
  final TextEditingController descriptionController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController websiteController;
  final ServiceCategoryId categoryId;
  final BusinessOwnerProfileVisibility visibility;
  final ValueChanged<ServiceCategoryId> onCategoryChanged;
  final ValueChanged<BusinessOwnerProfileVisibility> onVisibilityChanged;
  final VoidCallback onFieldChanged;
  final VoidCallback? onSave;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppMessageBanner(
                  message: l10n.ownerProfilePreviewNotice,
                  icon: Icons.info_outline,
                  tone: AppMessageTone.info,
                ),
                const SizedBox(height: AppSpacing.md),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ownerProfileSectionBasics,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: legalNameController,
                        decoration: InputDecoration(
                          labelText: l10n.ownerProfileLegalName,
                        ),
                        onChanged: (_) => onFieldChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.ownerProfileValidationLegalName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: displayNameController,
                        decoration: InputDecoration(
                          labelText: l10n.ownerProfileDisplayName,
                        ),
                        onChanged: (_) => onFieldChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.ownerProfileValidationDisplayName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.ownerProfileDescription,
                        ),
                        minLines: 3,
                        maxLines: 5,
                        onChanged: (_) => onFieldChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.ownerProfileValidationDescription;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<ServiceCategoryId>(
                        isExpanded: true,
                        value: categoryId,
                        decoration: InputDecoration(
                          labelText: l10n.ownerProfileCategory,
                        ),
                        items: [
                          for (final id in ServiceCategoryId.values)
                            DropdownMenuItem(
                              value: id,
                              child: Text(serviceCategoryLabel(id, l10n)),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            onCategoryChanged(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ownerProfileSectionContact,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: l10n.ownerProfileContactPhone,
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => onFieldChanged(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: l10n.ownerProfileContactEmail,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => onFieldChanged(),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return null;
                          }
                          final result = validateBusinessOwnerProfileInput(
                            BusinessOwnerProfileInput(
                              legalBusinessName: 'x',
                              displayName: 'x',
                              description: 'x',
                              categoryId: categoryId,
                              contactEmail: trimmed,
                            ),
                            legalNameRequired: () => '',
                            displayNameRequired: () => '',
                            descriptionRequired: () => '',
                            emailInvalid: () => l10n.ownerProfileValidationEmail,
                            websiteInvalid: () => '',
                          );
                          return result.contactEmailError;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: websiteController,
                        decoration: InputDecoration(
                          labelText: l10n.ownerProfileWebsite,
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: (_) => onFieldChanged(),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return null;
                          }
                          final result = validateBusinessOwnerProfileInput(
                            BusinessOwnerProfileInput(
                              legalBusinessName: 'x',
                              displayName: 'x',
                              description: 'x',
                              categoryId: categoryId,
                              websiteUrl: trimmed,
                            ),
                            legalNameRequired: () => '',
                            displayNameRequired: () => '',
                            descriptionRequired: () => '',
                            emailInvalid: () => '',
                            websiteInvalid: () =>
                                l10n.ownerProfileValidationWebsite,
                          );
                          return result.websiteUrlError;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ownerProfileSectionSettings,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<BusinessOwnerProfileVisibility>(
                        isExpanded: true,
                        value: visibility,
                        decoration: InputDecoration(
                          labelText: l10n.ownerProfileVisibility,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: BusinessOwnerProfileVisibility.hiddenPreview,
                            child: Text(
                              l10n.ownerProfileVisibilityHidden,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: BusinessOwnerProfileVisibility.visibleInPreview,
                            child: Text(
                              l10n.ownerProfileVisibilityVisible,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            onVisibilityChanged(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onSave,
                  child: saveBusy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.ownerProfileSaveAction),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: saveBusy ? null : onCancel,
                  child: Text(l10n.ownerProfileCancelAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
