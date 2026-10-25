import 'package:flutter/foundation.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_identity.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_admin_role.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_decision.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_policy.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_authorization_request.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission_definition.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_governance_repository.dart';

class QoshniPlatformGovernanceController extends ChangeNotifier {
  QoshniPlatformGovernanceController(this._repository);

  final QoshniPlatformGovernanceRepository _repository;

  String? selectedAdminId;
  String? selectedRoleId;
  QoshniPlatformPermission previewPermission =
      QoshniPlatformPermission.viewPlatformAdminDashboard;
  QoshniPlatformResourceScopeKind previewScopeKind =
      QoshniPlatformResourceScopeKind.platform;
  String previewBusinessReference = '';
  String previewBranchReference = '';
  String previewActionLabel = 'Preview authorization check';

  /// Demo session: which synthetic platform admin performs workflow actions.
  String activeAdminId = 'admin-demo-verifier';

  List<QoshniPlatformAdminIdentity> get admins => _repository.listAdmins();

  List<QoshniPlatformAdminRole> get roles => _repository.listRoles();

  List<QoshniPlatformPermissionDefinition> get permissionCatalog =>
      _repository.permissionCatalog();

  Map<String, QoshniPlatformAdminRole> get rolesById {
    return {for (final role in roles) role.roleId: role};
  }

  QoshniPlatformAdminIdentity? get selectedAdmin {
    final id = selectedAdminId;
    if (id == null) {
      return null;
    }
    return _repository.findAdmin(id);
  }

  QoshniPlatformAdminRole? get selectedRole {
    final id = selectedRoleId;
    if (id == null) {
      return null;
    }
    return _repository.findRole(id);
  }

  void selectAdmin(String? adminId) {
    selectedAdminId = adminId;
    notifyListeners();
  }

  void selectRole(String? roleId) {
    selectedRoleId = roleId;
    notifyListeners();
  }

  void setPreviewPermission(QoshniPlatformPermission permission) {
    previewPermission = permission;
    notifyListeners();
  }

  void setPreviewScopeKind(QoshniPlatformResourceScopeKind kind) {
    previewScopeKind = kind;
    notifyListeners();
  }

  void setPreviewBusinessReference(String value) {
    previewBusinessReference = value;
    notifyListeners();
  }

  void setPreviewBranchReference(String value) {
    previewBranchReference = value;
    notifyListeners();
  }

  void setPreviewActionLabel(String value) {
    previewActionLabel = value;
    notifyListeners();
  }

  void setActiveAdminId(String adminId) {
    activeAdminId = adminId;
    notifyListeners();
  }

  QoshniPlatformResourceScope buildPreviewScope() {
    return switch (previewScopeKind) {
      QoshniPlatformResourceScopeKind.platform =>
        const QoshniPlatformResourceScope.platform(),
      QoshniPlatformResourceScopeKind.business => QoshniPlatformResourceScope(
          kind: QoshniPlatformResourceScopeKind.business,
          businessReference: previewBusinessReference.trim(),
        ),
      QoshniPlatformResourceScopeKind.branch => QoshniPlatformResourceScope(
          kind: QoshniPlatformResourceScopeKind.branch,
          businessReference: previewBusinessReference.trim(),
          branchReference: previewBranchReference.trim(),
        ),
    };
  }

  QoshniPlatformAuthorizationDecision? previewAuthorizationForSelectedAdmin() {
    final admin = selectedAdmin;
    if (admin == null) {
      return null;
    }
    return QoshniPlatformAuthorizationPolicy.evaluate(
      QoshniPlatformAuthorizationRequest(
        admin: admin,
        rolesById: rolesById,
        permission: previewPermission,
        resourceScope: buildPreviewScope(),
        actionLabel: previewActionLabel,
      ),
    );
  }
}
