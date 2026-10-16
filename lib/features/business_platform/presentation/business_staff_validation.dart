import 'package:qoshni/features/business_platform/domain/business_staff_member.dart';
import 'package:qoshni/features/business_platform/domain/business_staff_role.dart';

class BusinessStaffValidationResult {
  const BusinessStaffValidationResult({
    required this.isValid,
    this.firstNameError,
    this.phoneError,
    this.emailError,
    this.roleError,
    this.branchError,
  });

  final bool isValid;
  final String? firstNameError;
  final String? phoneError;
  final String? emailError;
  final String? roleError;
  final String? branchError;
}

BusinessStaffValidationResult validateBusinessStaffInput(
  BusinessStaffMemberInput input, {
  required String Function() firstNameRequired,
  required String Function() phoneInvalid,
  required String Function() emailInvalid,
  required String Function() roleNotAssignable,
  required String Function() branchRequired,
}) {
  String? firstNameError;
  String? phoneError;
  String? emailError;
  String? roleError;
  String? branchError;

  if (input.firstName.trim().isEmpty) {
    firstNameError = firstNameRequired();
  }

  final phone = input.contactPhone.trim();
  if (phone.isEmpty || !_looksLikePhone(phone)) {
    phoneError = phoneInvalid();
  }

  final email = input.contactEmail?.trim();
  if (email != null && email.isNotEmpty && !_looksLikeEmail(email)) {
    emailError = emailInvalid();
  }

  if (!isAssignableBusinessStaffRole(input.role)) {
    roleError = roleNotAssignable();
  }

  if (input.assignedBranchIds.isEmpty) {
    branchError = branchRequired();
  }

  return BusinessStaffValidationResult(
    isValid: firstNameError == null &&
        phoneError == null &&
        emailError == null &&
        roleError == null &&
        branchError == null,
    firstNameError: firstNameError,
    phoneError: phoneError,
    emailError: emailError,
    roleError: roleError,
    branchError: branchError,
  );
}

bool _looksLikePhone(String value) {
  final normalized = value.replaceAll(RegExp(r'[\s\-()]'), '');
  return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(normalized);
}

bool _looksLikeEmail(String value) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
}
