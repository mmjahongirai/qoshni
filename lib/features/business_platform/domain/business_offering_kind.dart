import 'package:qoshni/core/localization/generated/app_localizations.dart';

enum BusinessOfferingKind {
  product,
  service,
  rental,
}

extension BusinessOfferingKindLabels on BusinessOfferingKind {
  String label(AppLocalizations l10n) {
    return switch (this) {
      BusinessOfferingKind.product => l10n.businessOfferingKindProduct,
      BusinessOfferingKind.service => l10n.businessOfferingKindService,
      BusinessOfferingKind.rental => l10n.businessOfferingKindRental,
    };
  }
}
