import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_delivery_task_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_category.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_severity.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_status.dart';

const String kDemoDeliveryExceptionOpenId = 'demo-delivery-exception-open-001';
const String kDemoDeliveryExceptionResolvedId =
    'demo-delivery-exception-resolved-002';

List<BusinessDeliveryException> buildDemoDeliveryExceptions({
  required String businessScopeId,
}) {
  final epoch = kDemoDeliveryTaskEpoch;
  return [
    BusinessDeliveryException(
      exceptionId: kDemoDeliveryExceptionOpenId,
      deliveryTaskId: kDemoDeliveryTaskInTransitId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      category: BusinessDeliveryExceptionCategory.recipientUnavailable,
      severity: BusinessDeliveryExceptionSeverity.high,
      reason: 'Demo: recipient not reachable at drop-off label',
      status: BusinessDeliveryExceptionStatus.open,
      createdAt: epoch.add(const Duration(hours: 5)),
      updatedAt: epoch.add(const Duration(hours: 5)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
    BusinessDeliveryException(
      exceptionId: kDemoDeliveryExceptionResolvedId,
      deliveryTaskId: kDemoDeliveryTaskAssignedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      category: BusinessDeliveryExceptionCategory.deliveryDelayed,
      severity: BusinessDeliveryExceptionSeverity.medium,
      reason: 'Demo: short delay at pickup window',
      status: BusinessDeliveryExceptionStatus.resolved,
      resolutionNote: 'Demo: rescheduled within same demo session',
      resolvedAt: epoch.add(const Duration(hours: 3)),
      createdAt: epoch.add(const Duration(hours: 2, minutes: 30)),
      updatedAt: epoch.add(const Duration(hours: 3)),
      dataSource: BusinessCatalogProductDataSource.demoSeed,
    ),
  ];
}

Map<String, List<BusinessDeliveryExceptionHistoryEvent>>
    buildDemoDeliveryExceptionHistory({
  required List<BusinessDeliveryException> exceptions,
}) {
  final map = <String, List<BusinessDeliveryExceptionHistoryEvent>>{};
  for (final ex in exceptions) {
    map[ex.exceptionId] = [
      BusinessDeliveryExceptionHistoryEvent(
        eventId: '${ex.exceptionId}-created',
        exceptionId: ex.exceptionId,
        deliveryTaskId: ex.deliveryTaskId,
        action: BusinessDeliveryExceptionHistoryAction.created,
        newStatus: BusinessDeliveryExceptionStatus.open,
        recordedAt: ex.createdAt,
      ),
      if (ex.status != BusinessDeliveryExceptionStatus.open)
        BusinessDeliveryExceptionHistoryEvent(
          eventId: '${ex.exceptionId}-resolved',
          exceptionId: ex.exceptionId,
          deliveryTaskId: ex.deliveryTaskId,
          action: BusinessDeliveryExceptionHistoryAction.statusChanged,
          previousStatus: BusinessDeliveryExceptionStatus.open,
          newStatus: ex.status,
          recordedAt: ex.resolvedAt ?? ex.updatedAt,
          reason: ex.resolutionNote,
        ),
    ];
  }
  return map;
}
