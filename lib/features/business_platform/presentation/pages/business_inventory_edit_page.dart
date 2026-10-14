import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_message_banner.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_availability_state.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';
import 'package:qoshni/features/business_platform/presentation/business_inventory_controller.dart';
import 'package:qoshni/features/business_platform/presentation/business_offerings_controller.dart';

class BusinessInventoryEditPage extends StatefulWidget {
  const BusinessInventoryEditPage({
    required this.profileId,
    required this.offeringId,
    super.key,
  });

  final String? profileId;
  final String? offeringId;

  @override
  State<BusinessInventoryEditPage> createState() =>
      _BusinessInventoryEditPageState();
}

class _BusinessInventoryEditPageState extends State<BusinessInventoryEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _totalController;
  late final TextEditingController _availableController;
  late BusinessOfferingAvailabilityState _availability;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profileId = widget.profileId?.trim();
    final offeringId = widget.offeringId?.trim();
    final inventory = profileId != null && offeringId != null
        ? getIt<BusinessInventoryController>().inventoryFor(
            businessProfileId: profileId,
            offeringId: offeringId,
          )
        : null;

    _availability =
        inventory?.availability ?? BusinessOfferingAvailabilityState.active;
    _totalController = TextEditingController(
      text: inventory?.totalQuantity?.toString() ?? '',
    );
    _availableController = TextEditingController(
      text: inventory?.availableQuantity?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _totalController.dispose();
    _availableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileId = widget.profileId?.trim();
    final offeringId = widget.offeringId?.trim();
    final offering = profileId != null && offeringId != null
        ? getIt<BusinessOfferingsController>().offeringById(
            businessProfileId: profileId,
            offeringId: offeringId,
          )
        : null;

    if (offering == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.businessInventoryEditTitle),
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

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final needsQuantities = offering.kind != BusinessOfferingKind.service;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.businessInventoryEditTitle),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          phone: _FormScroll(
            maxWidth: 520,
            child: _buildForm(
              context,
              l10n,
              offering,
              profileId!,
              offeringId!,
              needsQuantities,
              colorScheme,
              textTheme,
            ),
          ),
          tablet: _FormScroll(
            maxWidth: 760,
            child: _buildForm(
              context,
              l10n,
              offering,
              profileId!,
              offeringId!,
              needsQuantities,
              colorScheme,
              textTheme,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    BusinessProfileOffering offering,
    String profileId,
    String offeringId,
    bool needsQuantities,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            offering.name,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            offering.kind.label(l10n),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppMessageBanner(
            message: offering.kind == BusinessOfferingKind.rental
                ? l10n.businessInventoryRentalManualNotice
                : l10n.businessInventoryLocalNotice,
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.businessInventoryAvailabilityToggle),
            subtitle: Text(_availability.label(l10n)),
            value:
                _availability == BusinessOfferingAvailabilityState.active,
            onChanged: (active) {
              setState(() {
                _availability = active
                    ? BusinessOfferingAvailabilityState.active
                    : BusinessOfferingAvailabilityState.paused;
              });
            },
          ),
          if (needsQuantities) ...[
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _totalController,
              decoration: InputDecoration(
                labelText: offering.kind == BusinessOfferingKind.rental
                    ? l10n.businessInventoryFieldTotalUnits
                    : l10n.businessInventoryFieldStockTotal,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => _validateRequiredNonNegative(l10n, v),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _availableController,
              decoration: InputDecoration(
                labelText: offering.kind == BusinessOfferingKind.rental
                    ? l10n.businessInventoryFieldAvailableUnits
                    : l10n.businessInventoryFieldStockAvailable,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final base = _validateRequiredNonNegative(l10n, v);
                if (base != null) {
                  return base;
                }
                final total = int.tryParse(_totalController.text.trim());
                final available = int.tryParse(v!.trim());
                if (total != null &&
                    available != null &&
                    available > total) {
                  return l10n.businessInventoryValidationAvailableExceedsTotal;
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _isSaving
                ? null
                : () => _save(
                      l10n,
                      profileId,
                      offeringId,
                      offering.kind,
                    ),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.businessInventorySaveAction),
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

  String? _validateRequiredNonNegative(AppLocalizations l10n, String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return l10n.businessInventoryValidationQuantityRequired;
    }
    final parsed = int.tryParse(raw.trim());
    if (parsed == null || parsed < 0) {
      return l10n.businessInventoryValidationQuantityInvalid;
    }
    return null;
  }

  Future<void> _save(
    AppLocalizations l10n,
    String profileId,
    String offeringId,
    BusinessOfferingKind kind,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final controller = getIt<BusinessInventoryController>();

    int? total;
    int? available;
    if (kind != BusinessOfferingKind.service) {
      total = int.parse(_totalController.text.trim());
      available = int.parse(_availableController.text.trim());
    }

    final result = controller.saveInventory(
      businessProfileId: profileId,
      offeringId: offeringId,
      availability: _availability,
      totalQuantity: total,
      availableQuantity: available,
    );

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    if (result == BusinessInventorySaveResult.success) {
      context.pop();
      return;
    }

    final message = switch (result) {
      BusinessInventorySaveResult.invalidQuantities =>
        l10n.businessInventoryValidationAvailableExceedsTotal,
      BusinessInventorySaveResult.offeringNotFound =>
        l10n.businessOfferingNotFoundBody,
      BusinessInventorySaveResult.profileNotEditable =>
        l10n.businessInventoryProfileNotEditable,
      BusinessInventorySaveResult.success => '',
    };

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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
