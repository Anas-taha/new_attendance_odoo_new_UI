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
