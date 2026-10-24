import 'package:flutter/foundation.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_template_demo_variables.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_definition.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_locale_resolution.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_render_result.dart'
    show
        QoshniNotificationTemplateRenderErr,
        QoshniNotificationTemplateRenderFailure,
        QoshniNotificationTemplateRenderResult;
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_renderer.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_template_status.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_template_repository.dart';

class QoshniNotificationTemplateController extends ChangeNotifier {
  QoshniNotificationTemplateController(this._repository);

  final QoshniNotificationTemplateRepository _repository;

  QoshniNotificationCategory? _categoryFilter;
  QoshniNotificationChannel? _channelFilter;
  QoshniNotificationTemplateStatus? _statusFilter;
  QoshniNotificationTemplateLocale _previewLocale =
      QoshniNotificationTemplateLocale.en;
  String? _selectedTemplateId;

  QoshniNotificationTemplateRenderResult? _lastPreviewResult;
  QoshniNotificationTemplateLocaleResolution? _lastLocaleResolution;

  QoshniNotificationCategory? get categoryFilter => _categoryFilter;
  QoshniNotificationChannel? get channelFilter => _channelFilter;
  QoshniNotificationTemplateStatus? get statusFilter => _statusFilter;
  QoshniNotificationTemplateLocale get previewLocale => _previewLocale;
  String? get selectedTemplateId => _selectedTemplateId;

  QoshniNotificationTemplateRenderResult? get lastPreviewResult =>
      _lastPreviewResult;
  QoshniNotificationTemplateLocaleResolution? get lastLocaleResolution =>
      _lastLocaleResolution;

  List<QoshniNotificationTemplateDefinition> get templates =>
      _repository.list(
        category: _categoryFilter,
        channel: _channelFilter,
        status: _statusFilter,
      );

  QoshniNotificationTemplateDefinition? get selectedTemplate =>
      _selectedTemplateId == null
          ? null
          : _repository.getById(_selectedTemplateId!);

  void setCategoryFilter(QoshniNotificationCategory? category) {
    if (_categoryFilter == category) {
      return;
    }
    _categoryFilter = category;
    _clearSelectionIfHidden();
    notifyListeners();
  }

  void setChannelFilter(QoshniNotificationChannel? channel) {
    if (_channelFilter == channel) {
      return;
    }
    _channelFilter = channel;
    _clearSelectionIfHidden();
    notifyListeners();
  }

  void setStatusFilter(QoshniNotificationTemplateStatus? status) {
    if (_statusFilter == status) {
      return;
    }
    _statusFilter = status;
    _clearSelectionIfHidden();
    notifyListeners();
  }

  void setPreviewLocale(QoshniNotificationTemplateLocale locale) {
    if (_previewLocale == locale) {
      return;
    }
    _previewLocale = locale;
    _refreshPreview();
    notifyListeners();
  }

  void selectTemplate(String? templateId) {
    if (_selectedTemplateId == templateId) {
      return;
    }
    _selectedTemplateId = templateId;
    _refreshPreview();
    notifyListeners();
  }

  void clearFilters() {
    _categoryFilter = null;
    _channelFilter = null;
    _statusFilter = null;
    _clearSelectionIfHidden();
    notifyListeners();
  }

  void refreshPreview() {
    _refreshPreview();
    notifyListeners();
  }

  void _clearSelectionIfHidden() {
    final selected = selectedTemplate;
    if (selected == null && _selectedTemplateId != null) {
      _selectedTemplateId = null;
      _lastPreviewResult = null;
      _lastLocaleResolution = null;
    }
  }

  void _refreshPreview() {
    final selected = selectedTemplate;
    if (selected == null) {
      _lastPreviewResult = null;
      _lastLocaleResolution = null;
      return;
    }

    final resolved = _repository.resolveByKeyAndLocale(
      templateKey: selected.templateKey,
      requestedLocale: _previewLocale,
    );
    _lastLocaleResolution = resolved.resolution;
    final template = resolved.template;
    if (template == null) {
      _lastPreviewResult = const QoshniNotificationTemplateRenderErr(
        QoshniNotificationTemplateRenderFailure(
          errorCode: 'locale_not_available',
        ),
      );
      return;
    }

    final variables = qoshniNotificationTemplateDemoVariablesForKey(
      template.templateKey,
    );
    _lastPreviewResult = QoshniNotificationTemplateRenderer.render(
      template: template,
      variables: variables,
      clock: () => template.updatedAt,
    );
  }
}
