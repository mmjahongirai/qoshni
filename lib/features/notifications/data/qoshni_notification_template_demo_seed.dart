import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_variable_definition.dart';
import 'package:qoshni/routing/route_paths.dart';

const int kQoshniNotificationTemplateDemoVersion = 1;
final DateTime kQoshniNotificationTemplateDemoUpdatedAt =
    DateTime.utc(2025, 4, 1, 9, 0);

List<QoshniNotificationTemplateDefinition> buildQoshniNotificationTemplateDemoSeed() {
  return List.unmodifiable([
    ..._orderConfirmationTemplates(),
    ..._deliveryStatusTemplates(),
    ..._securityAlertTemplates(),
    ..._businessUpdateTemplates(),
    ..._promotionalOfferTemplates(),
    ..._draftAndArchivedSamples(),
  ]);
}

List<QoshniNotificationTemplateDefinition> _orderConfirmationTemplates() {
  const key = 'demo.order.confirmation';
  const vars = [
    QoshniNotificationTemplateVariableDefinition(
      key: 'customerLabel',
      required: false,
    ),
    QoshniNotificationTemplateVariableDefinition(
      key: 'orderReference',
      required: true,
    ),
    QoshniNotificationTemplateVariableDefinition(
      key: 'etaWindow',
      required: false,
    ),
  ];
  return [
    _tpl(
      id: 'tpl-$key-en',
      key: key,
      locale: QoshniNotificationTemplateLocale.en,
      category: QoshniNotificationCategory.orders,
      channel: QoshniNotificationChannel.inApp,
      title: 'Order {{orderReference}} confirmed',
      body:
          'Hi {{customerLabel}}, your demo order {{orderReference}} is confirmed. ETA {{etaWindow}}.',
      variables: vars,
      route: RoutePaths.demoOrders,
    ),
    _tpl(
      id: 'tpl-$key-ru',
      key: key,
      locale: QoshniNotificationTemplateLocale.ru,
      category: QoshniNotificationCategory.orders,
      channel: QoshniNotificationChannel.inApp,
      title: 'Заказ {{orderReference}} подтверждён',
      body:
          'Здравствуйте, {{customerLabel}}! Демо-заказ {{orderReference}} подтверждён. Окно доставки: {{etaWindow}}.',
      variables: vars,
      route: RoutePaths.demoOrders,
    ),
    _tpl(
      id: 'tpl-$key-uz',
      key: key,
      locale: QoshniNotificationTemplateLocale.uz,
      category: QoshniNotificationCategory.orders,
      channel: QoshniNotificationChannel.inApp,
      title: 'Buyurtma {{orderReference}} tasdiqlandi',
      body:
          'Salom, {{customerLabel}}! Demo buyurtma {{orderReference}} tasdiqlandi. Yetkazish vaqti: {{etaWindow}}.',
      variables: vars,
      route: RoutePaths.demoOrders,
    ),
  ];
}

List<QoshniNotificationTemplateDefinition> _deliveryStatusTemplates() {
  const key = 'demo.delivery.status';
  const vars = [
    QoshniNotificationTemplateVariableDefinition(
      key: 'statusPhrase',
      required: true,
    ),
    QoshniNotificationTemplateVariableDefinition(
      key: 'courierLabel',
      required: false,
    ),
  ];
  return [
    _tpl(
      id: 'tpl-$key-en',
      key: key,
      locale: QoshniNotificationTemplateLocale.en,
      category: QoshniNotificationCategory.delivery,
      channel: QoshniNotificationChannel.pushPreview,
      title: 'Delivery update',
      body: '{{statusPhrase}} Courier: {{courierLabel}}.',
      variables: vars,
    ),
    _tpl(
      id: 'tpl-$key-ru',
      key: key,
      locale: QoshniNotificationTemplateLocale.ru,
      category: QoshniNotificationCategory.delivery,
      channel: QoshniNotificationChannel.pushPreview,
      title: 'Обновление доставки',
      body: '{{statusPhrase}} Курьер: {{courierLabel}}.',
      variables: vars,
    ),
    _tpl(
      id: 'tpl-$key-uz',
      key: key,
      locale: QoshniNotificationTemplateLocale.uz,
      category: QoshniNotificationCategory.delivery,
      channel: QoshniNotificationChannel.pushPreview,
      title: 'Yetkazib berish yangilandi',
      body: '{{statusPhrase}} Kuryer: {{courierLabel}}.',
      variables: vars,
    ),
  ];
}

List<QoshniNotificationTemplateDefinition> _securityAlertTemplates() {
  const key = 'demo.security.alert';
  const vars = [
    QoshniNotificationTemplateVariableDefinition(
      key: 'alertHeadline',
      required: true,
    ),
    QoshniNotificationTemplateVariableDefinition(
      key: 'actionHint',
      required: false,
    ),
  ];
  return [
    _tpl(
      id: 'tpl-$key-en',
      key: key,
      locale: QoshniNotificationTemplateLocale.en,
      category: QoshniNotificationCategory.security,
      channel: QoshniNotificationChannel.inApp,
      priority: QoshniNotificationPriority.urgent,
      title: 'Security alert',
      body: '{{alertHeadline}} Next step: {{actionHint}}.',
      variables: vars,
      route: RoutePaths.profile,
    ),
    _tpl(
      id: 'tpl-$key-ru',
      key: key,
      locale: QoshniNotificationTemplateLocale.ru,
      category: QoshniNotificationCategory.security,
      channel: QoshniNotificationChannel.inApp,
      priority: QoshniNotificationPriority.urgent,
      title: 'Оповещение безопасности',
      body: '{{alertHeadline}} Действие: {{actionHint}}.',
      variables: vars,
      route: RoutePaths.profile,
    ),
    _tpl(
      id: 'tpl-$key-uz',
      key: key,
      locale: QoshniNotificationTemplateLocale.uz,
      category: QoshniNotificationCategory.security,
      channel: QoshniNotificationChannel.inApp,
      priority: QoshniNotificationPriority.urgent,
      title: 'Xavfsizlik ogohlantirishi',
      body: '{{alertHeadline}} Keyingi qadam: {{actionHint}}.',
      variables: vars,
      route: RoutePaths.profile,
    ),
  ];
}

List<QoshniNotificationTemplateDefinition> _businessUpdateTemplates() {
  const key = 'demo.business.update';
  const vars = [
    QoshniNotificationTemplateVariableDefinition(
      key: 'businessName',
      required: true,
    ),
    QoshniNotificationTemplateVariableDefinition(
      key: 'updateSummary',
      required: true,
    ),
  ];
  return [
    _tpl(
      id: 'tpl-$key-en',
      key: key,
      locale: QoshniNotificationTemplateLocale.en,
      category: QoshniNotificationCategory.business,
      channel: QoshniNotificationChannel.emailPreview,
      title: '{{businessName}} service update',
      body: 'Demo business notice: {{updateSummary}}.',
      variables: vars,
    ),
    _tpl(
      id: 'tpl-$key-ru',
      key: key,
      locale: QoshniNotificationTemplateLocale.ru,
      category: QoshniNotificationCategory.business,
      channel: QoshniNotificationChannel.emailPreview,
      title: 'Обновление {{businessName}}',
      body: 'Демо-уведомление для бизнеса: {{updateSummary}}.',
      variables: vars,
    ),
    _tpl(
      id: 'tpl-$key-uz',
      key: key,
      locale: QoshniNotificationTemplateLocale.uz,
      category: QoshniNotificationCategory.business,
      channel: QoshniNotificationChannel.emailPreview,
      title: '{{businessName}} xizmat yangilanishi',
      body: 'Demo biznes xabari: {{updateSummary}}.',
      variables: vars,
    ),
  ];
}

List<QoshniNotificationTemplateDefinition> _promotionalOfferTemplates() {
  const key = 'demo.promotion.offer';
  const vars = [
    QoshniNotificationTemplateVariableDefinition(
      key: 'offerTitle',
      required: true,
    ),
    QoshniNotificationTemplateVariableDefinition(
      key: 'discountPercent',
      required: true,
    ),
    QoshniNotificationTemplateVariableDefinition(
      key: 'expiryDate',
      required: false,
    ),
  ];
  return [
    _tpl(
      id: 'tpl-$key-en',
      key: key,
      locale: QoshniNotificationTemplateLocale.en,
      category: QoshniNotificationCategory.promotions,
      channel: QoshniNotificationChannel.inApp,
      priority: QoshniNotificationPriority.low,
      title: '{{offerTitle}}',
      body:
          'Demo offer: {{discountPercent}}% off. Valid until {{expiryDate}}.',
      variables: vars,
    ),
    _tpl(
      id: 'tpl-$key-ru',
      key: key,
      locale: QoshniNotificationTemplateLocale.ru,
      category: QoshniNotificationCategory.promotions,
      channel: QoshniNotificationChannel.inApp,
      priority: QoshniNotificationPriority.low,
      title: '{{offerTitle}}',
      body:
          'Демо-акция: скидка {{discountPercent}}%. Действует до {{expiryDate}}.',
      variables: vars,
    ),
    _tpl(
      id: 'tpl-$key-uz',
      key: key,
      locale: QoshniNotificationTemplateLocale.uz,
      category: QoshniNotificationCategory.promotions,
      channel: QoshniNotificationChannel.inApp,
      priority: QoshniNotificationPriority.low,
      title: '{{offerTitle}}',
      body:
          'Demo taklif: {{discountPercent}}% chegirma. Amal qilish muddati: {{expiryDate}}.',
      variables: vars,
    ),
  ];
}

List<QoshniNotificationTemplateDefinition> _draftAndArchivedSamples() {
  return [
    _tpl(
      id: 'tpl-demo.draft.welcome-en',
      key: 'demo.draft.welcome',
      locale: QoshniNotificationTemplateLocale.en,
      category: QoshniNotificationCategory.business,
      channel: QoshniNotificationChannel.inApp,
      status: QoshniNotificationTemplateStatus.draft,
      title: 'Welcome draft',
      body: 'Draft template — not for active preview.',
      variables: const [],
    ),
    _tpl(
      id: 'tpl-demo.archived.promotion-en',
      key: 'demo.archived.promotion',
      locale: QoshniNotificationTemplateLocale.en,
      category: QoshniNotificationCategory.promotions,
      channel: QoshniNotificationChannel.inApp,
      status: QoshniNotificationTemplateStatus.archived,
      title: 'Archived promo',
      body: 'Archived synthetic promotion template.',
      variables: const [
        QoshniNotificationTemplateVariableDefinition(
          key: 'offerTitle',
          required: true,
        ),
      ],
    ),
  ];
}

QoshniNotificationTemplateDefinition _tpl({
  required String id,
  required String key,
  required QoshniNotificationTemplateLocale locale,
  required QoshniNotificationCategory category,
  required QoshniNotificationChannel channel,
  required String title,
  required String body,
  required List<QoshniNotificationTemplateVariableDefinition> variables,
  QoshniNotificationTemplateStatus status =
      QoshniNotificationTemplateStatus.active,
  QoshniNotificationPriority priority = QoshniNotificationPriority.normal,
  String? route,
}) {
  return QoshniNotificationTemplateDefinition(
    templateId: id,
    templateKey: key,
    category: category,
    channel: channel,
    status: status,
    locale: locale,
    titleTemplate: title,
    bodyTemplate: body,
    variables: variables,
    priority: priority,
    version: kQoshniNotificationTemplateDemoVersion,
    updatedAt: kQoshniNotificationTemplateDemoUpdatedAt,
    internalNavigationRoute: route,
  );
}
