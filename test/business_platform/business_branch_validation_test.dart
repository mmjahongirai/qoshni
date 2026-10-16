import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_branch.dart';
import 'package:qoshni/features/business_platform/domain/business_branch_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_branch_validation.dart';

void main() {
  test('valid branch input passes', () {
    const input = BusinessBranchInput(
      name: 'Center',
      city: 'Tashkent',
      addressLine: 'Street 1',
      contactPhone: '+998901234567',
      status: BusinessBranchLifecycleStatus.active,
      weeklySchedule: [
        BranchDaySchedule(
          weekday: 1,
          isClosed: false,
          openTime: '09:00',
          closeTime: '18:00',
        ),
      ],
    );

    final result = validateBusinessBranchInput(
      input,
      nameRequired: () => 'name',
      cityRequired: () => 'city',
      addressRequired: () => 'addr',
      phoneInvalid: () => 'phone',
      timeInvalid: () => 'time',
      timeOrderInvalid: () => 'order',
      coordinateInvalid: () => 'coord',
    );

    expect(result.isValid, isTrue);
  });

  test('empty name and invalid hours fail', () {
    const input = BusinessBranchInput(
      name: '',
      city: '',
      addressLine: '',
      contactPhone: 'abc',
      status: BusinessBranchLifecycleStatus.active,
      weeklySchedule: [
        BranchDaySchedule(
          weekday: 1,
          isClosed: false,
          openTime: '18:00',
          closeTime: '09:00',
        ),
      ],
    );

    final result = validateBusinessBranchInput(
      input,
      nameRequired: () => 'name',
      cityRequired: () => 'city',
      addressRequired: () => 'addr',
      phoneInvalid: () => 'phone',
      timeInvalid: () => 'time',
      timeOrderInvalid: () => 'order',
      coordinateInvalid: () => 'coord',
    );

    expect(result.isValid, isFalse);
    expect(result.nameError, isNotNull);
    expect(result.phoneError, isNotNull);
    expect(result.scheduleErrorsByWeekday[1], 'order');
  });

  test('closed day skips time validation', () {
    const input = BusinessBranchInput(
      name: 'X',
      city: 'Y',
      addressLine: 'Z',
      status: BusinessBranchLifecycleStatus.active,
      weeklySchedule: [
        BranchDaySchedule(weekday: 1, isClosed: true),
      ],
    );

    final result = validateBusinessBranchInput(
      input,
      nameRequired: () => 'name',
      cityRequired: () => 'city',
      addressRequired: () => 'addr',
      phoneInvalid: () => 'phone',
      timeInvalid: () => 'time',
      timeOrderInvalid: () => 'order',
      coordinateInvalid: () => 'coord',
    );

    expect(result.isValid, isTrue);
  });
}
