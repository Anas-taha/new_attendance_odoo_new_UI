class AttendanceModel {
  num? id;
  String? checkIn;
  String? checkOut;
  num? workedHours;
  num? inLatitude;
  num? inLongitude;
  String? inAddress;
  String? geofenceStatus;
  num? distanceFromLocation;

  AttendanceModel({
    this.id,
    this.checkIn,
    this.checkOut,
    this.workedHours,
    this.inLatitude,
    this.inLongitude,
    this.inAddress,
    this.geofenceStatus,
    this.distanceFromLocation,
  });

  AttendanceModel.fromOdoo(Map<String, dynamic> json) {
    id = json['id'];
    checkIn = json['check_in'];
    checkOut = json['check_out'];
    workedHours = json['worked_hours'];
    inLatitude = json['in_latitude'];
    inLongitude = json['in_longitude'];
    inAddress = json['in_address'] != false ? json['in_address'] : null;
    geofenceStatus = json['geofence_status'];
    distanceFromLocation = json['distance_from_location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['check_in'] = this.checkIn;
    data['check_out'] = this.checkOut;
    data['worked_hours'] = this.workedHours;
    data['in_latitude'] = this.inLatitude;
    data['in_longitude'] = this.inLongitude;
    data['in_address'] = this.inAddress;
    data['geofence_status'] = this.geofenceStatus;
    data['distance_from_location'] = this.distanceFromLocation;
    return data;
  }
}
