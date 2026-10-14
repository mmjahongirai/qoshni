import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_pricing_unit.dart';
import 'package:qoshni/features/business_platform/presentation/business_offerings_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_profile_controller.dart';

class BusinessOfferingFormPage extends StatefulWidget {
  const BusinessOfferingFormPage({
    required this.profileId,
    this.offeringId,
    super.key,
  });

  final String? profileId;
  final String? offeringId;

  @override
  State<BusinessOfferingFormPage> createState() =>
      _BusinessOfferingFormPageState();
}

class _BusinessOfferingFormPageState extends State<BusinessOfferingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _depositController;
  late BusinessOfferingKind _kind;
  late BusinessPricingUnit _pricingUnit;
  bool _isSaving = false;

  bool get _isEdit =>
      widget.offeringId != null && widget.offeringId!.isNotEmpty;

  String? get _profileId => widget.profileId?.trim();

  @override
  void initState() {
    super.initState();
    final offerings = getIt<BusinessOfferingsController>();
    final profileId = _profileId;
    final offering = _isEdit && profileId != null
        ? offerings.offeringById(
            businessProfileId: profileId,
            offeringId: widget.offeringId!,
          )
        : null;

    _nameController = TextEditingController(text: offering?.name ?? '');
    _descriptionController =
        TextEditingController(text: offering?.description ?? '');
    _priceController = TextEditingController(
      text: offering?.samplePriceUzs?.toString() ?? '',
    );
    _depositController = TextEditingController(
      text: offering?.demoDepositUzs?.toString() ?? '',
    );
    _kind = offering?.kind ?? BusinessOfferingKind.product;
    _pricingUnit =
        offering?.pricingUnit ?? BusinessPricingUnit.defaultFor(_kind);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileId = _profileId;
    final profileController = getIt<BusinessProfileController>();
    final draft =
        profileId == null ? null : profileController.userDraftById(profileId);

    if (profileId == null || profileId.isEmpty || draft == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(
            _isEdit
                ? l10n.businessOfferingFormEditTitle
                : l10n.businessOfferingFormCreateTitle,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.businessOfferingProfileNotEditable,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_isEdit &&
        getIt<BusinessOfferingsController>().offeringById(
              businessProfileId: profileId,
              offeringId: widget.offeringId!,
            ) ==
            null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.businessOfferingFormEditTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.businessOfferingNotFoundBody,
              textAlign: TextAlign.center,
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
              ? l10n.businessOfferingFormEditTitle
              : l10n.businessOfferingFormCreateTitle,
        ),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          phone: _FormScroll(
            maxWidth: 520,
            child: _buildForm(context, l10n, profileId),
          ),
          tablet: _FormScroll(
            maxWidth: 760,
            child: _buildForm(context, l10n, profileId),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    String profileId,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppMessageBanner(
            message: l10n.businessOfferingFormLocalNotice,
            icon: Icons.save_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.businessOfferingFieldName,
            ),
            textInputAction: TextInputAction.next,
            validator: (v) => v == null || v.trim().isEmpty
                ? l10n.businessOfferingValidationNameRequired
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<BusinessOfferingKind>(
            value: _kind,
            decoration: InputDecoration(
              labelText: l10n.businessOfferingFieldKind,
            ),
            items: [
              for (final kind in BusinessOfferingKind.values)
                DropdownMenuItem(
                  value: kind,
                  child: Text(kind.label(l10n)),
                ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _kind = value;
                _pricingUnit = BusinessPricingUnit.defaultFor(value);
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.businessOfferingFieldDescription,
            ),
            minLines: 2,
            maxLines: 4,
            validator: (v) => v == null || v.trim().isEmpty
                ? l10n.businessOfferingValidationDescriptionRequired
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<BusinessPricingUnit>(
            value: _pricingUnit,
            decoration: InputDecoration(
              labelText: l10n.businessOfferingFieldPricingUnit,
            ),
            items: [
              for (final unit in BusinessPricingUnit.values)
                DropdownMenuItem(
                  value: unit,
                  child: Text(unit.label(l10n)),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _pricingUnit = value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: l10n.businessOfferingFieldDemoPriceOptional,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validateOptionalUzs,
          ),
          if (_kind == BusinessOfferingKind.rental) ...[
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _depositController,
              decoration: InputDecoration(
                labelText: l10n.businessOfferingFieldDemoDepositOptional,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateOptionalUzs,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSaving ? null : () => _save(l10n, profileId),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.businessOfferingSaveAction),
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

  String? _validateOptionalUzs(String? raw) {
    final l10n = AppLocalizations.of(context);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final parsed = int.tryParse(raw.trim());
    if (parsed == null || parsed < 0) {
      return l10n.businessOfferingValidationUzsInvalid;
    }
    return null;
  }

  int? _parseOptionalUzs(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return int.tryParse(trimmed);
  }

  Future<void> _save(AppLocalizations l10n, String profileId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final controller = getIt<BusinessOfferingsController>();
    final price = _parseOptionalUzs(_priceController.text);
    final deposit = _kind == BusinessOfferingKind.rental
        ? _parseOptionalUzs(_depositController.text)
        : null;

    if (_isEdit) {
      final ok = controller.updateOffering(
        businessProfileId: profileId,
        offeringId: widget.offeringId!,
        kind: _kind,
        name: _nameController.text,
        description: _descriptionController.text,
        pricingUnit: _pricingUnit,
        samplePriceUzs: price,
        demoDepositUzs: deposit,
      );
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      if (ok) {
        context.pop();
      }
      return;
    }

    final newId = controller.addOffering(
      businessProfileId: profileId,
      kind: _kind,
      name: _nameController.text,
      description: _descriptionController.text,
      pricingUnit: _pricingUnit,
      samplePriceUzs: price,
      demoDepositUzs: deposit,
    );

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    if (newId != null) {
      context.pop();
    }
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
