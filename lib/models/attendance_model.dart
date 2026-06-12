class AttendanceSummaryModel {
  final AttendanceTotals? totals;
  final List<AttendanceWeek>? weeks;
  final String? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  AttendanceSummaryModel({
    this.totals,
    this.weeks,
    this.status,
    this.dateFrom,
    this.dateTo,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> data) {
    return AttendanceSummaryModel(
      totals: data['totals'] != null
          ? AttendanceTotals.fromJson(data['totals'])
          : null,
      weeks: data['weeks'] != null
          ? (data['weeks'] as List)
                .map((e) => AttendanceWeek.fromJson(e))
                .toList()
          : null,
      status: data['status'],
      dateFrom: data['date_from'] != null && data['date_from'] != false
          ? DateTime.tryParse(data['date_from'])
          : null,
      dateTo: data['date_to'] != null && data['date_to'] != false
          ? DateTime.tryParse(data['date_to'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totals': totals?.toJson(),
      'weeks': weeks?.map((e) => e.toJson()).toList(),
      'status': status,
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
    };
  }

  bool get isSuccess => status == 'success';
}

class AttendanceTotals {
  final int? lates;
  final int? earlyLeaves;
  final int? absences;
  final int? holidays;
  final int? present;

  AttendanceTotals({
    this.lates,
    this.earlyLeaves,
    this.absences,
    this.holidays,
    this.present,
  });

  factory AttendanceTotals.fromJson(Map<String, dynamic> data) {
    return AttendanceTotals(
      lates: data['lates'],
      earlyLeaves: data['early_leaves'],
      absences: data['absences'],
      holidays: data['holidays'],
      present: data['present'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lates': lates,
      'early_leaves': earlyLeaves,
      'absences': absences,
      'holidays': holidays,
      'present': present,
    };
  }
}

class AttendanceWeek {
  final int? weekNumber;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? lates;
  final int? earlyLeaves;
  final int? absences;
  final int? holidaysCount;
  final int? present;
  final List<dynamic>? holidays;

  AttendanceWeek({
    this.weekNumber,
    this.dateFrom,
    this.dateTo,
    this.lates,
    this.earlyLeaves,
    this.absences,
    this.holidaysCount,
    this.present,
    this.holidays,
  });

  factory AttendanceWeek.fromJson(Map<String, dynamic> data) {
    return AttendanceWeek(
      weekNumber: data['week_number'],
      dateFrom: data['date_from'] != null && data['date_from'] != false
          ? DateTime.tryParse(data['date_from'])
          : null,
      dateTo: data['date_to'] != null && data['date_to'] != false
          ? DateTime.tryParse(data['date_to'])
          : null,
      lates: data['lates'],
      earlyLeaves: data['early_leaves'],
      absences: data['absences'],
      holidaysCount: data['holidays_count'],
      present: data['present'],
      holidays: data['holidays'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_number': weekNumber,
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
      'lates': lates,
      'early_leaves': earlyLeaves,
      'absences': absences,
      'holidays_count': holidaysCount,
      'present': present,
      'holidays': holidays,
    };
  }

  /// Display label e.g. "Week 18"
  String get weekLabel => 'Week ${weekNumber ?? '-'}';

  /// Formatted date range e.g. "2026-05-01 to 2026-05-03"
  String get dateRangeDisplay {
    if (dateFrom == null) return 'N/A';
    final start = dateFrom!.toLocal().toString().split(' ')[0];
    if (dateTo == null) return start;
    final end = dateTo!.toLocal().toString().split(' ')[0];
    return '$start to $end';
  }
}
