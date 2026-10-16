/// JSON DTOs aligned with backend owner onboarding schemas.
library;

class OwnerApplicationViewDto {
  const OwnerApplicationViewDto({
    required this.applicationId,
    this.legalBusinessName,
    this.tradeDisplayName,
    this.serviceCategory,
    required this.registrationJurisdiction,
    this.registrationIdentifier,
    this.taxIdentifier,
    this.businessContactEmail,
    required this.verificationStatus,
    this.rejectionReasonCode,
    this.submittedAt,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String applicationId;
  final String? legalBusinessName;
  final String? tradeDisplayName;
  final String? serviceCategory;
  final String registrationJurisdiction;
  final String? registrationIdentifier;
  final String? taxIdentifier;
  final String? businessContactEmail;
  final String verificationStatus;
  final String? rejectionReasonCode;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDraft => verificationStatus == 'draft';

  factory OwnerApplicationViewDto.fromJson(Map<String, dynamic> json) {
    return OwnerApplicationViewDto(
      applicationId: json['application_id'] as String,
      legalBusinessName: json['legal_business_name'] as String?,
      tradeDisplayName: json['trade_display_name'] as String?,
      serviceCategory: json['service_category'] as String?,
      registrationJurisdiction: json['registration_jurisdiction'] as String,
      registrationIdentifier: json['registration_identifier'] as String?,
      taxIdentifier: json['tax_identifier'] as String?,
      businessContactEmail: json['business_contact_email'] as String?,
      verificationStatus: json['verification_status'] as String,
      rejectionReasonCode: json['rejection_reason_code'] as String?,
      submittedAt: _parseDate(json['submitted_at']),
      reviewedAt: _parseDate(json['reviewed_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class OnboardingVerificationStatusViewDto {
  const OnboardingVerificationStatusViewDto({
    required this.applicationId,
    required this.verificationStatus,
    this.rejectionReasonCode,
    this.submittedAt,
    this.reviewedAt,
    required this.updatedAt,
  });

  final String applicationId;
  final String verificationStatus;
  final String? rejectionReasonCode;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final DateTime updatedAt;

  factory OnboardingVerificationStatusViewDto.fromJson(Map<String, dynamic> json) {
    return OnboardingVerificationStatusViewDto(
      applicationId: json['application_id'] as String,
      verificationStatus: json['verification_status'] as String,
      rejectionReasonCode: json['rejection_reason_code'] as String?,
      submittedAt: _parseDate(json['submitted_at']),
      reviewedAt: _parseDate(json['reviewed_at']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class OwnerDocumentViewDto {
  const OwnerDocumentViewDto({
    required this.documentId,
    required this.applicationId,
    required this.documentType,
    required this.lifecycleState,
    required this.createdAt,
    required this.updatedAt,
  });

  final String documentId;
  final String applicationId;
  final String documentType;
  final String lifecycleState;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory OwnerDocumentViewDto.fromJson(Map<String, dynamic> json) {
    return OwnerDocumentViewDto(
      documentId: json['document_id'] as String,
      applicationId: json['application_id'] as String,
      documentType: json['document_type'] as String,
      lifecycleState: json['lifecycle_state'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class OnboardingApplicationCreateRequestDto {
  const OnboardingApplicationCreateRequestDto({
    this.legalBusinessName,
    this.tradeDisplayName,
    this.serviceCategory,
    this.registrationJurisdiction,
  });

  final String? legalBusinessName;
  final String? tradeDisplayName;
  final String? serviceCategory;
  final String? registrationJurisdiction;

  Map<String, dynamic> toJson() {
    return {
      if (legalBusinessName != null) 'legal_business_name': legalBusinessName,
      if (tradeDisplayName != null) 'trade_display_name': tradeDisplayName,
      if (serviceCategory != null) 'service_category': serviceCategory,
      if (registrationJurisdiction != null)
        'registration_jurisdiction': registrationJurisdiction,
    };
  }
}

class OnboardingApplicationDraftUpdateRequestDto {
  const OnboardingApplicationDraftUpdateRequestDto({
    this.legalBusinessName,
    this.tradeDisplayName,
    this.serviceCategory,
    this.registrationJurisdiction,
    this.registrationIdentifier,
    this.taxIdentifier,
    this.businessContactEmail,
    this.clearLegalBusinessName = false,
    this.clearTradeDisplayName = false,
    this.clearRegistrationIdentifier = false,
    this.clearTaxIdentifier = false,
    this.clearBusinessContactEmail = false,
  });

  final String? legalBusinessName;
  final String? tradeDisplayName;
  final String? serviceCategory;
  final String? registrationJurisdiction;
  final String? registrationIdentifier;
  final String? taxIdentifier;
  final String? businessContactEmail;
  final bool clearLegalBusinessName;
  final bool clearTradeDisplayName;
  final bool clearRegistrationIdentifier;
  final bool clearTaxIdentifier;
  final bool clearBusinessContactEmail;

  Map<String, dynamic> toJson() {
    return {
      if (legalBusinessName != null) 'legal_business_name': legalBusinessName,
      if (tradeDisplayName != null) 'trade_display_name': tradeDisplayName,
      if (serviceCategory != null) 'service_category': serviceCategory,
      if (registrationJurisdiction != null)
        'registration_jurisdiction': registrationJurisdiction,
      if (registrationIdentifier != null)
        'registration_identifier': registrationIdentifier,
      if (taxIdentifier != null) 'tax_identifier': taxIdentifier,
      if (businessContactEmail != null)
        'business_contact_email': businessContactEmail,
      if (clearLegalBusinessName) 'clear_legal_business_name': true,
      if (clearTradeDisplayName) 'clear_trade_display_name': true,
      if (clearRegistrationIdentifier) 'clear_registration_identifier': true,
      if (clearTaxIdentifier) 'clear_tax_identifier': true,
      if (clearBusinessContactEmail) 'clear_business_contact_email': true,
    };
  }
}

class RegisterOnboardingDocumentRequestDto {
  const RegisterOnboardingDocumentRequestDto({
    required this.documentType,
    this.declaredContentType,
  });

  final String documentType;
  final String? declaredContentType;

  Map<String, dynamic> toJson() {
    return {
      'document_type': documentType,
      if (declaredContentType != null)
        'declared_content_type': declaredContentType,
    };
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String);
}

/// Backend-supported service categories.
abstract final class OnboardingServiceCategories {
  static const groceries = 'groceries';
  static const restaurants = 'restaurants';
  static const pharmacy = 'pharmacy';
  static const shops = 'shops';
  static const masters = 'masters';
  static const rent = 'rent';

  static const all = [
    groceries,
    restaurants,
    pharmacy,
    shops,
    masters,
    rent,
  ];
}

/// Backend `BusinessOnboardingDocumentType` values.
abstract final class OnboardingDocumentTypes {
  static const registrationCertificate = 'registration_certificate';
  static const taxRegistration = 'tax_registration';
  static const authorizedRepresentativeId = 'authorized_representative_id';
  static const otherSupporting = 'other_supporting';

  static const all = [
    registrationCertificate,
    taxRegistration,
    authorizedRepresentativeId,
    otherSupporting,
  ];
}

const onboardingMaxUploadBytes = 10 * 1024 * 1024;
