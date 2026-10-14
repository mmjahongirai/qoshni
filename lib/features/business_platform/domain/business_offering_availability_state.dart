import 'package:qoshni/core/localization/generated/app_localizations.dart';

enum BusinessOfferingAvailabilityState {
  active,
  paused,
}

extension BusinessOfferingAvailabilityStateLabels
    on BusinessOfferingAvailabilityState {
  String label(AppLocalizations l10n) {
    return switch (this) {
      BusinessOfferingAvailabilityState.active =>
        l10n.businessInventoryStateActive,
      BusinessOfferingAvailabilityState.paused =>
        l10n.businessInventoryStatePaused,
    };
  }
}
