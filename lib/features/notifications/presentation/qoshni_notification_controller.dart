import 'package:flutter/foundation.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_repository.dart';

class QoshniNotificationController extends ChangeNotifier {
  QoshniNotificationController(this._repository);

  final QoshniNotificationRepository _repository;

  QoshniNotificationReadFilter _readFilter = QoshniNotificationReadFilter.all;
  QoshniNotificationCategory? _categoryFilter;

  String? lastOperationMessageKey;

  QoshniNotificationReadFilter get readFilter => _readFilter;

  QoshniNotificationCategory? get categoryFilter => _categoryFilter;

  int get unreadCount => _repository.unreadCount();

  List<QoshniNotification> get notifications => _repository.list(
        readFilter: _readFilter,
        category: _categoryFilter,
      );

  void refresh() {
    notifyListeners();
  }

  void setReadFilter(QoshniNotificationReadFilter filter) {
    if (_readFilter == filter) {
      return;
    }
    _readFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(QoshniNotificationCategory? category) {
    if (_categoryFilter == category) {
      return;
    }
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _readFilter = QoshniNotificationReadFilter.all;
    _categoryFilter = null;
    notifyListeners();
  }

  QoshniNotificationMarkReadResult markRead(String notificationId) {
    final result = _repository.markRead(notificationId);
    lastOperationMessageKey = switch (result) {
      QoshniNotificationMarkReadResult.success => 'markReadSuccess',
      QoshniNotificationMarkReadResult.alreadyRead => 'markReadAlready',
      QoshniNotificationMarkReadResult.notFound => 'markReadNotFound',
      QoshniNotificationMarkReadResult.invalidId => 'markReadInvalid',
      QoshniNotificationMarkReadResult.failure => 'markReadFailure',
    };
    notifyListeners();
    return result;
  }

  QoshniNotificationMarkAllReadResult markAllRead() {
    final result = _repository.markAllRead();
    lastOperationMessageKey = switch (result) {
      QoshniNotificationMarkAllReadResult.success => 'markAllReadSuccess',
      QoshniNotificationMarkAllReadResult.failure => 'markAllReadFailure',
    };
    notifyListeners();
    return result;
  }
}
