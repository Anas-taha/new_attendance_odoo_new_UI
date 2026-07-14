class HolidaysModel {
  String? status;
  num? count;
  List<Leaves>? leaves;

  HolidaysModel({this.status, this.count, this.leaves});

  HolidaysModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    if (json['leaves'] != null) {
      leaves = <Leaves>[];
      json['leaves'].forEach((v) {
        leaves!.add(new Leaves.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    if (this.leaves != null) {
      data['leaves'] = this.leaves!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Leaves {
  num? id;
  String? title;
  num? leaveTypeId;
  String? dateFrom;
  String? dateTo;
  num? numberOfDays;
  String? holidayStatus;
  String? holidayReason;
  String? rejectedReason;

  Leaves({
    this.id,
    this.title,
    this.leaveTypeId,
    this.dateFrom,
    this.dateTo,
    this.numberOfDays,
    this.holidayStatus,
    this.holidayReason,
    this.rejectedReason,
  });

  Leaves.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    leaveTypeId = json['leave_type_id'];
    dateFrom = json['date_from'];
    dateTo = json['date_to'];
    numberOfDays = json['number_of_days'];
    holidayStatus = json['holiday_status'];
    holidayReason = json['holiday_reason'];
    rejectedReason = json['rejected_reason'];
  }

  /// Maps `hr.leave` search_read rows (Postman jsonrpc fields).
  factory Leaves.fromSearchRead(Map<String, dynamic> json) {
    final statusField = json['holiday_status_id'];
    num? typeId;
    String? typeName;
    if (statusField is List && statusField.isNotEmpty) {
      typeId = statusField[0] as num?;
      if (statusField.length > 1) {
        typeName = statusField[1]?.toString();
      }
    }

    return Leaves(
      id: json['id'],
      title: typeName ?? json['name']?.toString(),
      leaveTypeId: typeId,
      dateFrom: _formatSearchReadDate(json['date_from']),
      dateTo: _formatSearchReadDate(json['date_to']),
      numberOfDays: json['number_of_days'],
      holidayStatus: _mapOdooLeaveState(json['state']),
      holidayReason: json['name']?.toString(),
    );
  }

  static String? _formatSearchReadDate(dynamic raw) {
    if (raw == null || raw == false) {
      return null;
    }
    final value = raw.toString();
    final parsed = DateTime.tryParse(value.replaceFirst(' ', 'T'));
    if (parsed == null) {
      return value;
    }
    return '${parsed.year}-'
        '${parsed.month.toString().padLeft(2, '0')}-'
        '${parsed.day.toString().padLeft(2, '0')}';
  }

  static String? _mapOdooLeaveState(dynamic state) {
    switch (state?.toString()) {
      case 'validate':
        return 'approved';
      case 'refuse':
        return 'rejected';
      case 'confirm':
        return 'pending';
      case 'cancel':
        return 'cancelled';
      case 'draft':
        return 'draft';
      default:
        return state?.toString();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['leave_type_id'] = this.leaveTypeId;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['number_of_days'] = this.numberOfDays;
    data['holiday_status'] = this.holidayStatus;
    data['holiday_reason'] = this.holidayReason;
    data['rejected_reason'] = this.rejectedReason;
    return data;
  }
}
