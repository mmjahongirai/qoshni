import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission_scope_requirement.dart';

class QoshniPlatformPermissionDefinition {
  const QoshniPlatformPermissionDefinition({
    required this.permission,
    required this.catalogKey,
    required this.scopeRequirement,
  });

  final QoshniPlatformPermission permission;
  final String catalogKey;
  final QoshniPlatformPermissionScopeRequirement scopeRequirement;

  String get permissionId => permission.permissionId;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;
}

List<QoshniPlatformPermissionDefinition> buildQoshniPlatformPermissionCatalog() {
  return QoshniPlatformPermission.values
      .map(
        (permission) => QoshniPlatformPermissionDefinition(
          permission: permission,
          catalogKey: permission.name,
          scopeRequirement: qoshniPlatformPermissionScopeRequirement(permission),
        ),
      )
      .toList(growable: false);
}
