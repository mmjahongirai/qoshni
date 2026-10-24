import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_role.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_policy.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_reason.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_request.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';

void main() {
  late Map<String, QoshniPlatformAdminRole> rolesById;

  setUp(() {
    final roles = buildQoshniPlatformAdminRoleDemoSeed();
    rolesById = {for (final role in roles) role.roleId: role};
  });

  QoshniPlatformAuthorizationRequest requestForAdminId(
    String adminId, {
    required QoshniPlatformPermission permission,
    required QoshniPlatformResourceScope scope,
  }) {
    final admin = buildQoshniPlatformAdminIdentityDemoSeed()
        .firstWhere((a) => a.adminId == adminId);
    return QoshniPlatformAuthorizationRequest(
      admin: admin,
      rolesById: rolesById,
      permission: permission,
      resourceScope: scope,
      actionLabel: 'demo-action',
    );
  }

  test('platform viewer may view dashboard at platform scope', () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-viewer',
        permission: QoshniPlatformPermission.viewPlatformAdminDashboard,
        scope: const QoshniPlatformResourceScope.platform(),
      ),
    );
    expect(decision.isAllowed, isTrue);
    expect(decision.reason,
        QoshniPlatformAuthorizationReason.allowedExplicitGrant);
  });

  test('viewer is denied configuration management by default', () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-viewer',
        permission:
            QoshniPlatformPermission.manageLowRiskPlatformConfiguration,
        scope: const QoshniPlatformResourceScope.platform(),
      ),
    );
    expect(decision.isAllowed, isFalse);
    expect(decision.reason,
        QoshniPlatformAuthorizationReason.deniedPermissionNotGranted);
  });

  test('suspended admin is denied', () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-suspended',
        permission: QoshniPlatformPermission.viewPlatformAdminDashboard,
        scope: const QoshniPlatformResourceScope.platform(),
      ),
    );
    expect(decision.isAllowed, isFalse);
    expect(decision.reason,
        QoshniPlatformAuthorizationReason.deniedAdminSuspended);
  });

  test('admin with only disabled role is denied', () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-disabled-role',
        permission: QoshniPlatformPermission.viewAuditRecords,
        scope: const QoshniPlatformResourceScope.platform(),
      ),
    );
    expect(decision.isAllowed, isFalse);
    expect(decision.reason,
        QoshniPlatformAuthorizationReason.deniedNoEnabledRoles);
  });

  test('platform-wide permission rejects business scope without platform grant path',
      () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-viewer',
        permission: QoshniPlatformPermission.viewPlatformAdminDashboard,
        scope: QoshniPlatformResourceScope(
          kind: QoshniPlatformResourceScopeKind.business,
          businessReference: kDemoPlatformGovernanceBusinessA,
        ),
      ),
    );
    expect(decision.isAllowed, isFalse);
    expect(decision.reason,
        QoshniPlatformAuthorizationReason.deniedScopePlatformWideRequired);
  });

  test('verifier allows review within assigned business scope', () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-verifier',
        permission:
            QoshniPlatformPermission.reviewBusinessVerificationSubmissions,
        scope: QoshniPlatformResourceScope(
          kind: QoshniPlatformResourceScopeKind.business,
          businessReference: kDemoPlatformGovernanceBusinessA,
        ),
      ),
    );
    expect(decision.isAllowed, isTrue);
  });

  test('verifier denied for cross-business scope', () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-verifier',
        permission:
            QoshniPlatformPermission.reviewBusinessVerificationSubmissions,
        scope: QoshniPlatformResourceScope(
          kind: QoshniPlatformResourceScopeKind.business,
          businessReference: kDemoPlatformGovernanceBusinessB,
        ),
      ),
    );
    expect(decision.isAllowed, isFalse);
    expect(decision.reason,
        QoshniPlatformAuthorizationReason.deniedCrossBusinessAccess);
  });

  test('support agent may respond on assigned branch scope', () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-support',
        permission: QoshniPlatformPermission.respondToSupportCases,
        scope: QoshniPlatformResourceScope(
          kind: QoshniPlatformResourceScopeKind.branch,
          businessReference: kDemoPlatformGovernanceBusinessA,
          branchReference: kDemoPlatformGovernanceBranchA1,
        ),
      ),
    );
    expect(decision.isAllowed, isTrue);
  });

  test('support agent denied on unassigned branch', () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-support',
        permission: QoshniPlatformPermission.respondToSupportCases,
        scope: QoshniPlatformResourceScope(
          kind: QoshniPlatformResourceScopeKind.branch,
          businessReference: kDemoPlatformGovernanceBusinessA,
          branchReference: kDemoPlatformGovernanceBranchB1,
        ),
      ),
    );
    expect(decision.isAllowed, isFalse);
    expect(decision.reason,
        QoshniPlatformAuthorizationReason.deniedCrossBranchAccess);
  });

  test('support permissions are separate from configuration management', () {
    final supportDecision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-support',
        permission: QoshniPlatformPermission.viewSupportCases,
        scope: QoshniPlatformResourceScope(
          kind: QoshniPlatformResourceScopeKind.business,
          businessReference: kDemoPlatformGovernanceBusinessA,
        ),
      ),
    );
    final configDecision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-support',
        permission: QoshniPlatformPermission.manageLowRiskPlatformConfiguration,
        scope: const QoshniPlatformResourceScope.platform(),
      ),
    );
    expect(supportDecision.isAllowed, isTrue);
    expect(configDecision.isAllowed, isFalse);
  });

  test('operations admin is not implicit super-admin for moderation', () {
    final decision = QoshniPlatformAuthorizationPolicy.evaluate(
      requestForAdminId(
        'admin-demo-operations',
        permission: QoshniPlatformPermission.performPermittedModerationActions,
        scope: const QoshniPlatformResourceScope.platform(),
      ),
    );
    expect(decision.isAllowed, isFalse);
  });
}
