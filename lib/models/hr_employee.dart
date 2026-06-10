class HrEmployee {
  final int id;
  final String name;
  final String? jobTitle;
  final List<dynamic>? departmentId;
  final String? workEmail;
  final String? workPhone;
  final String? barcode;
  final String? attendanceState;
  final List<dynamic>? parentId;
  final String? workLocationId;
  // final String? imageUrl;
  // final DateTime? hireDate;
  // final String? employeeId;
  // final bool isActive;

  HrEmployee({
    required this.id,
    required this.name,
    this.workEmail,
    this.workPhone,
    this.jobTitle,
    this.departmentId,
    this.workLocationId,
    // this.imageUrl,
    // this.hireDate,
    // this.employeeId,
    this.parentId,
    // this.isActive = true,
    this.barcode,
    this.attendanceState,
  });

  factory HrEmployee.fromOdoo(Map<String, dynamic> data) {
    return HrEmployee(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      workEmail: data['work_email'] != false ? data['work_email'] : null,
      workPhone: data['work_phone'] != false ? data['work_phone'] : null,
      jobTitle: data['job_title'] != false ? data['job_title'] : null,
      departmentId:
          data['department_id'] != false && data['department_id'] != null
          ? List<dynamic>.from(data['department_id'])
          : null,
      workLocationId:
          data['work_location_id'] != false && data['work_location_id'] != null
          ? data['work_location_id'][1]
          : null,
      // imageUrl: data['image_128'],
      // hireDate: data['hire_date'] != null
      //     ? DateTime.tryParse(data['hire_date'])
      //     : null,
      // employeeId: data['employee_id'],
      // isActive: data['active'] ?? true,
      barcode: data['barcode'] != false ? data['barcode'] : null,
      parentId: data['parent_id'] != false
          ? List<String>.from(data['parent_id'])
          : null,
      attendanceState: data['attendance_state'] != false
          ? data['attendance_state']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'work_email': workEmail,
      'work_phone': workPhone,
      'job_title': jobTitle,
      'department': departmentId,
      'work_location': workLocationId,
      // 'image_url': imageUrl,
      // 'hire_date': hireDate?.toIso8601String(),
      // 'employee_id': employeeId,
      // 'active': isActive,
      'barcode': barcode,
      'attendance_state': attendanceState,
      'parent_id': parentId,
    };
  }

  HrEmployee copyWith({
    int? id,
    String? name,
    String? workEmail,
    String? workPhone,
    String? jobTitle,
    List<dynamic>? departmentId,
    String? workLocationId,
    String? imageUrl,
    DateTime? hireDate,
    String? employeeId,
    bool? isActive,
    String? barcode,
    String? attendanceState,
    List<dynamic>? parentId,
  }) {
    return HrEmployee(
      id: id ?? this.id,
      name: name ?? this.name,
      workEmail: workEmail ?? this.workEmail,
      workPhone: workPhone ?? this.workPhone,
      jobTitle: jobTitle ?? this.jobTitle,
      departmentId: departmentId ?? this.departmentId,
      workLocationId: workLocationId ?? this.workLocationId,
      // imageUrl: imageUrl ?? this.imageUrl,
      // hireDate: hireDate ?? this.hireDate,
      // employeeId: employeeId ?? this.employeeId,
      // isActive: isActive ?? this.isActive,
      barcode: barcode ?? this.barcode,
      attendanceState: attendanceState ?? this.attendanceState,
      parentId: parentId ?? this.parentId,
    );
  }
}
