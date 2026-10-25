import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_role_status.dart';

class QoshniPlatformAdminRole {
  const QoshniPlatformAdminRole({
    required this.roleId,
    required this.roleKey,
    required this.displayNameKey,
    required this.purposeKey,
    required this.permissionIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String roleId;
  final String roleKey;
  final String displayNameKey;
  final String purposeKey;
  final List<String> permissionIds;
  final QoshniPlatformRoleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;

  List<QoshniPlatformPermission> get permissions {
    final resolved = <QoshniPlatformPermission>[];
    for (final id in permissionIds) {
      for (final value in QoshniPlatformPermission.values) {
        if (value.permissionId == id) {
          resolved.add(value);
          break;
        }
      }
    }
    return List.unmodifiable(resolved);
  }

  QoshniPlatformAdminRole copyWith({
    QoshniPlatformRoleStatus? status,
    List<String>? permissionIds,
    DateTime? updatedAt,
  }) {
    return QoshniPlatformAdminRole(
      roleId: roleId,
      roleKey: roleKey,
      displayNameKey: displayNameKey,
      purposeKey: purposeKey,
      permissionIds: permissionIds ?? List.unmodifiable(this.permissionIds),
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
