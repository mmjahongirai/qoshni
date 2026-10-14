import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/business_platform/presentation/business_profile_controller.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessProfileFormPage extends StatefulWidget {
  const BusinessProfileFormPage({
    this.draftId,
    this.seed,
    super.key,
  });

  /// When set, edits an existing user draft.
  final String? draftId;

  /// Optional initial values (e.g. copied from a sample profile).
  final BusinessProfileFormSeed? seed;

  @override
  State<BusinessProfileFormPage> createState() =>
      _BusinessProfileFormPageState();
}

class _BusinessProfileFormPageState extends State<BusinessProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _hoursController;
  late final TextEditingController _phoneController;
  late ServiceCategoryId _categoryId;
  bool _isSaving = false;

  bool get _isEdit => widget.draftId != null && widget.draftId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    BusinessProfileDraft? existing;
    if (_isEdit) {
      existing =
          getIt<BusinessProfileController>().userDraftById(widget.draftId!);
    }

    final seed = widget.seed;
    _nameController = TextEditingController(
      text: existing?.businessName ?? seed?.businessName ?? '',
    );
    _descriptionController = TextEditingController(
      text: existing?.description ?? seed?.description ?? '',
    );
    _addressController = TextEditingController(
      text: existing?.addressDescription ?? seed?.addressDescription ?? '',
    );
    _hoursController = TextEditingController(
      text: existing?.workingHours ?? seed?.workingHours ?? '',
    );
    _phoneController = TextEditingController(
      text: existing?.contactPhone ?? seed?.contactPhone ?? '',
    );
    _categoryId = existing?.categoryId ??
        seed?.categoryId ??
        ServiceCategoryId.shops;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isEdit &&
        getIt<BusinessProfileController>().userDraftById(widget.draftId!) ==
            null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.businessProfileFormEditTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.businessProfileNotFoundBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          _isEdit
              ? l10n.businessProfileFormEditTitle
              : l10n.businessProfileFormCreateTitle,
        ),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          phone: _FormScroll(
            maxWidth: 520,
            child: _buildForm(context, l10n),
          ),
          tablet: _FormScroll(
            maxWidth: 760,
            child: _buildForm(context, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMessageBanner(
            message: l10n.businessProfileFormLocalSaveNotice,
            icon: Icons.save_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.businessProfileFieldName,
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.businessProfileValidationNameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<ServiceCategoryId>(
            value: _categoryId,
            decoration: InputDecoration(
              labelText: l10n.businessProfileFieldCategory,
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
                setState(() => _categoryId = value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.businessProfileFieldDescription,
            ),
            minLines: 3,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.businessProfileValidationDescriptionRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: l10n.businessProfileFieldAddress,
            ),
            minLines: 2,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.businessProfileValidationAddressRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _hoursController,
            decoration: InputDecoration(
              labelText: l10n.businessProfileFieldHours,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.businessProfileValidationHoursRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: l10n.businessProfileFieldPhoneOptional,
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _isSaving ? null : () => _save(context, l10n),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.businessProfileSaveAction),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _isSaving ? null : () => context.pop(),
            child: Text(l10n.businessProfileCancelAction),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final controller = getIt<BusinessProfileController>();
    final phone = _phoneController.text;

    if (_isEdit) {
      final ok = controller.updateDraft(
        id: widget.draftId!,
        businessName: _nameController.text,
        categoryId: _categoryId,
        description: _descriptionController.text,
        addressDescription: _addressController.text,
        workingHours: _hoursController.text,
        contactPhone: phone,
      );
      if (!context.mounted) {
        return;
      }
      setState(() => _isSaving = false);
      if (ok) {
        context.pop();
      }
      return;
    }

    final newId = controller.createDraft(
      businessName: _nameController.text,
      categoryId: _categoryId,
      description: _descriptionController.text,
      addressDescription: _addressController.text,
      workingHours: _hoursController.text,
      contactPhone: phone,
    );

    if (!context.mounted) {
      return;
    }
    setState(() => _isSaving = false);
    context.goNamed(
      RouteNames.businessProfileDetail,
      pathParameters: {'profileId': newId},
    );
  }
}

class _FormScroll extends StatelessWidget {
  const _FormScroll({
    required this.maxWidth,
    required this.child,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
