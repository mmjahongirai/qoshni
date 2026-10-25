/// Supported template locales aligned with app localization (en, ru, uz).
enum QoshniNotificationTemplateLocale {
  en,
  ru,
  uz;

  String get languageCode => name;

  static QoshniNotificationTemplateLocale? fromLanguageCode(String? code) {
    if (code == null || code.isEmpty) {
      return null;
    }
    final primary = code.split('-').first.toLowerCase();
    return switch (primary) {
      'en' => QoshniNotificationTemplateLocale.en,
      'ru' => QoshniNotificationTemplateLocale.ru,
      'uz' => QoshniNotificationTemplateLocale.uz,
      _ => null,
    };
  }

  static const List<QoshniNotificationTemplateLocale> fallbackOrder = [
    QoshniNotificationTemplateLocale.en,
    QoshniNotificationTemplateLocale.ru,
    QoshniNotificationTemplateLocale.uz,
  ];
}
