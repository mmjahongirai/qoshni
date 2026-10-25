class QoshniNotificationTemplateVariableDefinition {
  const QoshniNotificationTemplateVariableDefinition({
    required this.key,
    required this.required,
    this.description,
  });

  final String key;
  final bool required;
  final String? description;
}
