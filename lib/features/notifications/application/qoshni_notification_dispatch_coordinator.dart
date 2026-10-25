import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel_adapter.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_eligibility.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_delivery_policy.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_audit_record.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_request.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_dispatch_audit_repository.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_preference_repository.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_repository.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_dispatch_validation.dart';

export 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_audit_record.dart'
    show QoshniNotificationDispatchOperationResult;

typedef QoshniNotificationDispatchClock = DateTime Function();

class QoshniNotificationDispatchCoordinator {
  QoshniNotificationDispatchCoordinator({
    required QoshniNotificationPreferenceRepository preferenceRepository,
    required QoshniNotificationRepository inboxRepository,
    required QoshniNotificationDispatchAuditRepository auditRepository,
    required Map<QoshniNotificationChannel, QoshniNotificationChannelAdapter>
        channelAdapters,
    QoshniNotificationDispatchClock? clock,
  })  : _preferenceRepository = preferenceRepository,
        _inboxRepository = inboxRepository,
        _auditRepository = auditRepository,
        _channelAdapters = channelAdapters,
        _clock = clock ?? DateTime.now;

  final QoshniNotificationPreferenceRepository _preferenceRepository;
  final QoshniNotificationRepository _inboxRepository;
  final QoshniNotificationDispatchAuditRepository _auditRepository;
  final Map<QoshniNotificationChannel, QoshniNotificationChannelAdapter>
      _channelAdapters;
  final QoshniNotificationDispatchClock _clock;

  String Function()? auditIdFactory;

  QoshniNotificationDispatchOperationResult dispatch(
    QoshniNotificationDispatchRequest request,
  ) {
    if (qoshniNotificationDispatchRequestValidationError(request) != null) {
      return const QoshniNotificationDispatchOperationResult(
        outcome: QoshniNotificationDispatchOutcome.validationFailed,
      );
    }

    final idem = request.idempotencyReference.trim();
    if (_auditRepository.hasIdempotencyReference(idem)) {
      return QoshniNotificationDispatchOperationResult(
        outcome: QoshniNotificationDispatchOutcome.duplicateIdempotencyReference,
        auditRecord: _auditRepository.findByIdempotencyReference(idem),
      );
    }

    final preferences = _preferenceRepository.preferences;
    if (request.demoRecipientReference.trim() !=
        preferences.demoRecipientReference) {
      return const QoshniNotificationDispatchOperationResult(
        outcome: QoshniNotificationDispatchOutcome.validationFailed,
      );
    }

    final eligibility = QoshniNotificationDeliveryPolicy.evaluate(
      preferences: preferences,
      scenario: QoshniNotificationEligibilityInput(
        category: request.category,
        channel: request.channel,
        priority: request.priority,
      ),
      evaluationLocalDateTime: request.evaluationLocalDateTime,
    );

    final adapter = _channelAdapters[request.channel];
    if (adapter == null) {
      return const QoshniNotificationDispatchOperationResult(
        outcome: QoshniNotificationDispatchOutcome.coordinatorFailure,
      );
    }

    if (!eligibility.isEligible) {
      return _finalizeAudit(
        request: request,
        outcome: QoshniNotificationDispatchOutcome.suppressedByPolicy,
        eligibilityReason: eligibility.reason,
        channelSimulationMessage:
            'Channel simulation skipped — suppressed by policy.',
        inboxNotificationId: null,
      );
    }

    final simulation = adapter.simulate(request);
    if (!simulation.isSimulatedSuccess) {
      return _finalizeAudit(
        request: request,
        outcome: QoshniNotificationDispatchOutcome.simulatedChannelFailure,
        eligibilityReason: QoshniNotificationEligibilityReason.eligible,
        channelSimulationMessage: simulation.message,
        inboxNotificationId: null,
      );
    }

    String? inboxNotificationId;
    if (request.channel == QoshniNotificationChannel.inApp) {
      final deliverResult = _inboxRepository.deliver(
        QoshniNotificationDeliverInput(
          demoRecipientReference: request.demoRecipientReference.trim(),
          category: request.category,
          channel: request.channel,
          title: request.title.trim(),
          body: request.body.trim(),
          createdAt: _clock().toUtc(),
          priority: request.priority,
          internalNavigationRoute: request.internalNavigationRoute?.trim(),
          provenance: QoshniNotificationProvenance.syntheticDemo,
          deduplicationReference: idem,
        ),
      );
      if (deliverResult != QoshniNotificationDeliverResult.success) {
        return _finalizeAudit(
          request: request,
          outcome: QoshniNotificationDispatchOutcome.inboxPersistFailure,
          eligibilityReason: QoshniNotificationEligibilityReason.eligible,
          channelSimulationMessage: _inboxPersistFailureMessage(
            simulation.message,
            deliverResult,
          ),
          inboxNotificationId: null,
        );
      }
      inboxNotificationId = _resolveInboxIdByDedupe(idem);
    }

    final outcome = request.channel == QoshniNotificationChannel.inApp
        ? QoshniNotificationDispatchOutcome.deliveredToInbox
        : QoshniNotificationDispatchOutcome.simulatedChannelDelivered;

    return _finalizeAudit(
      request: request,
      outcome: outcome,
      eligibilityReason: QoshniNotificationEligibilityReason.eligible,
      channelSimulationMessage: simulation.message,
      inboxNotificationId: inboxNotificationId,
    );
  }

  QoshniNotificationDispatchOperationResult _finalizeAudit({
    required QoshniNotificationDispatchRequest request,
    required QoshniNotificationDispatchOutcome outcome,
    required QoshniNotificationEligibilityReason eligibilityReason,
    required String channelSimulationMessage,
    required String? inboxNotificationId,
  }) {
    final auditId = auditIdFactory?.call() ?? 'dispatch-audit-session';
    final record = QoshniNotificationDispatchAuditRecord(
      auditRecordId: auditId,
      recordedAt: _clock().toUtc(),
      demoRecipientReference: request.demoRecipientReference.trim(),
      category: request.category,
      channel: request.channel,
      priority: request.priority,
      titleSummary: request.title.trim(),
      idempotencyReference: request.idempotencyReference.trim(),
      correlationReference: request.correlationReference.trim(),
      source: request.source,
      outcome: outcome,
      eligibilityReason: eligibilityReason,
      channelSimulationMessage: channelSimulationMessage,
      provenance: QoshniNotificationProvenance.syntheticDemo,
      inboxNotificationId: inboxNotificationId,
    );

    final appendResult = _auditRepository.append(record);
    if (appendResult != QoshniNotificationDispatchAuditAppendResult.success) {
      return const QoshniNotificationDispatchOperationResult(
        outcome: QoshniNotificationDispatchOutcome.coordinatorFailure,
      );
    }

    return QoshniNotificationDispatchOperationResult(
      outcome: outcome,
      auditRecord: record,
    );
  }

  static String _inboxPersistFailureMessage(
    String simulationMessage,
    QoshniNotificationDeliverResult deliverResult,
  ) {
    final detail = switch (deliverResult) {
      QoshniNotificationDeliverResult.invalidInput => 'invalid inbox payload',
      QoshniNotificationDeliverResult.duplicateDeduplicationReference =>
        'duplicate inbox deduplication reference',
      QoshniNotificationDeliverResult.failure => 'inbox repository failure',
      QoshniNotificationDeliverResult.success => 'unexpected success',
    };
    return '$simulationMessage In-app inbox persist failed: $detail (demo).';
  }

  String? _resolveInboxIdByDedupe(String dedupe) {
    for (final item in _inboxRepository.list()) {
      if (item.deduplicationReference == dedupe) {
        return item.notificationId;
      }
    }
    return null;
  }
}
