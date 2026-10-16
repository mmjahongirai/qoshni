import 'package:qoshni/features/business_platform/domain/business_branch.dart';

class BusinessBranchValidationResult {
  const BusinessBranchValidationResult({
    required this.isValid,
    this.nameError,
    this.cityError,
    this.addressError,
    this.phoneError,
    this.scheduleErrorsByWeekday = const {},
    this.latitudeError,
    this.longitudeError,
  });

  final bool isValid;
  final String? nameError;
  final String? cityError;
  final String? addressError;
  final String? phoneError;
  final Map<int, String> scheduleErrorsByWeekday;
  final String? latitudeError;
  final String? longitudeError;
}

BusinessBranchValidationResult validateBusinessBranchInput(
  BusinessBranchInput input, {
  required String Function() nameRequired,
  required String Function() cityRequired,
  required String Function() addressRequired,
  required String Function() phoneInvalid,
  required String Function() timeInvalid,
  required String Function() timeOrderInvalid,
  required String Function() coordinateInvalid,
}) {
  String? nameError;
  String? cityError;
  String? addressError;
  String? phoneError;
  final scheduleErrors = <int, String>{};
  String? latitudeError;
  String? longitudeError;

  if (input.name.trim().isEmpty) {
    nameError = nameRequired();
  }
  if (input.city.trim().isEmpty) {
    cityError = cityRequired();
  }
  if (input.addressLine.trim().isEmpty) {
    addressError = addressRequired();
  }

  final phone = input.contactPhone?.trim();
  if (phone != null && phone.isNotEmpty && !_looksLikePhone(phone)) {
    phoneError = phoneInvalid();
  }

  for (final day in input.weeklySchedule) {
    if (day.isClosed) {
      continue;
    }
    final open = day.openTime?.trim();
    final close = day.closeTime?.trim();
    if (open == null ||
        open.isEmpty ||
        close == null ||
        close.isEmpty ||
        !_isValidTime(open) ||
        !_isValidTime(close)) {
      scheduleErrors[day.weekday] = timeInvalid();
      continue;
    }
    if (_minutesFromTime(open) >= _minutesFromTime(close)) {
      scheduleErrors[day.weekday] = timeOrderInvalid();
    }
  }

  if (input.latitude != null &&
      (input.latitude!.abs() > 90 || input.latitude!.isNaN)) {
    latitudeError = coordinateInvalid();
  }
  if (input.longitude != null &&
      (input.longitude!.abs() > 180 || input.longitude!.isNaN)) {
    longitudeError = coordinateInvalid();
  }

  return BusinessBranchValidationResult(
    isValid: nameError == null &&
        cityError == null &&
        addressError == null &&
        phoneError == null &&
        scheduleErrors.isEmpty &&
        latitudeError == null &&
        longitudeError == null,
    nameError: nameError,
    cityError: cityError,
    addressError: addressError,
    phoneError: phoneError,
    scheduleErrorsByWeekday: scheduleErrors,
    latitudeError: latitudeError,
    longitudeError: longitudeError,
  );
}

bool _looksLikePhone(String value) {
  final normalized = value.replaceAll(RegExp(r'[\s\-()]'), '');
  return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(normalized);
}

bool _isValidTime(String value) {
  final match = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(value);
  return match != null;
}

int _minutesFromTime(String value) {
  final parts = value.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
