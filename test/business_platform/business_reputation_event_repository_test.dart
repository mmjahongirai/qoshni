import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/data/in_memory_business_reputation_event_repository.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';
import 'package:qoshni/features/business_platform/domain/business_review_provenance.dart';
import 'package:qoshni/features/business_platform/domain/business_review_target_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_reputation_event_repository.dart';

void main() {
  late InMemoryBusinessReputationEventRepository repo;

  setUp(() {
    repo = InMemoryBusinessReputationEventRepository(
      InMemoryBusinessOwnerProfileRepository(),
    );
  });

  BusinessReputationEventRecordInput input({
    required String correlation,
    String scope = '',
  }) {
    final businessScopeId =
        scope.isEmpty ? repo.businessScopeId : scope;
    return BusinessReputationEventRecordInput(
      businessScopeId: businessScopeId,
      targetType: BusinessReviewTargetType.product,
      targetId: 'demo-target',
      eventType: BusinessReputationEventType.complaintCreated,
      sourceDomain: BusinessReputationEventSourceDomain.complaint,
      sourceRecordId: 'demo-complaint-x',
      correlationReferenceId: correlation,
      provenance: BusinessReviewProvenance.syntheticDemo,
      occurredAt: DateTime.utc(2025, 3, 1),
      metadataSummary: 'Demo signal',
    );
  }

  test('demo seed is ordered deterministically by occurredAt', () {
    final events = repo.listForCurrentScope();
    expect(events.length, greaterThan(3));
    for (var i = 1; i < events.length; i++) {
      expect(
        events[i - 1].occurredAt.compareTo(events[i].occurredAt),
        lessThanOrEqualTo(0),
      );
    }
  });

  test('append is duplicate-safe by correlation reference', () {
    const corr = 'test-corr-unique-001';
    expect(repo.appendEvent(input(correlation: corr)), success);
    expect(
      repo.appendEvent(input(correlation: corr)),
      BusinessReputationEventRecordResult.duplicateCorrelation,
    );
    expect(repo.listForCurrentScope(sourceRecordId: 'demo-complaint-x').length, 1);
  });

  test('invalid append does not mutate event list length', () {
    final before = repo.listForCurrentScope().length;
    expect(
      repo.appendEvent(
        input(correlation: 'bad-corr-user@example.com'),
      ),
      BusinessReputationEventRecordResult.invalidInput,
    );
    expect(repo.listForCurrentScope().length, before);
  });

  test('failNextAppend leaves state unchanged', () {
    repo.failNextAppend = true;
    final before = repo.listForCurrentScope().length;
    expect(
      repo.appendEvent(input(correlation: 'fail-corr-001')),
      BusinessReputationEventRecordResult.failure,
    );
    expect(repo.listForCurrentScope().length, before);
    expect(repo.hasCorrelationReference('fail-corr-001'), isFalse);
  });
}

const success = BusinessReputationEventRecordResult.success;
