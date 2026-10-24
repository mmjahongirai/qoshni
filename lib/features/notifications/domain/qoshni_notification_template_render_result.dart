class QoshniNotificationTemplateRenderSuccess {
  const QoshniNotificationTemplateRenderSuccess({
    required this.title,
    required this.body,
    required this.renderedAt,
  });

  final String title;
  final String body;
  final DateTime renderedAt;
}

class QoshniNotificationTemplateRenderFailure {
  const QoshniNotificationTemplateRenderFailure({
    required this.errorCode,
    this.detail,
    this.missingVariables = const [],
    this.undeclaredPlaceholders = const [],
  });

  final String errorCode;
  final String? detail;
  final List<String> missingVariables;
  final List<String> undeclaredPlaceholders;
}

sealed class QoshniNotificationTemplateRenderResult {
  const QoshniNotificationTemplateRenderResult();

  bool get isSuccess => this is QoshniNotificationTemplateRenderOk;

  QoshniNotificationTemplateRenderSuccess? get successOrNull =>
      this is QoshniNotificationTemplateRenderOk
          ? (this as QoshniNotificationTemplateRenderOk).value
          : null;

  QoshniNotificationTemplateRenderFailure? get failureOrNull =>
      this is QoshniNotificationTemplateRenderErr
          ? (this as QoshniNotificationTemplateRenderErr).value
          : null;
}

class QoshniNotificationTemplateRenderOk extends QoshniNotificationTemplateRenderResult {
  const QoshniNotificationTemplateRenderOk(this.value);

  final QoshniNotificationTemplateRenderSuccess value;
}

class QoshniNotificationTemplateRenderErr extends QoshniNotificationTemplateRenderResult {
  const QoshniNotificationTemplateRenderErr(this.value);

  final QoshniNotificationTemplateRenderFailure value;
}
