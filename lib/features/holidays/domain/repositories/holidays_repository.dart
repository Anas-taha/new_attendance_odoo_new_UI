import 'package:hr_app_odoo/models/holiday_model.dart';

abstract class HolidaysRepository {
  Future<HolidaysModel?> getHolidays();

  /// Returns null when hr.leave search_read is unavailable.
  Future<List<Leaves>?> searchLeaves({List<int>? holidayStatusIds});
}
