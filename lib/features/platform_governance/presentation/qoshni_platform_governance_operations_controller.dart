import 'package:flutter/foundation.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_operations_summary.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_operations_summary_service.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_resource_scope.dart';

class QoshniPlatformGovernanceOperationsController extends ChangeNotifier {
  QoshniPlatformGovernanceOperationsController({
    required QoshniPlatformGovernanceOperationsSummaryService summaryService,
    required QoshniPlatformGovernanceAuthorizer authorizer,
  })  : _summaryService = summaryService,
        _authorizer = authorizer;

  final QoshniPlatformGovernanceOperationsSummaryService _summaryService;
  final QoshniPlatformGovernanceAuthorizer _authorizer;

  QoshniPlatformGovernanceOperationsSummary? summary;
  String? lastAccessDeniedReasonKey;

  void refresh(String adminId) {
    final decision = _authorizer.authorize(
      adminId: adminId,
      permission: QoshniPlatformPermission.viewPlatformAdminDashboard,
      resourceScope: const QoshniPlatformResourceScope.platform(),
      actionLabel: 'operations_dashboard',
    );
    if (!decision.isAllowed) {
      summary = null;
      lastAccessDeniedReasonKey = decision.reason.name;
      notifyListeners();
      return;
    }
    lastAccessDeniedReasonKey = null;
    summary = _summaryService.build();
    notifyListeners();
  }
}
