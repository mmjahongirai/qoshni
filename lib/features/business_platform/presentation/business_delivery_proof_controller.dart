import 'package:flutter/foundation.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_proof_of_delivery.dart';
import 'package:qoshni/features/business_platform/domain/repositories/business_delivery_proof_repository.dart';

class BusinessDeliveryProofController extends ChangeNotifier {
  BusinessDeliveryProofController(this._repository);

  final BusinessDeliveryProofRepository _repository;

  bool _saveBusy = false;

  bool get saveBusy => _saveBusy;

  List<BusinessDeliveryProofOfDelivery> proofs({
    String? branchId,
    String? deliveryTaskId,
  }) =>
      _repository.listForCurrentScope(
        branchId: branchId,
        deliveryTaskId: deliveryTaskId,
      );

  List<BusinessDeliveryProofHistoryEvent> historyFor(String proofId) =>
      _repository.proofHistory(proofId);

  Future<BusinessDeliveryProofCreateResult> createProof(
    BusinessDeliveryProofCreateInput input,
  ) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.createProof(input);
    _saveBusy = false;
    notifyListeners();
    return result;
  }

  Future<BusinessDeliveryProofTransitionResult> applyTransition({
    required String proofId,
    required BusinessDeliveryProofTransitionRequest request,
  }) async {
    _saveBusy = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    final result = _repository.applyTransition(
      proofId: proofId,
      request: request,
    );
    _saveBusy = false;
    notifyListeners();
    return result;
  }
}
