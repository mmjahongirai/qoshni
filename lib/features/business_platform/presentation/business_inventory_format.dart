import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_availability_state.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_inventory.dart';
import 'package:qoshni/features/business_platform/domain/business_offering_kind.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_offering.dart';

String formatInventoryStatusLine(
  AppLocalizations l10n,
  BusinessProfileOffering offering,
  BusinessOfferingInventory? inventory,
) {
  if (inventory == null) {
    return l10n.businessInventoryNotConfigured;
  }

  final state = inventory.availability.label(l10n);

  return switch (offering.kind) {
    BusinessOfferingKind.service => l10n.businessInventoryServiceStatus(state),
    BusinessOfferingKind.product => l10n.businessInventoryProductStock(
        inventory.availableQuantity!,
        inventory.totalQuantity!,
        state,
      ),
    BusinessOfferingKind.rental => l10n.businessInventoryRentalUnits(
        inventory.availableQuantity!,
        inventory.totalQuantity!,
        state,
      ),
  };
}
