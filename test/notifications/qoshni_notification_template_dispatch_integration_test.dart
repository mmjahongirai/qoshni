import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/application/qoshni_notification_dispatch_coordinator.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_dispatch_audit_repository.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_preference_repository.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_repository.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_template_repository.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_template_demo_variables.dart';
import 'package:qoshni/features/notifications/data/simulated_qoshni_notification_channel_adapters.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_dispatch_outcome.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_renderer.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_dispatch_controller.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_controller.dart';

void main() {
  late InMemoryQoshniNotificationRepository inbox;
  late InMemoryQoshniNotificationDispatchAuditRepository audit;
  late QoshniNotificationDispatchCoordinator coordinator;
  late QoshniNotificationDispatchController dispatchController;
  late InMemoryQoshniNotificationTemplateRepository templates;

  setUp(() {
    inbox = InMemoryQoshniNotificationRepository();
    audit = InMemoryQoshniNotificationDispatchAuditRepository();
    coordinator = QoshniNotificationDispatchCoordinator(
      preferenceRepository: InMemoryQoshniNotificationPreferenceRepository(),
      inboxRepository: inbox,
      auditRepository: audit,
      channelAdapters: buildSimulatedQoshniNotificationChannelAdapters(),
      clock: () => DateTime(2025, 4, 10, 12, 0),
    );
    coordinator.auditIdFactory = audit.nextAuditRecordId;
    dispatchController = QoshniNotificationDispatchController(
      coordinator,
      audit,
      QoshniNotificationController(inbox),
    );
    templates = InMemoryQoshniNotificationTemplateRepository();
  });

  test('render failure does not create inbox or audit records', () {
    final template = templates.resolveByKeyAndLocale(
      templateKey: 'demo.order.confirmation',
      requestedLocale: QoshniNotificationTemplateLocale.en,
    ).template!;
    final beforeInbox = inbox.list().length;
    final result = dispatchController.dispatchFromTemplate(
      template: template,
      variables: const {},
      evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
      idempotencySuffix: 'tpl-fail',
    );
    expect(result, isNull);
    expect(inbox.list().length, beforeInbox);
    expect(audit.list(), isEmpty);
  });

  test('successful render runs existing dispatch flow to inbox', () {
    final template = templates.resolveByKeyAndLocale(
      templateKey: 'demo.order.confirmation',
      requestedLocale: QoshniNotificationTemplateLocale.en,
    ).template!;
    final variables = qoshniNotificationTemplateDemoVariablesForKey(
      template.templateKey,
    );
    final render = QoshniNotificationTemplateRenderer.render(
      template: template,
      variables: variables,
    );
    expect(render.isSuccess, isTrue);

    final beforeInbox = inbox.list().length;
    final result = dispatchController.dispatchFromTemplate(
      template: template,
      variables: variables,
      evaluationLocalDateTime: DateTime(2025, 4, 10, 12, 0),
      idempotencySuffix: 'tpl-ok',
    );
    expect(result, isNotNull);
    expect(result!.outcome, QoshniNotificationDispatchOutcome.deliveredToInbox);
    expect(inbox.list().length, greaterThan(beforeInbox));
    expect(audit.list().length, 1);
  });
}
