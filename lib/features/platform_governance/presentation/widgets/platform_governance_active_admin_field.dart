import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_governance_controller.dart';

class PlatformGovernanceActiveAdminField extends StatelessWidget {
  const PlatformGovernanceActiveAdminField({
    required this.governanceController,
    super.key,
  });

  final QoshniPlatformGovernanceController governanceController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final admins = governanceController.admins;
    return DropdownButtonFormField<String>(
      key: ValueKey(governanceController.activeAdminId),
      initialValue: governanceController.activeAdminId,
      decoration: InputDecoration(
        labelText: l10n.platformWorkflowActiveAdminLabel,
      ),
      items: admins
          .map(
            (admin) => DropdownMenuItem(
              value: admin.adminId,
              child: Text(admin.displayLabel),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          governanceController.setActiveAdminId(value);
        }
      },
    );
  }
}
