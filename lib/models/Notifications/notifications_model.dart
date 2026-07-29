class NotificationsModel {
  bool? status;
  int? code;
  NotificationsModelData? data;
  String? msg;

  NotificationsModel({this.status, this.code, this.data, this.msg});

  NotificationsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    data = json['data'] != null ? new NotificationsModelData.fromJson(json['data']) : null;
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

class NotificationsModelData {
  int? currentPage;
  List<NotificationsData>? data;
  String? firstPageUrl;


  NotificationsModelData(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
       });

  NotificationsModelData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <NotificationsData>[];
      json['data'].forEach((v) {
        data!.add(new NotificationsData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    return data;
  }
}

class NotificationsData {
  int? id;
  int? userId;
  int? notifiedUserId;
  String? type;
  int? read;
  String? screen;
  NotiData? data;
  Sender? user;
  NotifiedUser? notifiedUser;

  NotificationsData(
      {this.id,
        this.userId,
        this.notifiedUserId,
        this.type,
        this.read,
        this.screen,
        this.data,
        this.user,
        this.notifiedUser});

  NotificationsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    notifiedUserId = json['notified_user_id'];
    type = json['type'];
    read = json['read'];
    screen = json['screen'];
    data = json['data'] != null ? new NotiData.fromJson(json['data']) : null;
    user = json['user'] != null ? new Sender.fromJson(json['user']) : null;
    notifiedUser = json['notified_user'] != null
        ? new NotifiedUser.fromJson(json['notified_user'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['notified_user_id'] = this.notifiedUserId;
    data['type'] = this.type;
    data['read'] = this.read;
    data['screen'] = this.screen;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.notifiedUser != null) {
      data['notified_user'] = this.notifiedUser!.toJson();
    }
    return data;
  }
}

class NotiData {
  Notifi? data;
  String? date;
  String? time;
  Sender? sender;
  String? messageTemplate;
  String? message;

  NotiData(
      {this.data,
        this.date,
        this.time,
        this.sender,
        this.messageTemplate,
        this.message});

  NotiData.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Notifi.fromJson(json['data']) : null;
    date = json['date'];
    time = json['time'];
    sender =
    json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    messageTemplate = json['message_template'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['date'] = this.date;
    data['time'] = this.time;
    if (this.sender != null) {
      data['sender'] = this.sender!.toJson();
    }
    data['message_template'] = this.messageTemplate;
    data['message'] = this.message;
    return data;
  }
}

class Notifi {
  int? id;
  var notes;
  num? total;  
  String? status;
 var driverId;
  String? reference;
  num? totalTax;
  String? createdAt;
  String? updatedAt;
  int? customerId;
  int? inventoryId;
  num? totalWithTax;
 var shippingStatus;
 var termsConditions;
 var confirmationImage;

  Notifi(
      {this.id,
        this.notes,
        this.total,
        this.status,
        this.driverId,
        this.reference,
        this.totalTax,
        this.createdAt,
        this.updatedAt,
        this.customerId,
        this.inventoryId,
        this.totalWithTax,
        this.shippingStatus,
        this.termsConditions,
        this.confirmationImage});

  Notifi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    notes = json['notes'];
    total = json['total'];
    status = json['status'];
    driverId = json['driver_id'];
    reference = json['reference'];
    totalTax = json['total_tax'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    customerId = json['customer_id'];
    inventoryId = json['inventory_id'];
    totalWithTax = json['total_with_tax'];
    shippingStatus = json['shipping_status'];
    termsConditions = json['terms_conditions'];
    confirmationImage = json['confirmation_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['notes'] = this.notes;
    data['total'] = this.total;
    data['status'] = this.status;
    data['driver_id'] = this.driverId;
    data['reference'] = this.reference;
    data['total_tax'] = this.totalTax;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['customer_id'] = this.customerId;
    data['inventory_id'] = this.inventoryId;
    data['total_with_tax'] = this.totalWithTax;
    data['shipping_status'] = this.shippingStatus;
    data['terms_conditions'] = this.termsConditions;
    data['confirmation_image'] = this.confirmationImage;
    return data;
  }
}

class Sender {
  int? id;
  String? name;
  String? email;
  String? locale;
  String? status;
  String? createdAt;
 var taxNumber;
  String? updatedAt;
  // List<Null>? deviceToken;
  var organization;
  String? phoneNumber;

  Sender(
      {this.id,
        this.name,
        this.email,
        this.locale,
        this.status,
        this.createdAt,
        this.taxNumber,
        this.updatedAt,
     //   this.deviceToken,
        this.organization,
        this.phoneNumber});

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    locale = json['locale'];
    status = json['status'];
    createdAt = json['created_at'];
    taxNumber = json['tax_number'];
    updatedAt = json['updated_at'];
    // if (json['device_token'] != null) {
    //   deviceToken = <Null>[];
    //   json['device_token'].forEach((v) {
    //     deviceToken!.add(new Null.fromJson(v));
    //   });
    // }
    organization = json['organization'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['locale'] = this.locale;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['tax_number'] = this.taxNumber;
    data['updated_at'] = this.updatedAt;
    // if (this.deviceToken != null) {
    //   data['device_token'] = this.deviceToken!.map((v) => v.toJson()).toList();
    // }
    data['organization'] = this.organization;
    data['phone_number'] = this.phoneNumber;
    return data;
  }
}

class NotifiedUser {
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

  NotifiedUser(
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

  NotifiedUser.fromJson(Map<String, dynamic> json) {
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