import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_source_domain.dart';
import 'package:qoshni/features/business_platform/domain/business_reputation_event_type.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_reputation_event_repository.dart';

class BusinessReputationEventController extends ChangeNotifier {
  BusinessReputationEventController(this._repository);

  final BusinessReputationEventRepository _repository;

  bool _listLoading = true;

  bool get listLoading => _listLoading;

  List<BusinessReputationEvent> events({
    String? branchId,
    BusinessReputationEventSourceDomain? sourceDomain,
    BusinessReputationEventType? eventType,
    String? sourceRecordId,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        sourceDomain: sourceDomain,
        eventType: eventType,
        sourceRecordId: sourceRecordId,
      );

  Future<void> refreshList() async {
    _listLoading = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _repository.listForCurrentScope();
    _listLoading = false;
    notifyListeners();
  }
}
