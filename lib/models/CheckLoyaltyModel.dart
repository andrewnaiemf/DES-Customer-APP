class CheckLoyaltyModel {
  bool? status;
  int? code;
  CheckLoyaltyModelData? data;
  String? msg;

  CheckLoyaltyModel({this.status, this.code, this.data, this.msg});

  CheckLoyaltyModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    data = json['data'] != null ? new CheckLoyaltyModelData.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class CheckLoyaltyModelData {
  int? totalDiscount;

  CheckLoyaltyModelData({this.totalDiscount});

  CheckLoyaltyModelData.fromJson(Map<String, dynamic> json) {
    totalDiscount = json['total_discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_discount'] = this.totalDiscount;
    return data;
  }
}