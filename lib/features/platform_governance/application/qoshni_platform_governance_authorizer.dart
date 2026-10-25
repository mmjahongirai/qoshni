import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_decision.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_policy.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_request.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';

/// Demo authorization gate for platform-governance write operations.
class QoshniPlatformGovernanceAuthorizer {
  QoshniPlatformGovernanceAuthorizer(this._governanceRepository);

  final QoshniPlatformGovernanceRepository _governanceRepository;

  QoshniPlatformAuthorizationDecision authorize({
    required String adminId,
    required QoshniPlatformPermission permission,
    required QoshniPlatformResourceScope resourceScope,
    required String actionLabel,
  }) {
    final admin = _governanceRepository.findAdmin(adminId.trim());
    if (admin == null) {
      return QoshniPlatformAuthorizationDecision(
        isAllowed: false,
        reason: QoshniPlatformAuthorizationReason.deniedAdminNotFound,
        permission: permission,
      );
    }
    final roles = {
      for (final role in _governanceRepository.listRoles()) role.roleId: role,
    };
    return QoshniPlatformAuthorizationPolicy.evaluate(
      QoshniPlatformAuthorizationRequest(
        admin: admin,
        rolesById: roles,
        permission: permission,
        resourceScope: resourceScope,
        actionLabel: actionLabel,
      ),
    );
  }
}
