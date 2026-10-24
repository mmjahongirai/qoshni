import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_mutation_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_proposal_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request_status.dart';

abstract class QoshniPlatformApprovalRepository {
  List<QoshniPlatformApprovalRequest> list({
    QoshniPlatformApprovalRequestStatus? status,
  });

  QoshniPlatformApprovalRequest? find(String requestId);

  QoshniPlatformApprovalMutationResult createRequest({
    required String requestId,
    required QoshniPlatformApprovalProposalType proposalType,
    required String requesterAdminReference,
    required String targetReference,
    required String reasonCode,
    required DateTime createdAtUtc,
    String? businessReference,
  });

  QoshniPlatformApprovalMutationResult decide({
    required String requestId,
    required QoshniPlatformApprovalRequestStatus toStatus,
    required String deciderAdminReference,
    required String decisionReasonCode,
    required DateTime decidedAtUtc,
  });

  QoshniPlatformApprovalMutationResult cancel({
    required String requestId,
    required String requesterAdminReference,
    required String reasonCode,
    required DateTime cancelledAtUtc,
  });
}
