import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_identity.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_role.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';

class QoshniPlatformAuthorizationRequest {
  const QoshniPlatformAuthorizationRequest({
    required this.admin,
    required this.rolesById,
    required this.permission,
    required this.resourceScope,
    required this.actionLabel,
  });

  final QoshniPlatformAdminIdentity admin;
  final Map<String, QoshniPlatformAdminRole> rolesById;
  final QoshniPlatformPermission permission;
  final QoshniPlatformResourceScope resourceScope;
  final String actionLabel;
}
