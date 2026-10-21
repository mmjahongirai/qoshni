import 'package:qoshni/features/business_platform/data/business_reputation_event_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_owner_profile_repository.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_reputation_event_repository.dart';
import 'package:qoshni/features/business_platform/presentation/business_reputation_event_validation.dart';

class InMemoryBusinessReputationEventRepository
    implements BusinessReputationEventRepository {
  InMemoryBusinessReputationEventRepository(this._ownerProfileRepository);

  final BusinessOwnerProfileRepository _ownerProfileRepository;

  final Map<String, List<BusinessReputationEvent>> _byScope = {};
  final Map<String, Set<String>> _correlationByScope = {};

  int _eventCounter = 0;
  bool failNextAppend = false;

  @override
  String get businessScopeId =>
      _ownerProfileRepository.ensureSessionProfile().sessionProfileId;

  @override
  List<BusinessReputationEvent> listForCurrentScope({
    String? branchId,
    BusinessReputationEventSourceDomain? sourceDomain,
    BusinessReputationEventType? eventType,
    String? sourceRecordId,
  }) {
    var list = List<BusinessReputationEvent>.from(_ensureScopeList());
    if (branchId != null && branchId.trim().isNotEmpty) {
      final id = branchId.trim();
      list = list
          .where((e) => e.branchId == id || e.branchId == null)
          .toList();
    }
    if (sourceDomain != null) {
      list = list.where((e) => e.sourceDomain == sourceDomain).toList();
    }
    if (eventType != null) {
      list = list.where((e) => e.eventType == eventType).toList();
    }
    if (sourceRecordId != null && sourceRecordId.trim().isNotEmpty) {
      final id = sourceRecordId.trim();
      list = list.where((e) => e.sourceRecordId == id).toList();
    }
    return List.unmodifiable(list);
  }

  @override
  bool hasCorrelationReference(String correlationReferenceId) {
    return _ensureCorrelationSet().contains(correlationReferenceId.trim());
  }

  @override
  BusinessReputationEventRecordResult appendEvent(
    BusinessReputationEventRecordInput input,
  ) {
    if (catalogBusinessReputationEventRecordValidationError(input) != null) {
      return BusinessReputationEventRecordResult.invalidInput;
    }
    final correlation = input.correlationReferenceId.trim();
    if (hasCorrelationReference(correlation)) {
      return BusinessReputationEventRecordResult.duplicateCorrelation;
    }

    if (failNextAppend) {
      failNextAppend = false;
      return BusinessReputationEventRecordResult.failure;
    }

    final now = DateTime.now().toUtc();
    _eventCounter++;
    final id = 'session-reputation-event-$_eventCounter';

    final event = BusinessReputationEvent(
      reputationEventId: id,
      businessScopeId: businessScopeId,
      branchId: input.branchId?.trim(),
      targetType: input.targetType,
      targetId: input.targetId.trim(),
      eventType: input.eventType,
      sourceDomain: input.sourceDomain,
      sourceRecordId: input.sourceRecordId.trim(),
      previousStatusLabel: input.previousStatusLabel,
      newStatusLabel: input.newStatusLabel,
      correlationReferenceId: correlation,
      provenance: input.provenance,
      occurredAt: input.occurredAt.toUtc(),
      recordedAt: now,
      dataSource: BusinessCatalogProductDataSource.userSession,
      metadataSummary: input.metadataSummary?.trim(),
    );

    _ensureScopeList().add(event);
    _ensureCorrelationSet().add(correlation);
    _sortScopeList();
    return BusinessReputationEventRecordResult.success;
  }

  void _sortScopeList() {
    final list = _ensureScopeList();
    list.sort((a, b) {
      final byTime = a.occurredAt.compareTo(b.occurredAt);
      if (byTime != 0) {
        return byTime;
      }
      return a.reputationEventId.compareTo(b.reputationEventId);
    });
  }

  List<BusinessReputationEvent> _ensureScopeList() {
    return _byScope.putIfAbsent(businessScopeId, () {
      final seeded =
          buildDemoBusinessReputationEvents(businessScopeId: businessScopeId);
      _correlationByScope[businessScopeId] = seeded
          .map((e) => e.correlationReferenceId)
          .toSet();
      return seeded;
    });
  }

  Set<String> _ensureCorrelationSet() {
    _ensureScopeList();
    return _correlationByScope.putIfAbsent(businessScopeId, () => {});
  }
}
