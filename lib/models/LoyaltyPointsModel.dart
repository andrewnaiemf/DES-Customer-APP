class LoyaltyPointsModel {
  bool? status;
  int? code;
  List<LoyaltyPointsModelData>? data;
  String? msg;

  LoyaltyPointsModel({this.status, this.code, this.data, this.msg});

  LoyaltyPointsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    if (json['data'] != null) {
      data = <LoyaltyPointsModelData>[];
      json['data'].forEach((v) {
        data!.add(new LoyaltyPointsModelData.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class LoyaltyPointsModelData {
  List<Points>? points;
  String? total;

  LoyaltyPointsModelData({this.points, this.total});

  LoyaltyPointsModelData.fromJson(Map<String, dynamic> json) {
    if (json['points'] != null) {
      points = <Points>[];
      json['points'].forEach((v) {
        points!.add(new Points.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.points != null) {
      data['points'] = this.points!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    return data;
  }
}

class Points {
  int? id;
  int? receiptId;
  int? customerId;
  int? points;
  String? createdAt;
  String? updatedAt;
  String? expireAt;
  bool? isExpired;

  Points(
      {this.id,
        this.receiptId,
        this.customerId,
        this.points,
        this.createdAt,
        this.updatedAt,
        this.expireAt,
        this.isExpired});

  Points.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    receiptId = json['receipt_id'];
    customerId = json['customer_id'];
    points = json['points'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    expireAt = json['expire_at'];
    isExpired = json['is_expired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['receipt_id'] = this.receiptId;
    data['customer_id'] = this.customerId;
    data['points'] = this.points;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['expire_at'] = this.expireAt;
    data['is_expired'] = this.isExpired;
    return data;
  }
}