import 'package:qoshni/features/business_platform/domain/business_reputation_event.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';

enum BusinessReputationEventRecordResult {
  success,
  invalidInput,
  duplicateCorrelation,
  failure,
}

abstract class BusinessReputationEventRepository {
  String get businessScopeId;

  List<BusinessReputationEvent> listForCurrentScope({
    String? branchId,
    BusinessReputationEventSourceDomain? sourceDomain,
    BusinessReputationEventType? eventType,
    String? sourceRecordId,
  });

  BusinessReputationEventRecordResult appendEvent(
    BusinessReputationEventRecordInput input,
  );

  bool hasCorrelationReference(String correlationReferenceId);
}
