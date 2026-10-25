import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/platform_governance/data/in_memory_qoshni_platform_moderation_queue_repository.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_moderation_case_status.dart';
import 'package:qoshni/features/platform_governance/domain/qoshni_platform_governance_history_entry.dart';
import 'package:qoshni/features/platform_governance/domain/repositories/qoshni_platform_moderation_queue_repository.dart';
import 'package:qoshni/features/platform_governance/data/qoshni_platform_governance_demo_seed.dart';

void main() {
  test('moderation queue data layer does not import business complaint repositories',
      () {
    final dir = Directory('lib/features/platform_governance/data');
    final violations = <String>[];
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.path.contains('moderation')) {
        final content = entity.readAsStringSync();
        if (content.contains('business_complaint_repository') ||
            content.contains('InMemoryBusinessComplaintRepository')) {
          violations.add(entity.path);
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('moderation status transition does not require external Phase 13 mutation',
      () {
    final repo = InMemoryQoshniPlatformModerationQueueRepository();
    final item = repo.find('mod-demo-001')!;
    final result = repo.transitionStatus(
      caseId: item.caseId,
      toStatus: QoshniPlatformModerationCaseStatus.underReview,
      historyEntry: QoshniPlatformGovernanceHistoryEntry(
        recordedAt: kDemoPlatformGovernanceEpoch,
        actorAdminReference: 'demo-platform-admin-moderator',
        operation: 'status_transition',
        fromStatus: item.status.wireValue,
        toStatus: QoshniPlatformModerationCaseStatus.underReview.wireValue,
        reasonCode: 'triage',
        note: 'demo',
      ),
      updatedAtUtc: kDemoPlatformGovernanceEpoch,
    );
    expect(result, QoshniPlatformModerationMutationResult.success);
    expect(
      repo.find('mod-demo-001')!.status,
      QoshniPlatformModerationCaseStatus.underReview,
    );
  });
}
