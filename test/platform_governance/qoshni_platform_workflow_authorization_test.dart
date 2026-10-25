import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_authorizer.dart';
import 'package:qoshni/features/platform_governance/application/qoshni_platform_governance_write_result.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_business_verification_queue_repository.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_governance_repository.dart';
import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_business_verification_submission_status.dart';
import 'package:qoshni/features/platform_governance/presentation/qoshni_platform_business_verification_queue_controller.dart';

void main() {
  test('verification write denied for viewer admin leaves submission unchanged',
      () {
    final repo = InMemoryQoshniPlatformBusinessVerificationQueueRepository();
    final governance = InMemoryQoshniPlatformGovernanceRepository();
    final controller = QoshniPlatformBusinessVerificationQueueController(
      repository: repo,
      governanceRepository: governance,
      authorizer: QoshniPlatformGovernanceAuthorizer(governance),
    );
    controller.selectSubmission('bver-demo-001');
    final before = repo.find('bver-demo-001')!.status;
    final result = controller.transitionSelected(
      adminId: 'admin-demo-viewer',
      toStatus: QoshniPlatformBusinessVerificationSubmissionStatus.underReview,
      reasonCode: 'attempt',
      atUtc: kDemoPlatformGovernanceEpoch,
    );
    expect(result.outcome,
        QoshniPlatformGovernanceWriteOutcome.authorizationDenied);
    expect(repo.find('bver-demo-001')!.status, before);
  });

  test('verifier can begin review on assigned business submission', () {
    final repo = InMemoryQoshniPlatformBusinessVerificationQueueRepository();
    final governance = InMemoryQoshniPlatformGovernanceRepository();
    final controller = QoshniPlatformBusinessVerificationQueueController(
      repository: repo,
      governanceRepository: governance,
      authorizer: QoshniPlatformGovernanceAuthorizer(governance),
    );
    controller.selectSubmission('bver-demo-001');
    final result = controller.transitionSelected(
      adminId: 'admin-demo-verifier',
      toStatus: QoshniPlatformBusinessVerificationSubmissionStatus.underReview,
      reasonCode: 'queue_triage',
      atUtc: kDemoPlatformGovernanceEpoch,
    );
    expect(result.isSuccess, isTrue);
    expect(
      repo.find('bver-demo-001')!.status,
      QoshniPlatformBusinessVerificationSubmissionStatus.underReview,
    );
  });

  test('verifier denied on cross-business submission', () {
    final repo = InMemoryQoshniPlatformBusinessVerificationQueueRepository();
    final governance = InMemoryQoshniPlatformGovernanceRepository();
    final controller = QoshniPlatformBusinessVerificationQueueController(
      repository: repo,
      governanceRepository: governance,
      authorizer: QoshniPlatformGovernanceAuthorizer(governance),
    );
    controller.selectSubmission('bver-demo-002');
    final before = repo.find('bver-demo-002')!.status;
    final result = controller.transitionSelected(
      adminId: 'admin-demo-verifier',
      toStatus: QoshniPlatformBusinessVerificationSubmissionStatus.approved,
      reasonCode: 'demo_approve',
      atUtc: kDemoPlatformGovernanceEpoch,
    );
    expect(result.outcome,
        QoshniPlatformGovernanceWriteOutcome.authorizationDenied);
    expect(repo.find('bver-demo-002')!.status, before);
  });
}
