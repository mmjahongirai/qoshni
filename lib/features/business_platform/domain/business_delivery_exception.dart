import 'package:qoshni/features/business_platform/domain/business_catalog_product.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_category.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_severity.dart';
import 'package:qoshni/features/business_platform/domain/business_delivery_exception_status.dart';

class BusinessDeliveryException {
  const BusinessDeliveryException({
    required this.exceptionId,
    required this.deliveryTaskId,
    required this.businessScopeId,
    required this.branchId,
    required this.category,
    required this.severity,
    required this.reason,
    required this.status,
    this.resolutionNote,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.dataSource,
  });

  final String exceptionId;
  final String deliveryTaskId;
  final String businessScopeId;
  final String branchId;
  final BusinessDeliveryExceptionCategory category;
  final BusinessDeliveryExceptionSeverity severity;
  final String reason;
  final BusinessDeliveryExceptionStatus status;
  final String? resolutionNote;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BusinessCatalogProductDataSource dataSource;

  BusinessDeliveryException copyWith({
    BusinessDeliveryExceptionStatus? status,
    String? resolutionNote,
    bool clearResolutionNote = false,
    DateTime? resolvedAt,
    bool clearResolvedAt = false,
    DateTime? updatedAt,
  }) {
    return BusinessDeliveryException(
      exceptionId: exceptionId,
      deliveryTaskId: deliveryTaskId,
      businessScopeId: businessScopeId,
      branchId: branchId,
      category: category,
      severity: severity,
      reason: reason,
      status: status ?? this.status,
      resolutionNote: clearResolutionNote
          ? null
          : (resolutionNote ?? this.resolutionNote),
      resolvedAt:
          clearResolvedAt ? null : (resolvedAt ?? this.resolvedAt),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dataSource: dataSource,
    );
  }
}

class BusinessDeliveryExceptionCreateInput {
  const BusinessDeliveryExceptionCreateInput({
    required this.deliveryTaskId,
    required this.category,
    this.severity = BusinessDeliveryExceptionSeverity.medium,
    required this.reason,
  });

  final String deliveryTaskId;
  final BusinessDeliveryExceptionCategory category;
  final BusinessDeliveryExceptionSeverity severity;
  final String reason;
}
