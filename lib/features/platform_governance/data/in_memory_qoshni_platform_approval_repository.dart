import 'package:qoshni/features/platform_governance/data/qoshni_platform_approval_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_mutation_result.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_proposal_type.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_approval_request_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_permission.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_approval_repository.dart';

class InMemoryQoshniPlatformApprovalRepository
    implements QoshniPlatformApprovalRepository {
  InMemoryQoshniPlatformApprovalRepository({
    List<QoshniPlatformApprovalRequest>? seed,
  }) : _requests = List.of(seed ?? buildQoshniPlatformApprovalDemoSeed());

  final List<QoshniPlatformApprovalRequest> _requests;

  bool failNextMutation = false;

  @override
  List<QoshniPlatformApprovalRequest> list({
    QoshniPlatformApprovalRequestStatus? status,
  }) {
    return _requests
        .where((r) => status == null || r.status == status)
        .toList(growable: false);
  }

  @override
  QoshniPlatformApprovalRequest? find(String requestId) {
    for (final request in _requests) {
      if (request.requestId == requestId) {
        return request;
      }
    }
    return null;
  }

  @override
  QoshniPlatformApprovalMutationResult createRequest({
    required String requestId,
    required QoshniPlatformApprovalProposalType proposalType,
    required String requesterAdminReference,
    required String targetReference,
    required String reasonCode,
    required DateTime createdAtUtc,
    String? businessReference,
  }) {
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformApprovalMutationResult.failure;
    }
    if (requestId.trim().isEmpty ||
        requesterAdminReference.trim().isEmpty ||
        targetReference.trim().isEmpty ||
        reasonCode.trim().isEmpty) {
      return QoshniPlatformApprovalMutationResult.invalidInput;
    }
    if (find(requestId) != null) {
      return QoshniPlatformApprovalMutationResult.invalidInput;
    }
    _requests.add(
      QoshniPlatformApprovalRequest(
        requestId: requestId,
        proposalType: proposalType,
        status: QoshniPlatformApprovalRequestStatus.pending,
        requesterAdminReference: requesterAdminReference,
        targetReference: targetReference,
        requiredPermission:
            QoshniPlatformPermission.decideHighRiskAdministrativeProposal,
        reasonCode: reasonCode.trim(),
        createdAt: createdAtUtc.toUtc(),
        updatedAt: createdAtUtc.toUtc(),
        businessReference: businessReference,
      ),
    );
    return QoshniPlatformApprovalMutationResult.success;
  }

  @override
  QoshniPlatformApprovalMutationResult decide({
    required String requestId,
    required QoshniPlatformApprovalRequestStatus toStatus,
    required String deciderAdminReference,
    required String decisionReasonCode,
    required DateTime decidedAtUtc,
  }) {
    if (failNextMutation) {
      failNextMutation = false;
      return QoshniPlatformApprovalMutationResult.failure;
    }
    final index = _requests.indexWhere((r) => r.requestId == requestId);
    if (index < 0) {
      return QoshniPlatformApprovalMutationResult.notFound;
    }
    final existing = _requests[index];
    if (existing.status != QoshniPlatformApprovalRequestStatus.pending) {
      return QoshniPlatformApprovalMutationResult.invalidTransition;
    }
    if (deciderAdminReference == existing.requesterAdminReference) {
      return QoshniPlatformApprovalMutationResult.selfApprovalDenied;
    }
    if (toStatus != QoshniPlatformApprovalRequestStatus.approved &&
        toStatus != QoshniPlatformApprovalRequestStatus.rejected) {
      return QoshniPlatformApprovalMutationResult.invalidInput;
    }
    if (decisionReasonCode.trim().isEmpty) {
      return QoshniPlatformApprovalMutationResult.invalidInput;
    }
    _requests[index] = QoshniPlatformApprovalRequest(
      requestId: existing.requestId,
      proposalType: existing.proposalType,
      status: toStatus,
      requesterAdminReference: existing.requesterAdminReference,
      targetReference: existing.targetReference,
      requiredPermission: existing.requiredPermission,
      reasonCode: existing.reasonCode,
      createdAt: existing.createdAt,
      updatedAt: decidedAtUtc.toUtc(),
      deciderAdminReference: deciderAdminReference,
      decisionReasonCode: decisionReasonCode.trim(),
      decidedAt: decidedAtUtc.toUtc(),
      businessReference: existing.businessReference,
      isSeedRecord: existing.isSeedRecord,
    );
    return QoshniPlatformApprovalMutationResult.success;
  }

  @override
  QoshniPlatformApprovalMutationResult cancel({
    required String requestId,
    required String requesterAdminReference,
    required String reasonCode,
    required DateTime cancelledAtUtc,
  }) {
    final index = _requests.indexWhere((r) => r.requestId == requestId);
    if (index < 0) {
      return QoshniPlatformApprovalMutationResult.notFound;
    }
    final existing = _requests[index];
    if (existing.requesterAdminReference != requesterAdminReference) {
      return QoshniPlatformApprovalMutationResult.invalidInput;
    }
    if (existing.status != QoshniPlatformApprovalRequestStatus.pending) {
      return QoshniPlatformApprovalMutationResult.invalidTransition;
    }
    if (reasonCode.trim().isEmpty) {
      return QoshniPlatformApprovalMutationResult.invalidInput;
    }
    _requests[index] = QoshniPlatformApprovalRequest(
      requestId: existing.requestId,
      proposalType: existing.proposalType,
      status: QoshniPlatformApprovalRequestStatus.cancelled,
      requesterAdminReference: existing.requesterAdminReference,
      targetReference: existing.targetReference,
      requiredPermission: existing.requiredPermission,
      reasonCode: existing.reasonCode,
      createdAt: existing.createdAt,
      updatedAt: cancelledAtUtc.toUtc(),
      businessReference: existing.businessReference,
      isSeedRecord: existing.isSeedRecord,
    );
    return QoshniPlatformApprovalMutationResult.success;
  }
}
