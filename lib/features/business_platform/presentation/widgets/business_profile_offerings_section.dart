import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/core/widgets/app_price_text.dart';
import 'package:qoshni/core/widgets/app_surface_card.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';
import 'package:qoshni/features/business_platform/presentation/business_offering_format.dart';
import 'package:qoshni/features/business_platform/presentation/business_offerings_controller.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/routing/route_paths.dart';

class BusinessProfileOfferingsSection extends StatelessWidget {
  const BusinessProfileOfferingsSection({
    required this.l10n,
    required this.profile,
    super.key,
  });

  final AppLocalizations l10n;
  final BusinessProfileDraft profile;

  @override
  Widget build(BuildContext context) {
    final offeringsController = getIt<BusinessOfferingsController>();
    final isEditable = profile.kind == BusinessProfileKind.userDraft;

    return ListenableBuilder(
      listenable: offeringsController,
      builder: (context, _) {
        final userOfferings =
            offeringsController.offeringsForProfile(profile.id);
        final sampleOfferings = isEditable
            ? const <BusinessProfileOffering>[]
            : offeringsController.sampleOfferingsForProfile(l10n, profile.id);
        final offerings = isEditable ? userOfferings : sampleOfferings;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.businessOfferingsSectionTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (isEditable)
                  TextButton.icon(
                    onPressed: () => context.pushNamed(
                      RouteNames.businessOfferingCreate,
                      pathParameters: {'profileId': profile.id},
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(l10n.businessOfferingAddAction),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isEditable
                  ? l10n.businessOfferingsOwnerNotice
                  : l10n.businessOfferingsSampleNotice,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 12),
            if (offerings.isEmpty)
              _OfferingsEmptyCard(l10n: l10n, isEditable: isEditable)
            else
              for (var i = 0; i < offerings.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _OfferingCard(
                  l10n: l10n,
                  profileId: profile.id,
                  offering: offerings[i],
                  readOnly: !isEditable,
                ),
              ],
          ],
        );
      },
    );
  }
}

class _OfferingsEmptyCard extends StatelessWidget {
  const _OfferingsEmptyCard({
    required this.l10n,
    required this.isEditable,
  });

  final AppLocalizations l10n;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        isEditable
            ? l10n.businessOfferingsEmptyOwner
            : l10n.businessOfferingsEmptySample,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.35,
        ),
      ),
    );
  }
}

class _OfferingCard extends StatelessWidget {
  const _OfferingCard({
    required this.l10n,
    required this.profileId,
    required this.offering,
    required this.readOnly,
  });

  final AppLocalizations l10n;
  final String profileId;
  final BusinessProfileOffering offering;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final depositLine = formatBusinessOfferingDepositLine(l10n, offering);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offering.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      offering.kind.label(l10n),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!readOnly) ...[
                IconButton(
                  tooltip: l10n.businessOfferingEditAction,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => context.pushNamed(
                    RouteNames.businessOfferingEdit,
                    pathParameters: {
                      'profileId': profileId,
                      'offeringId': offering.id,
                    },
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
                IconButton(
                  tooltip: l10n.businessOfferingDeleteAction,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _confirmDelete(context),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            offering.description,
            style: textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppPriceText(
            label: formatBusinessOfferingPriceLine(l10n, offering),
            emphasis: PriceEmphasis.primary,
          ),
          if (depositLine != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              depositLine,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.businessOfferingDeleteConfirmTitle),
          content: Text(l10n.businessOfferingDeleteConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.businessProfileCancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.businessOfferingDeleteConfirmYes),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    getIt<BusinessOfferingsController>().removeOffering(
      businessProfileId: profileId,
      offeringId: offering.id,
    );
  }
}
