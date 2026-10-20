import 'package:qoshni/features/business_platform/data/business_catalog_inventory_demo_seed.dart';
import 'package:qoshni/features/business_platform/data/business_fulfillment_demo_seed.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_history_event.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';

const String kDemoDeliveryTaskCreatedId = 'demo-delivery-task-created-001';
const String kDemoDeliveryTaskReadyId = 'demo-delivery-task-ready-002';
const String kDemoDeliveryTaskAssignedId = 'demo-delivery-task-assigned-003';
const String kDemoDeliveryTaskInTransitId = 'demo-delivery-task-in-transit-004';
const String kDemoDeliveryTaskDeliveredId = 'demo-delivery-task-delivered-005';
const String kDemoDeliveryTaskFailedId = 'demo-delivery-task-failed-006';

final DateTime kDemoDeliveryTaskEpoch =
    DateTime.utc(2025, 1, 2, 9, 0, 0);

List<BusinessDeliveryTask> buildDemoDeliveryTasks({
  required String businessScopeId,
}) {
  return [
    _seedTask(
      deliveryTaskId: kDemoDeliveryTaskCreatedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      fulfillmentConfigurationId: kDemoFulfillmentStoreDeliveryPickupId,
      status: BusinessDeliveryTaskStatus.created,
      demoTaskReference: 'DT-001',
      demoPickupLabel: 'Demo pickup — Tashkent Center',
      demoDropOffLabel: 'Demo drop-off — Task 001',
      updatedAt: kDemoDeliveryTaskEpoch,
    ),
    _seedTask(
      deliveryTaskId: kDemoDeliveryTaskReadyId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      fulfillmentConfigurationId: kDemoFulfillmentStoreDeliveryPickupId,
      status: BusinessDeliveryTaskStatus.readyForPickup,
      demoTaskReference: 'DT-002',
      demoPickupLabel: 'Demo pickup — Tashkent Center',
      demoDropOffLabel: 'Demo drop-off — Task 002',
      updatedAt: kDemoDeliveryTaskEpoch.add(const Duration(hours: 1)),
    ),
    _seedTask(
      deliveryTaskId: kDemoDeliveryTaskAssignedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      fulfillmentConfigurationId: kDemoFulfillmentStoreDeliveryPickupId,
      status: BusinessDeliveryTaskStatus.assigned,
      demoTaskReference: 'DT-003',
      demoPickupLabel: 'Demo pickup — Tashkent Center',
      demoDropOffLabel: 'Demo drop-off — Task 003',
      demoAssignmentReference: 'Demo courier slot A',
      updatedAt: kDemoDeliveryTaskEpoch.add(const Duration(hours: 2)),
    ),
    _seedTask(
      deliveryTaskId: kDemoDeliveryTaskInTransitId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      fulfillmentConfigurationId: kDemoFulfillmentShopSamarkandId,
      status: BusinessDeliveryTaskStatus.inTransit,
      demoTaskReference: 'DT-004',
      demoPickupLabel: 'Demo pickup — Samarkand',
      demoDropOffLabel: 'Demo drop-off — Task 004',
      demoAssignmentReference: 'Demo courier slot B',
      updatedAt: kDemoDeliveryTaskEpoch.add(const Duration(hours: 4)),
    ),
    _seedTask(
      deliveryTaskId: kDemoDeliveryTaskDeliveredId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchSamarkandId,
      fulfillmentConfigurationId: kDemoFulfillmentShopSamarkandId,
      status: BusinessDeliveryTaskStatus.delivered,
      demoTaskReference: 'DT-005',
      demoPickupLabel: 'Demo pickup — Samarkand',
      demoDropOffLabel: 'Demo drop-off — Task 005',
      demoAssignmentReference: 'Demo courier slot C',
      updatedAt: kDemoDeliveryTaskEpoch.add(const Duration(days: 1)),
    ),
    _seedTask(
      deliveryTaskId: kDemoDeliveryTaskFailedId,
      businessScopeId: businessScopeId,
      branchId: kDemoBranchTashkentCenterId,
      fulfillmentConfigurationId: kDemoFulfillmentStoreDeliveryPickupId,
      status: BusinessDeliveryTaskStatus.failed,
      demoTaskReference: 'DT-006',
      demoPickupLabel: 'Demo pickup — Tashkent Center',
      demoDropOffLabel: 'Demo drop-off — Task 006',
      demoAssignmentReference: 'Demo courier slot D',
      failureReason: 'Demo unreachable drop-off (simulated)',
      updatedAt: kDemoDeliveryTaskEpoch.add(const Duration(hours: 6)),
    ),
  ];
}

BusinessDeliveryTask _seedTask({
  required String deliveryTaskId,
  required String businessScopeId,
  required String branchId,
  required String fulfillmentConfigurationId,
  required BusinessDeliveryTaskStatus status,
  required String demoTaskReference,
  required String demoPickupLabel,
  required String demoDropOffLabel,
  String? demoAssignmentReference,
  String? failureReason,
  required DateTime updatedAt,
}) {
  return BusinessDeliveryTask(
    deliveryTaskId: deliveryTaskId,
    demoTaskReference: demoTaskReference,
    businessScopeId: businessScopeId,
    branchId: branchId,
    fulfillmentConfigurationId: fulfillmentConfigurationId,
    fulfillmentType: BusinessFulfillmentType.delivery,
    status: status,
    demoPickupLabel: demoPickupLabel,
    demoDropOffLabel: demoDropOffLabel,
    demoAssignmentReference: demoAssignmentReference,
    failureReason: failureReason,
    createdAt: kDemoDeliveryTaskEpoch,
    updatedAt: updatedAt,
    dataSource: BusinessCatalogProductDataSource.demoSeed,
  );
}

Map<String, List<BusinessDeliveryTaskHistoryEvent>> buildDemoDeliveryTaskHistory({
  required List<BusinessDeliveryTask> tasks,
}) {
  final map = <String, List<BusinessDeliveryTaskHistoryEvent>>{};
  for (final task in tasks) {
    map[task.deliveryTaskId] = [
      BusinessDeliveryTaskHistoryEvent(
        eventId: '${task.deliveryTaskId}-event-created',
        deliveryTaskId: task.deliveryTaskId,
        action: BusinessDeliveryTaskHistoryAction.created,
        newStatus: BusinessDeliveryTaskStatus.created,
        recordedAt: task.createdAt,
      ),
      if (task.status != BusinessDeliveryTaskStatus.created)
        BusinessDeliveryTaskHistoryEvent(
          eventId: '${task.deliveryTaskId}-event-current',
          deliveryTaskId: task.deliveryTaskId,
          action: BusinessDeliveryTaskHistoryAction.statusChanged,
          previousStatus: BusinessDeliveryTaskStatus.created,
          newStatus: task.status,
          recordedAt: task.updatedAt,
          reason: task.failureReason,
        ),
    ];
  }
  return map;
}
