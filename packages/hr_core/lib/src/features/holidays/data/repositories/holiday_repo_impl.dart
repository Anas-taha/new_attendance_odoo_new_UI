import 'dart:developer';

import 'package:hr_core/src/features/holidays/domain/repositories/holidays_repository.dart';
import 'package:hr_core/src/models/holiday_model.dart';
import 'package:hr_core/src/services/simple_hr_service.dart';

class HolidayRepositoryImpl implements HolidaysRepository {
  HolidayRepositoryImpl({SimpleHrService? hrService})
    : _hrService = hrService ?? SimpleHrService();

  final SimpleHrService _hrService;

  @override
  Future<HolidaysModel?> getHolidays() async {
    final result = await _hrService.getHolidays();
    log(name: 'feqwgfwgbveg', 'result: ${result.count}');
    if (result.status == 'success') {
      return result;
    }
    return null;
  }

  @override
  Future<List<Leaves>?> searchLeaves({List<int>? holidayStatusIds}) =>
      _hrService.searchLeavesFromApi(holidayStatusIds: holidayStatusIds);
}
