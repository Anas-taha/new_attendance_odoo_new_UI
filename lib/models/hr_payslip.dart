class HrPayslip {
  final num? id;
  final String? number;
  final String? name;
  final String? state;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? basicWage;
  final double? grossWage;
  final double? netWage;

  HrPayslip({
    this.id,
    this.number,
    this.name,
    this.state,
    this.dateFrom,
    this.dateTo,
    this.basicWage,
    this.grossWage,
    this.netWage,
  });

  factory HrPayslip.fromOdoo(Map<String, dynamic> data) {
    return HrPayslip(
      id: data['id'],
      number: data['number'],
      name: data['name'],
      state: data['state'],
      dateFrom: data['date_from'] != null && data['date_from'] != false
          ? DateTime.tryParse(data['date_from'])
          : null,
      dateTo: data['date_to'] != null && data['date_to'] != false
          ? DateTime.tryParse(data['date_to'])
          : null,
      basicWage: _toDouble(data['basic_wage']),
      grossWage: _toDouble(data['gross_wage']),
      netWage: _toDouble(data['net_wage']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null || value == false) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'state': state,
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
      'basic_wage': basicWage,
      'gross_wage': grossWage,
      'net_wage': netWage,
    };
  }

  HrPayslip copyWith({
    num? id,
    String? number,
    String? name,
    String? state,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? basicWage,
    double? grossWage,
    double? netWage,
  }) {
    return HrPayslip(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      state: state ?? this.state,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      basicWage: basicWage ?? this.basicWage,
      grossWage: grossWage ?? this.grossWage,
      netWage: netWage ?? this.netWage,
    );
  }

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  String get statusDisplay {
    switch (state) {
      case 'draft':
        return 'Draft';
      case 'verify':
        return 'Verified';
      case 'done':
        return 'Paid';
      case 'cancel':
        return 'Cancelled';
      default:
        return state ?? 'Unknown';
    }
  }

  bool get isPaid => state == 'done';
  bool get isVerified => state == 'verify';
  bool get isDraft => state == 'draft';

  String get salaryDisplay =>
      basicWage != null ? basicWage!.toStringAsFixed(2) : 'N/A';

  String get dateRangeDisplay {
    if (dateFrom == null) return 'N/A';
    final start = dateFrom!.toLocal().toString().split(' ')[0];
    if (dateTo == null) return start;
    final end = dateTo!.toLocal().toString().split(' ')[0];
    return '$start to $end';
  }

  String get periodDisplay {
    if (dateFrom == null) return 'N/A';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dateFrom!.month - 1]} ${dateFrom!.year}';
  }
}
