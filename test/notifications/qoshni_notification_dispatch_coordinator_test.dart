import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/application/qoshni_notification_dispatch_coordinator.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_dispatch_audit_repository.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_preference_repository.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_repository.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_dispatch_demo_scenarios.dart';
import 'package:qoshni/features/notifications/data/simulated_qoshni_notification_channel_adapters.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel_adapter.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';

void main() {
  late InMemoryQoshniNotificationRepository inbox;
  late InMemoryQoshniNotificationPreferenceRepository preferences;
  late InMemoryQoshniNotificationDispatchAuditRepository audit;
  late QoshniNotificationDispatchCoordinator coordinator;
  late Map<QoshniNotificationChannel, QoshniNotificationChannelAdapter> adapters;

  setUp(() {
    inbox = InMemoryQoshniNotificationRepository();
    preferences = InMemoryQoshniNotificationPreferenceRepository();
    audit = InMemoryQoshniNotificationDispatchAuditRepository();
    adapters = buildSimulatedQoshniNotificationChannelAdapters();
    coordinator = QoshniNotificationDispatchCoordinator(
      preferenceRepository: preferences,
      inboxRepository: inbox,
      auditRepository: audit,
      channelAdapters: adapters,
      clock: () => DateTime.utc(2025, 4, 10, 12, 0),
    );
    coordinator.auditIdFactory = audit.nextAuditRecordId;
  });

  test('delivers in-app notification on eligible midday order scenario', () {
    final before = inbox.list().length;
    final request = buildDemoDispatchRequest(
      scenario: QoshniNotificationDispatchDemoScenario.orderInAppMidday,
      idempotencySuffix: '001',
    );
    final result = coordinator.dispatch(request);
    expect(result.outcome, QoshniNotificationDispatchOutcome.deliveredToInbox);
    expect(inbox.list().length, before + 1);
    expect(audit.list().length, 1);
    expect(result.auditRecord?.inboxNotificationId, isNotNull);
  });

  test('suppresses quiet-hours order without inbox side effect', () {
    final before = inbox.list().length;
    final request = buildDemoDispatchRequest(
      scenario: QoshniNotificationDispatchDemoScenario.orderInAppQuietHours,
      idempotencySuffix: '002',
    );
    final result = coordinator.dispatch(request);
    expect(result.outcome, QoshniNotificationDispatchOutcome.suppressedByPolicy);
    expect(
      result.auditRecord?.eligibilityReason,
      QoshniNotificationEligibilityReason.suppressedQuietHours,
    );
    expect(inbox.list().length, before);
    expect(audit.list().length, 1);
  });

  test('security scenario bypasses quiet hours and delivers to inbox', () {
    final request = buildDemoDispatchRequest(
      scenario: QoshniNotificationDispatchDemoScenario.securityInAppQuietHours,
      idempotencySuffix: '003',
    );
    final result = coordinator.dispatch(request);
    expect(result.outcome, QoshniNotificationDispatchOutcome.deliveredToInbox);
  });

  test('promotion without consent is suppressed by policy', () {
    final request = buildDemoDispatchRequest(
      scenario: QoshniNotificationDispatchDemoScenario.promotionPushPreview,
      idempotencySuffix: '004',
    );
    final result = coordinator.dispatch(request);
    expect(result.outcome, QoshniNotificationDispatchOutcome.suppressedByPolicy);
    expect(
      result.auditRecord?.eligibilityReason,
      QoshniNotificationEligibilityReason.suppressedPromotionalConsentDisabled,
    );
  });

  test('duplicate idempotency does not create duplicate inbox items', () {
    final request = buildDemoDispatchRequest(
      scenario: QoshniNotificationDispatchDemoScenario.orderInAppMidday,
      idempotencySuffix: 'dup',
    );
    expect(coordinator.dispatch(request).outcome,
        QoshniNotificationDispatchOutcome.deliveredToInbox);
    final before = inbox.list().length;
    final duplicate = coordinator.dispatch(request);
    expect(
      duplicate.outcome,
      QoshniNotificationDispatchOutcome.duplicateIdempotencyReference,
    );
    expect(inbox.list().length, before);
    expect(audit.list().length, 1);
  });

  test('simulated channel failure does not write inbox notification', () {
    final adapter =
        adapters[QoshniNotificationChannel.inApp]!
            as SimulatedQoshniNotificationChannelAdapter;
    adapter.failNextSimulation = true;
    final before = inbox.list().length;
    final request = buildDemoDispatchRequest(
      scenario: QoshniNotificationDispatchDemoScenario.orderInAppMidday,
      idempotencySuffix: '005',
    );
    final result = coordinator.dispatch(request);
    expect(
      result.outcome,
      QoshniNotificationDispatchOutcome.simulatedChannelFailure,
    );
    expect(inbox.list().length, before);
    expect(audit.list().length, 1);
  });

  test('inbox persist failure records explicit failure audit without inbox id', () {
    inbox.failNextDeliver = true;
    final before = inbox.list().length;
    final request = buildDemoDispatchRequest(
      scenario: QoshniNotificationDispatchDemoScenario.orderInAppMidday,
      idempotencySuffix: '006',
    );
    final result = coordinator.dispatch(request);
    expect(result.outcome, QoshniNotificationDispatchOutcome.inboxPersistFailure);
    expect(result.auditRecord?.outcome,
        QoshniNotificationDispatchOutcome.inboxPersistFailure);
    expect(result.auditRecord?.inboxNotificationId, isNull);
    expect(result.auditRecord?.idempotencyReference, request.idempotencyReference);
    expect(inbox.list().length, before);
    expect(audit.list().length, 1);
    expect(
      result.auditRecord!.channelSimulationMessage,
      contains('In-app inbox persist failed'),
    );
  });

  test('retry after inbox persist failure is duplicate without extra inbox items', () {
    inbox.failNextDeliver = true;
    final request = buildDemoDispatchRequest(
      scenario: QoshniNotificationDispatchDemoScenario.orderInAppMidday,
      idempotencySuffix: '006-retry',
    );
    coordinator.dispatch(request);
    inbox.failNextDeliver = false;
    final before = inbox.list().length;
    final retry = coordinator.dispatch(request);
    expect(
      retry.outcome,
      QoshniNotificationDispatchOutcome.duplicateIdempotencyReference,
    );
    expect(inbox.list().length, before);
    expect(audit.list().length, 1);
  });

  test('audit append failure surfaces coordinator error without success claim', () {
    inbox.failNextDeliver = true;
    audit.failNextAppend = true;
    final request = buildDemoDispatchRequest(
      scenario: QoshniNotificationDispatchDemoScenario.orderInAppMidday,
      idempotencySuffix: '006-audit-fail',
    );
    final result = coordinator.dispatch(request);
    expect(result.outcome, QoshniNotificationDispatchOutcome.coordinatorFailure);
    expect(result.auditRecord, isNull);
    expect(audit.list(), isEmpty);
  });

  test('audit records sort deterministically by recordedAt desc', () {
    coordinator.dispatch(
      buildDemoDispatchRequest(
        scenario: QoshniNotificationDispatchDemoScenario.orderInAppMidday,
        idempotencySuffix: '007',
      ),
    );
    coordinator.dispatch(
      buildDemoDispatchRequest(
        scenario: QoshniNotificationDispatchDemoScenario.orderInAppQuietHours,
        idempotencySuffix: '008',
      ),
    );
    final records = audit.list();
    expect(records.length, 2);
    expect(
      records.first.recordedAt.compareTo(records.last.recordedAt),
      greaterThanOrEqualTo(0),
    );
  });
}
