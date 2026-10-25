import 'package:flutter/foundation.dart';
import 'package:qoshni/features/notifications/application/qoshni_notification_dispatch_coordinator.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_dispatch_demo_scenarios.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_audit_record.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_request.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_dispatch_audit_repository.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_source.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_render_result.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_renderer.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_demo_seed.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_controller.dart';

class QoshniNotificationDispatchController extends ChangeNotifier {
  QoshniNotificationDispatchController(
    this._coordinator,
    this._auditRepository,
    this._inboxController,
  );

  final QoshniNotificationDispatchCoordinator _coordinator;
  final QoshniNotificationDispatchAuditRepository _auditRepository;
  final QoshniNotificationController _inboxController;

  QoshniNotificationDispatchOutcome? _lastOutcome;
  QoshniNotificationDispatchAuditRecord? _lastAuditRecord;
  QoshniNotificationTemplateRenderResult? _lastTemplateRenderResult;
  int _scenarioCounter = 0;

  QoshniNotificationDispatchOutcome? get lastOutcome => _lastOutcome;
  QoshniNotificationDispatchAuditRecord? get lastAuditRecord => _lastAuditRecord;
  QoshniNotificationTemplateRenderResult? get lastTemplateRenderResult =>
      _lastTemplateRenderResult;

  QoshniNotificationDispatchOutcome? _outcomeFilter;
  QoshniNotificationCategory? _categoryFilter;
  QoshniNotificationChannel? _channelFilter;

  QoshniNotificationDispatchOutcome? get outcomeFilter => _outcomeFilter;
  QoshniNotificationCategory? get categoryFilter => _categoryFilter;
  QoshniNotificationChannel? get channelFilter => _channelFilter;

  List<QoshniNotificationDispatchAuditRecord> get auditRecords =>
      _auditRepository.list(
        outcome: _outcomeFilter,
        category: _categoryFilter,
        channel: _channelFilter,
      );

  void setOutcomeFilter(QoshniNotificationDispatchOutcome? outcome) {
    if (_outcomeFilter == outcome) {
      return;
    }
    _outcomeFilter = outcome;
    notifyListeners();
  }

  void setCategoryFilter(QoshniNotificationCategory? category) {
    if (_categoryFilter == category) {
      return;
    }
    _categoryFilter = category;
    notifyListeners();
  }

  void setChannelFilter(QoshniNotificationChannel? channel) {
    if (_channelFilter == channel) {
      return;
    }
    _channelFilter = channel;
    notifyListeners();
  }

  void clearFilters() {
    _outcomeFilter = null;
    _categoryFilter = null;
    _channelFilter = null;
    notifyListeners();
  }

  QoshniNotificationDispatchOperationResult dispatch(
    QoshniNotificationDispatchRequest request,
  ) {
    final result = _coordinator.dispatch(request);
    _lastOutcome = result.outcome;
    _lastAuditRecord = result.auditRecord;
    if (result.outcome == QoshniNotificationDispatchOutcome.deliveredToInbox) {
      _inboxController.refresh();
    }
    notifyListeners();
    return result;
  }

  QoshniNotificationDispatchOperationResult runDemoScenario(
    QoshniNotificationDispatchDemoScenario scenario,
  ) {
    _scenarioCounter++;
    final request = buildDemoDispatchRequest(
      scenario: scenario,
      idempotencySuffix: _scenarioCounter.toString().padLeft(4, '0'),
    );
    return dispatch(request);
  }

  /// Renders [template] with [variables], then runs dispatch when render succeeds.
  /// Render failure does not call the coordinator (no inbox or audit side effects).
  QoshniNotificationDispatchOperationResult? dispatchFromTemplate({
    required QoshniNotificationTemplateDefinition template,
    required Map<String, String> variables,
    required DateTime evaluationLocalDateTime,
    String? idempotencySuffix,
  }) {
    final render = QoshniNotificationTemplateRenderer.render(
      template: template,
      variables: variables,
      clock: () => evaluationLocalDateTime.toUtc(),
    );
    _lastTemplateRenderResult = render;
    final success = render.successOrNull;
    if (success == null) {
      notifyListeners();
      return null;
    }

    _scenarioCounter++;
    final suffix =
        idempotencySuffix ?? _scenarioCounter.toString().padLeft(4, '0');
    final idempotency =
        'dispatch-tpl-${template.templateKey}-$suffix'.replaceAll(' ', '');
    final request = QoshniNotificationDispatchRequest(
      demoRecipientReference: kDemoNotificationRecipientReference,
      category: template.category,
      channel: template.channel,
      priority: template.priority,
      title: success.title,
      body: success.body,
      idempotencyReference: idempotency,
      correlationReference: 'dispatch-corr-tpl-$suffix',
      source: QoshniNotificationDispatchSource.demoTemplatePreview,
      evaluationLocalDateTime: evaluationLocalDateTime,
      internalNavigationRoute: template.internalNavigationRoute,
    );
    return dispatch(request);
  }
}
