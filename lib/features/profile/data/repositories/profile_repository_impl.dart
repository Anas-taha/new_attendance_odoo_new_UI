import 'dart:developer';

import 'package:hr_app_odoo/features/profile/domain/repositories/profile_repository.dart';
import 'package:hr_app_odoo/models/hr_employee.dart';
import 'package:hr_app_odoo/services/simple_hr_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({SimpleHrService? hrService})
    : _hrService = hrService ?? SimpleHrService();

  final SimpleHrService _hrService;

  @override
  Future<HrEmployee?> getProfileData() async {
    final result = await _hrService.getProfile();
    log(name: 'feqwgfwgbveg', 'result: $result');
    if (result.status == 'success') {
      return result;
    }
    return null;
  }
}
// {"jsonrpc": "2.0",
//  "id": null,
//   "result": {
//     "totals": {"lates": 0, "early_leaves": 0, "absences": 10, "holidays": 0, "present": 0},
//      "weeks": [
//       {"week_number": 23,
//        "date_from": "2026-06-01",
//         "date_to": "2026-06-07",
//          "lates": 0,
//           "early_leaves": 0,
//            "absences": 5,
//             "holidays_count": 0,
//              "present": 0,
//               "holidays": []
//               },
//                {"week_number": 24,
//                 "date_from": "2026-06-08", "date_to": "2026-06-13", "lates": 0, "early_leaves": 0, "absences": 5, "holidays_count": 0, "present": 0, "holidays": []}],
// "status": "success",
// "date_from": "2026-06-01",
// "date_to": "2026-06-13"}}