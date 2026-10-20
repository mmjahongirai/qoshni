import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_task_status.dart';
import 'package:qoshni/features/business_platform/domain/business_fulfillment_type.dart';

class BusinessDeliveryTask {
  const BusinessDeliveryTask({
    required this.deliveryTaskId,
    required this.demoTaskReference,
    required this.businessScopeId,
    required this.branchId,
    this.fulfillmentConfigurationId,
    required this.fulfillmentType,
    required this.status,
    required this.demoPickupLabel,
    required this.demoDropOffLabel,
    this.demoAssignmentReference,
    this.demoExternalOrderReference,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
    required this.dataSource,
  });

  final String deliveryTaskId;
  final String demoTaskReference;
  final String businessScopeId;
  final String branchId;
  final String? fulfillmentConfigurationId;
  final BusinessFulfillmentType fulfillmentType;
  final BusinessDeliveryTaskStatus status;
  final String demoPickupLabel;
  final String demoDropOffLabel;
  final String? demoAssignmentReference;
  /// Documented demo-only slot for a future order link — not a real order ID.
  final String? demoExternalOrderReference;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BusinessCatalogProductDataSource dataSource;

  bool get isDemoSeed => dataSource == BusinessCatalogProductDataSource.demoSeed;

  BusinessDeliveryTask copyWith({
    BusinessDeliveryTaskStatus? status,
    String? demoAssignmentReference,
    bool clearDemoAssignmentReference = false,
    String? failureReason,
    bool clearFailureReason = false,
    DateTime? updatedAt,
  }) {
    return BusinessDeliveryTask(
      deliveryTaskId: deliveryTaskId,
      demoTaskReference: demoTaskReference,
      businessScopeId: businessScopeId,
      branchId: branchId,
      fulfillmentConfigurationId: fulfillmentConfigurationId,
      fulfillmentType: fulfillmentType,
      status: status ?? this.status,
      demoPickupLabel: demoPickupLabel,
      demoDropOffLabel: demoDropOffLabel,
      demoAssignmentReference: clearDemoAssignmentReference
          ? null
          : (demoAssignmentReference ?? this.demoAssignmentReference),
      demoExternalOrderReference: demoExternalOrderReference,
      failureReason:
          clearFailureReason ? null : (failureReason ?? this.failureReason),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dataSource: dataSource,
    );
  }
}

class BusinessDeliveryTaskCreateInput {
  const BusinessDeliveryTaskCreateInput({
    required this.branchId,
    this.fulfillmentConfigurationId,
    this.fulfillmentType = BusinessFulfillmentType.delivery,
    required this.demoPickupLabel,
    required this.demoDropOffLabel,
    this.demoTaskReference,
    this.demoExternalOrderReference,
  });

  final String branchId;
  final String? fulfillmentConfigurationId;
  final BusinessFulfillmentType fulfillmentType;
  final String demoPickupLabel;
  final String demoDropOffLabel;
  final String? demoTaskReference;
  final String? demoExternalOrderReference;
}
