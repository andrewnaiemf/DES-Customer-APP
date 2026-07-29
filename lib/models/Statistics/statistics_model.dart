class StatisticModel {
  StatisticModelData? data;
  StatisticModel({this.data});
  StatisticModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new StatisticModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class StatisticModelData {
  List<Year>? year;

  StatisticModelData({this.year});

  StatisticModelData.fromJson(Map<String, dynamic> json) {
    if (json['Year'] != null) {
      year = <Year>[];
      json['Year'].forEach((v) {
        year!.add(new Year.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.year != null) {
      data['Year'] = this.year!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Year {
  num? totalPaidAmount;
  num? totalDueAmount;
  // num? totalAmount;

  Year({this.totalPaidAmount, this.totalDueAmount});

  Year.fromJson(Map<String, dynamic> json) {
    totalPaidAmount = json['total_paid_amount'];
    totalDueAmount = json['total_due_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_paid_amount'] = this.totalPaidAmount;
    data['total_due_amount'] = this.totalDueAmount;
    return data;
  }
}