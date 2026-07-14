class HrEmployee {
  String? status;
  Profile? profile;

  HrEmployee({this.status, this.profile});

  HrEmployee.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    profile = json['profile'] != null
        ? new Profile.fromJson(json['profile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
  int? id;
  String? name;
  String? jobTitle;
  String? department;
  int? departmentId;
  String? section;
  String? directManager;
  String? branch;
  String? workEmail;
  String? workPhone;
  String? mobilePhone;
  String? barcode;
  bool? hasImage;
  String? attendanceState;
  LastAttendance? lastAttendance;
  String? workLocation;

  Profile({
    this.id,
    this.name,
    this.jobTitle,
    this.department,
    this.departmentId,
    this.section,
    this.directManager,
    this.branch,
    this.workEmail,
    this.workPhone,
    this.mobilePhone,
    this.barcode,
    this.hasImage,
    this.attendanceState,
    this.lastAttendance,
    this.workLocation,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    jobTitle = json['job_title'];
    department = json['department'];
    departmentId = json['department_id'];
    section = json['section'];
    directManager = json['direct_manager'];
    branch = json['branch'];
    workEmail = json['work_email'];
    workPhone = json['work_phone'];
    mobilePhone = json['mobile_phone'];
    barcode = json['barcode'];
    hasImage = json['has_image'];
    attendanceState = json['attendance_state'];
    lastAttendance = json['last_attendance'] != null
        ? new LastAttendance.fromJson(json['last_attendance'])
        : null;
    workLocation = json['work_location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['job_title'] = this.jobTitle;
    data['department'] = this.department;
    data['department_id'] = this.departmentId;
    data['section'] = this.section;
    data['direct_manager'] = this.directManager;
    data['branch'] = this.branch;
    data['work_email'] = this.workEmail;
    data['work_phone'] = this.workPhone;
    data['mobile_phone'] = this.mobilePhone;
    data['barcode'] = this.barcode;
    data['has_image'] = this.hasImage;
    data['attendance_state'] = this.attendanceState;
    if (this.lastAttendance != null) {
      data['last_attendance'] = this.lastAttendance!.toJson();
    }
    data['work_location'] = this.workLocation;
    return data;
  }
}

class LastAttendance {
  String? checkIn;
  String? checkOut;

  LastAttendance({this.checkIn, this.checkOut});

  LastAttendance.fromJson(Map<String, dynamic> json) {
    checkIn = json['check_in'];
    checkOut = json['check_out'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['check_in'] = this.checkIn;
    data['check_out'] = this.checkOut;
    return data;
  }
}
// class HrEmployee {
//   final int id;
//   final String name;
//   final String? jobTitle;
//   final String? department;
//   final int? departmentId;
//   final String? section;
//   final String? directManager;
//   final String? branch;
//   final String? workEmail;
//   final String? workPhone;
//   final String? mobilePhone;
//   final String? barcode;
//   final bool hasImage;
//   final String? attendanceState;
//   final Map<String, dynamic>? lastAttendance;
//   final String? workLocation;

//   HrEmployee({
//     required this.id,
//     required this.name,
//     this.jobTitle,
//     this.department,
//     this.departmentId,
//     this.section,
//     this.directManager,
//     this.branch,
//     this.workEmail,
//     this.workPhone,
//     this.mobilePhone,
//     this.barcode,
//     this.hasImage = false,
//     this.attendanceState,
//     this.lastAttendance,
//     this.workLocation,
//   });

//   factory HrEmployee.fromJson(Map<String, dynamic> data) {
//     return HrEmployee(
//       id: data['id'] ?? 0,
//       name: data['name'] ?? '',
//       jobTitle: data['job_title'] != false ? data['job_title'] : null,
//       department: data['department'] != false ? data['department'] : null,
//       departmentId: data['department_id'] != false ? data['department_id'] : null,
//       section: data['section'] != false ? data['section'] : null,
//       directManager: data['direct_manager'] != false ? data['direct_manager'] : null,
//       branch: data['branch'] != false ? data['branch'] : null,
//       workEmail: data['work_email'] != false ? data['work_email'] : null,
//       workPhone: data['work_phone'] != false ? data['work_phone'] : null,
//       mobilePhone: data['mobile_phone'] != false ? data['mobile_phone'] : null,
//       barcode: data['barcode'] != false ? data['barcode'] : null,
//       hasImage: data['has_image'] ?? false,
//       attendanceState: data['attendance_state'] != false ? data['attendance_state'] : null,
//       lastAttendance: data['last_attendance'] != null && data['last_attendance'] != false
//           ? Map<String, dynamic>.from(data['last_attendance'])
//           : null,
//       workLocation: data['work_location'] != false ? data['work_location'] : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'job_title': jobTitle,
//       'department': department,
//       'department_id': departmentId,
//       'section': section,
//       'direct_manager': directManager,
//       'branch': branch,
//       'work_email': workEmail,
//       'work_phone': workPhone,
//       'mobile_phone': mobilePhone,
//       'barcode': barcode,
//       'has_image': hasImage,
//       'attendance_state': attendanceState,
//       'last_attendance': lastAttendance,
//       'work_location': workLocation,
//     };
//   }

//   HrEmployee copyWith({
//     int? id,
//     String? name,
//     String? jobTitle,
//     String? department,
//     int? departmentId,
//     String? section,
//     String? directManager,
//     String? branch,
//     String? workEmail,
//     String? workPhone,
//     String? mobilePhone,
//     String? barcode,
//     bool? hasImage,
//     String? attendanceState,
//     Map<String, dynamic>? lastAttendance,
//     String? workLocation,
//   }) {
//     return HrEmployee(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       jobTitle: jobTitle ?? this.jobTitle,
//       department: department ?? this.department,
//       departmentId: departmentId ?? this.departmentId,
//       section: section ?? this.section,
//       directManager: directManager ?? this.directManager,
//       branch: branch ?? this.branch,
//       workEmail: workEmail ?? this.workEmail,
//       workPhone: workPhone ?? this.workPhone,
//       mobilePhone: mobilePhone ?? this.mobilePhone,
//       barcode: barcode ?? this.barcode,
//       hasImage: hasImage ?? this.hasImage,
//       attendanceState: attendanceState ?? this.attendanceState,
//       lastAttendance: lastAttendance ?? this.lastAttendance,
//       workLocation: workLocation ?? this.workLocation,
//     );
//   }

//   // Helper getters للـ lastAttendance
//   DateTime? get checkIn {
//     final raw = lastAttendance?['check_in'];
//     return raw != null ? DateTime.tryParse(raw) : null;
//   }

//   DateTime? get checkOut {
//     final raw = lastAttendance?['check_out'];
//     return raw != null ? DateTime.tryParse(raw) : null;
//   }
// }
