import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_status.dart';

class QoshniPlatformAdminIdentity {
  const QoshniPlatformAdminIdentity({
    required this.adminId,
    required this.syntheticReference,
    required this.displayLabel,
    required this.status,
    required this.roleIds,
    required this.assignedBusinessReferences,
    required this.assignedBranchReferences,
    required this.createdAt,
    required this.updatedAt,
  });

  final String adminId;
  final String syntheticReference;
  final String displayLabel;
  final QoshniPlatformAdminStatus status;
  final List<String> roleIds;
  final List<String> assignedBusinessReferences;
  final List<String> assignedBranchReferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;

  QoshniPlatformAdminIdentity copyWith({
    QoshniPlatformAdminStatus? status,
    List<String>? roleIds,
    List<String>? assignedBusinessReferences,
    List<String>? assignedBranchReferences,
    DateTime? updatedAt,
  }) {
    return QoshniPlatformAdminIdentity(
      adminId: adminId,
      syntheticReference: syntheticReference,
      displayLabel: displayLabel,
      status: status ?? this.status,
      roleIds: roleIds ?? List.unmodifiable(this.roleIds),
      assignedBusinessReferences: assignedBusinessReferences ??
          List.unmodifiable(this.assignedBusinessReferences),
      assignedBranchReferences: assignedBranchReferences ??
          List.unmodifiable(this.assignedBranchReferences),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
