import 'package:hr_app_odoo/models/holiday_model.dart';

abstract class HolidaysRepository {
  Future<HolidaysModel?> getHolidays();
}
