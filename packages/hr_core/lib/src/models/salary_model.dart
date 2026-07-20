class SalaryModel {
  String? status;
  num? count;
  List<Payslips>? payslips;

  SalaryModel({this.status, this.count, this.payslips});

  SalaryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    if (json['payslips'] != null) {
      payslips = <Payslips>[];
      json['payslips'].forEach((v) {
        payslips!.add(new Payslips.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    if (this.payslips != null) {
      data['payslips'] = this.payslips!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Payslips {
  num? id;
  String? number;
  String? name;
  String? dateFrom;
  String? dateTo;
  String? state;
  num? basicSalary;
  num? allowances;
  num? deductions;
  num? netSalary;
  List<Lines>? lines;

  Payslips({
    this.id,
    this.number,
    this.name,
    this.dateFrom,
    this.dateTo,
    this.state,
    this.basicSalary,
    this.allowances,
    this.deductions,
    this.netSalary,
    this.lines,
  });

  Payslips.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    name = json['name'];
    dateFrom = json['date_from'];
    dateTo = json['date_to'];
    state = json['state'];
    basicSalary = _parseAmount(json['basic_salary']);
    allowances = _parseAmount(json['allowances']);
    deductions = _parseAmount(json['deductions']);
    netSalary = _parseAmount(json['net_salary']);
    if (json['lines'] != null) {
      lines = <Lines>[];
      json['lines'].forEach((v) {
        lines!.add(Lines.fromJson(v));
      });
    }
  }

  static num _parseAmount(dynamic value) {
    if (value == null || value == 'null' || value == 'snull') return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['number'] = this.number;
    data['name'] = this.name;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['state'] = this.state;
    data['basic_salary'] = this.basicSalary;
    data['allowances'] = this.allowances;
    data['deductions'] = this.deductions;
    data['net_salary'] = this.netSalary;
    if (this.lines != null) {
      data['lines'] = this.lines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Lines {
  String? name;
  String? code;
  String? category;
  num? total;

  Lines({this.name, this.code, this.category, this.total});

  Lines.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    category = json['category'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['code'] = this.code;
    data['category'] = this.category;
    data['total'] = this.total;
    return data;
  }
}
