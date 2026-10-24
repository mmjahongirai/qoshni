import 'package:qoshni/features/notifications/data/qoshni_notification_demo_seed.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_category.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_locale_content.dart';
import 'package:qoshni/features/system_messages/presentation/qoshni_system_message_validation.dart';
import 'package:qoshni/routing/route_paths.dart';

/// Primary demo recipient aligned with the notification inbox demo user.
const String kDemoSystemMessageRecipientPrimary =
    kDemoNotificationRecipientReference;

const String kDemoSystemMessageRecipientAlternate = 'demo-system-recipient-002';

final DateTime kDemoSystemMessageEpoch = DateTime.utc(2025, 4, 10, 12, 0);

List<QoshniSystemMessage> buildQoshniSystemMessageDemoSeed() {
  return List.unmodifiable([
    _msg(
      id: 'sys-msg-001',
      key: 'demo.announcement.welcome',
      category: QoshniSystemMessageCategory.generalAnnouncement,
      status: QoshniSystemMessageLifecycleStatus.published,
      publishedAt: DateTime.utc(2025, 4, 8, 9, 0),
      titles: (
        en: 'Welcome to the QO\'SHNI demo',
        ru: 'Добро пожаловать в демо QO\'SHNI',
        uz: 'QO\'SHNI demo platformasiga xush kelibsiz',
      ),
      bodies: (
        en: 'Synthetic platform announcement for preview only.',
        ru: 'Синтетическое объявление платформы только для предпросмотра.',
        uz: 'Faqat ko‘rish uchun sintetik platforma e\'lon.',
      ),
    ),
    _msg(
      id: 'sys-msg-002',
      key: 'demo.maintenance.preview',
      category: QoshniSystemMessageCategory.maintenanceNotice,
      status: QoshniSystemMessageLifecycleStatus.published,
      publishedAt: DateTime.utc(2025, 4, 9, 6, 0),
      visibleFrom: DateTime.utc(2025, 4, 9, 6, 0),
      visibleUntil: DateTime.utc(2025, 5, 1, 0, 0),
      titles: (
        en: 'Demo maintenance window (not real)',
        ru: 'Демо-окно обслуживания (не реальное)',
        uz: 'Demo texnik xizmat oynasi (haqiqiy emas)',
      ),
      bodies: (
        en: 'Example maintenance notice for UI testing only.',
        ru: 'Пример уведомления об обслуживании только для UI.',
        uz: 'Faqat UI sinovi uchun texnik xizmat namunasi.',
      ),
      route: RoutePaths.businessCenter,
    ),
    _msg(
      id: 'sys-msg-003',
      key: 'demo.service.catalog-update',
      category: QoshniSystemMessageCategory.serviceUpdate,
      status: QoshniSystemMessageLifecycleStatus.published,
      publishedAt: DateTime.utc(2025, 4, 7, 10, 0),
      titles: (
        en: 'Demo service catalog tips',
        ru: 'Подсказки по демо-каталогу',
        uz: 'Demo katalog bo‘yicha maslahatlar',
      ),
      bodies: (
        en: 'Explore Business Center catalog tools in this synthetic update.',
        ru: 'Изучите инструменты каталога в Business Center (демо).',
        uz: 'Business Center katalog vositalarini sinab ko‘ring (demo).',
      ),
    ),
    _msg(
      id: 'sys-msg-004',
      key: 'demo.policy.privacy-preview',
      category: QoshniSystemMessageCategory.policyInformation,
      status: QoshniSystemMessageLifecycleStatus.published,
      publishedAt: DateTime.utc(2025, 4, 6, 8, 0),
      titles: (
        en: 'Demo privacy overview',
        ru: 'Демо-обзор конфиденциальности',
        uz: 'Demo maxfiylik sharhi',
      ),
      bodies: (
        en: 'Policy-style copy for demonstration; not a legal notice.',
        ru: 'Текст в стиле политики для демонстрации; не юридическое уведомление.',
        uz: 'Namoyish uchun siyosat uslubidagi matn; huquqiy xabar emas.',
      ),
      route: RoutePaths.profile,
    ),
    _msg(
      id: 'sys-msg-005',
      key: 'demo.announcement.future',
      category: QoshniSystemMessageCategory.generalAnnouncement,
      status: QoshniSystemMessageLifecycleStatus.published,
      publishedAt: DateTime.utc(2025, 4, 1, 0, 0),
      visibleFrom: DateTime.utc(2025, 12, 1, 0, 0),
      titles: (
        en: 'Future demo announcement',
        ru: 'Будущее демо-объявление',
        uz: 'Kelajakdagi demo e\'lon',
      ),
      bodies: (
        en: 'Not visible until the configured start time.',
        ru: 'Не видно до настроенного времени начала.',
        uz: 'Boshlanish vaqtigacha ko‘rinmaydi.',
      ),
    ),
    _msg(
      id: 'sys-msg-006',
      key: 'demo.announcement.expired',
      category: QoshniSystemMessageCategory.generalAnnouncement,
      status: QoshniSystemMessageLifecycleStatus.published,
      publishedAt: DateTime.utc(2025, 3, 1, 0, 0),
      visibleUntil: DateTime.utc(2025, 4, 1, 0, 0),
      titles: (
        en: 'Expired demo announcement',
        ru: 'Истёкшее демо-объявление',
        uz: 'Muddati o‘tgan demo e\'lon',
      ),
      bodies: (
        en: 'This synthetic message is past its visible-until time.',
        ru: 'Это синтетическое сообщение просрочено по visible-until.',
        uz: 'Bu sintetik xabar visible-until vaqtidan o‘tgan.',
      ),
    ),
    _msg(
      id: 'sys-msg-007',
      key: 'demo.announcement.draft',
      category: QoshniSystemMessageCategory.generalAnnouncement,
      status: QoshniSystemMessageLifecycleStatus.draft,
      titles: (
        en: 'Draft demo announcement',
        ru: 'Черновик демо-объявления',
        uz: 'Demo e\'lon qoralama',
      ),
      bodies: (
        en: 'Draft content — not shown in the public feed.',
        ru: 'Черновик — не показывается в ленте.',
        uz: 'Qoralama — ommaviy lentada ko‘rinmaydi.',
      ),
    ),
    _msg(
      id: 'sys-msg-008',
      key: 'demo.announcement.withdrawn',
      category: QoshniSystemMessageCategory.serviceUpdate,
      status: QoshniSystemMessageLifecycleStatus.withdrawn,
      publishedAt: DateTime.utc(2025, 3, 20, 0, 0),
      titles: (
        en: 'Withdrawn demo update',
        ru: 'Отозванное демо-обновление',
        uz: 'Qaytarilgan demo yangilanish',
      ),
      bodies: (
        en: 'Withdrawn from the feed but retained for lifecycle tests.',
        ru: 'Убрано из ленты, сохранено для тестов жизненного цикла.',
        uz: 'Lentadan olib tashlangan, siklus testlari uchun saqlangan.',
      ),
    ),
    _msg(
      id: 'sys-msg-009',
      key: 'demo.announcement.archived',
      category: QoshniSystemMessageCategory.generalAnnouncement,
      status: QoshniSystemMessageLifecycleStatus.archived,
      publishedAt: DateTime.utc(2025, 2, 1, 0, 0),
      titles: (
        en: 'Archived demo announcement',
        ru: 'Архивное демо-объявление',
        uz: 'Arxivlangan demo e\'lon',
      ),
      bodies: (
        en: 'Archived synthetic record.',
        ru: 'Архивная синтетическая запись.',
        uz: 'Arxiv sintetik yozuv.',
      ),
    ),
  ]);
}

typedef _Triplet = ({String en, String ru, String uz});

QoshniSystemMessage _msg({
  required String id,
  required String key,
  required QoshniSystemMessageCategory category,
  required QoshniSystemMessageLifecycleStatus status,
  required _Triplet titles,
  required _Triplet bodies,
  DateTime? publishedAt,
  DateTime? visibleFrom,
  DateTime? visibleUntil,
  String? route,
}) {
  final created = DateTime.utc(2025, 3, 1, 8, 0);
  return QoshniSystemMessage(
    messageId: id,
    messageKey: key,
    audienceScope: kQoshniSystemMessageDemoAudienceScope,
    category: category,
    lifecycleStatus: status,
    localizedContent: {
      QoshniNotificationTemplateLocale.en: QoshniSystemMessageLocaleContent(
        title: titles.en,
        body: bodies.en,
      ),
      QoshniNotificationTemplateLocale.ru: QoshniSystemMessageLocaleContent(
        title: titles.ru,
        body: bodies.ru,
      ),
      QoshniNotificationTemplateLocale.uz: QoshniSystemMessageLocaleContent(
        title: titles.uz,
        body: bodies.uz,
      ),
    },
    createdAt: created,
    updatedAt: created,
    publishedAt: publishedAt,
    visibleFrom: visibleFrom,
    visibleUntil: visibleUntil,
    internalNavigationRoute: route,
  );
}
