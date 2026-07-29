class LoginModel {
  bool? status;
  int? code;
  LoginModelData? data;
  String? msg;

  LoginModel({this.status, this.code, this.data, this.msg});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    data = json['data'] != null ? new LoginModelData.fromJson(json['data']) : null;
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

class LoginModelData {
  User? user;
  String? token;

  LoginModelData({this.user, this.token});

  LoginModelData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class User {
  int? id;
  List<String>? deviceToken;
  String? locale;
  String? name;
  String? organization;
  String? email;
  String? phoneNumber;
  String? taxNumber;
  String? status;
  Null? rememberToken;
  String? createdAt;
  String? updatedAt;
  int? closingBalance;
  int? overdue;
  int? totalInvoicesCount;
  double? totalInvoicesAmount;
  int? totalOutStanding;
  int? totalPaid;
  List<Branches>? branches;
  ShippingAddress? shippingAddress;
  BillingAddress? billingAddress;

  User(
      {this.id,
        this.deviceToken,
        this.locale,
        this.name,
        this.organization,
        this.email,
        this.phoneNumber,
        this.taxNumber,
        this.status,
        this.rememberToken,
        this.createdAt,
        this.updatedAt,
        this.closingBalance,
        this.overdue,
        this.totalInvoicesCount,
        this.totalInvoicesAmount,
        this.totalOutStanding,
        this.totalPaid,
        this.branches,
        this.shippingAddress,
        this.billingAddress});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceToken = json['device_token'].cast<String>();
    locale = json['locale'];
    name = json['name'];
    organization = json['organization'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    taxNumber = json['tax_number'];
    status = json['status'];
    rememberToken = json['remember_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    closingBalance = json['closing_balance'];
    overdue = json['overdue'];
    totalInvoicesCount = json['total_invoices_count'];
    totalInvoicesAmount = json['total_invoices_amount'];
    totalOutStanding = json['total_out_standing'];
    totalPaid = json['total_paid'];
    if (json['branches'] != null) {
      branches = <Branches>[];
      json['branches'].forEach((v) {
        branches!.add(new Branches.fromJson(v));
      });
    }
    shippingAddress = json['shipping_address'] != null
        ? new ShippingAddress.fromJson(json['shipping_address'])
        : null;
    billingAddress = json['billing_address'] != null
        ? new BillingAddress.fromJson(json['billing_address'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['device_token'] = this.deviceToken;
    data['locale'] = this.locale;
    data['name'] = this.name;
    data['organization'] = this.organization;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['tax_number'] = this.taxNumber;
    data['status'] = this.status;
    data['remember_token'] = this.rememberToken;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['closing_balance'] = this.closingBalance;
    data['overdue'] = this.overdue;
    data['total_invoices_count'] = this.totalInvoicesCount;
    data['total_invoices_amount'] = this.totalInvoicesAmount;
    data['total_out_standing'] = this.totalOutStanding;
    data['total_paid'] = this.totalPaid;
    if (this.branches != null) {
      data['branches'] = this.branches!.map((v) => v.toJson()).toList();
    }
    if (this.shippingAddress != null) {
      data['shipping_address'] = this.shippingAddress!.toJson();
    }
    if (this.billingAddress != null) {
      data['billing_address'] = this.billingAddress!.toJson();
    }
    return data;
  }
}

class Branches {
  int? id;
  List<String>? deviceToken;
  String? locale;
  String? name;
  String? organization;
  String? email;
  String? phoneNumber;
  String? taxNumber;
  String? status;
  String? createdAt;
  String? updatedAt;

  Branches(
      {this.id,
        this.deviceToken,
        this.locale,
        this.name,
        this.organization,
        this.email,
        this.phoneNumber,
        this.taxNumber,
        this.status,
        this.createdAt,
        this.updatedAt});

  Branches.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceToken = json['device_token'].cast<String>();
    locale = json['locale'];
    name = json['name'];
    organization = json['organization'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    taxNumber = json['tax_number'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['device_token'] = this.deviceToken;
    data['locale'] = this.locale;
    data['name'] = this.name;
    data['organization'] = this.organization;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['tax_number'] = this.taxNumber;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ShippingAddress {
  int? id;
  int? contactId;
  Null? isDefault;
  String? shippingAddress;
  String? shippingCity;
  String? shippingState;
  String? shippingZip;
  Null? shippingCountry;
  String? shippingBuildingNumber;
  String? createdAt;
  String? updatedAt;

  ShippingAddress(
      {this.id,
        this.contactId,
        this.isDefault,
        this.shippingAddress,
        this.shippingCity,
        this.shippingState,
        this.shippingZip,
        this.shippingCountry,
        this.shippingBuildingNumber,
        this.createdAt,
        this.updatedAt});

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    contactId = json['contact_id'];
    isDefault = json['is_default'];
    shippingAddress = json['shipping_address'];
    shippingCity = json['shipping_city'];
    shippingState = json['shipping_state'];
    shippingZip = json['shipping_zip'];
    shippingCountry = json['shipping_country'];
    shippingBuildingNumber = json['shipping_building_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['contact_id'] = this.contactId;
    data['is_default'] = this.isDefault;
    data['shipping_address'] = this.shippingAddress;
    data['shipping_city'] = this.shippingCity;
    data['shipping_state'] = this.shippingState;
    data['shipping_zip'] = this.shippingZip;
    data['shipping_country'] = this.shippingCountry;
    data['shipping_building_number'] = this.shippingBuildingNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class BillingAddress {
  int? id;
  int? contactId;
  Null? isDefault;
  String? billingAddress;
  String? billingCity;
  String? billingState;
  String? billingZip;
  Null? billingCountry;
  String? buildingNumber;
  String? createdAt;
  String? updatedAt;

  BillingAddress(
      {this.id,
        this.contactId,
        this.isDefault,
        this.billingAddress,
        this.billingCity,
        this.billingState,
        this.billingZip,
        this.billingCountry,
        this.buildingNumber,
        this.createdAt,
        this.updatedAt});

  BillingAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    contactId = json['contact_id'];
    isDefault = json['is_default'];
    billingAddress = json['billing_address'];
    billingCity = json['billing_city'];
    billingState = json['billing_state'];
    billingZip = json['billing_zip'];
    billingCountry = json['billing_country'];
    buildingNumber = json['building_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['contact_id'] = this.contactId;
    data['is_default'] = this.isDefault;
    data['billing_address'] = this.billingAddress;
    data['billing_city'] = this.billingCity;
    data['billing_state'] = this.billingState;
    data['billing_zip'] = this.billingZip;
    data['billing_country'] = this.billingCountry;
    data['building_number'] = this.buildingNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}