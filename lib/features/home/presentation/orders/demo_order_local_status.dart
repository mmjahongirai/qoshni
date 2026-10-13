import 'package:qoshni/core/localization/generated/app_localizations.dart';

/// Local-only demo order status (no backend sync).
enum DemoOrderLocalStatus {
  /// Snapshot captured on device; never sent to a business.
  preparedNotSent,
}

extension DemoOrderLocalStatusLabels on DemoOrderLocalStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case DemoOrderLocalStatus.preparedNotSent:
        return l10n.demoOrderStatusPreparedNotSent;
    }
  }
}
