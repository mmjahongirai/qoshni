import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_identity.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_role.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_mutation_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission_definition.dart';

abstract class QoshniPlatformGovernanceRepository {
  List<QoshniPlatformPermissionDefinition> permissionCatalog();

  List<QoshniPlatformAdminIdentity> listAdmins();

  QoshniPlatformAdminIdentity? findAdmin(String adminId);

  List<QoshniPlatformAdminRole> listRoles();

  QoshniPlatformAdminRole? findRole(String roleId);

  QoshniPlatformGovernanceMutationResult assignRoleToAdmin({
    required String adminId,
    required String roleId,
    required DateTime updatedAtUtc,
  });

  QoshniPlatformGovernanceMutationResult setAdminStatus({
    required String adminId,
    required QoshniPlatformAdminStatus status,
    required DateTime updatedAtUtc,
  });
}
