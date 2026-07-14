class CheckInModel {
  String? status;
  String? action;
  num? attendanceId;
  String? checkIn;
  String? checkOut;
  String? geofenceStatus;
  String? attendanceState;

  CheckInModel({
    this.status,
    this.action,
    this.attendanceId,
    this.checkIn,
    this.checkOut,
    this.geofenceStatus,
    this.attendanceState,
  });

  CheckInModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    action = json['action'];
    attendanceId = json['attendance_id'];
    checkIn = json['check_in'];
    checkOut = json['check_out'];
    geofenceStatus = json['geofence_status'];
    attendanceState = json['attendance_state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['action'] = this.action;
    data['attendance_id'] = this.attendanceId;
    data['check_in'] = this.checkIn;
    data['check_out'] = this.checkOut;
    data['geofence_status'] = this.geofenceStatus;
    data['attendance_state'] = this.attendanceState;
    return data;
  }
}
