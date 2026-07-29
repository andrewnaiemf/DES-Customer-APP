class AccountStatementModel2 {
  bool? status;
  int? code;
  AccountStatementModel2Data? data;
  String? msg;

  AccountStatementModel2({this.status, this.code, this.data, this.msg});

  AccountStatementModel2.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    data = json['data'] != null ? new AccountStatementModel2Data.fromJson(json['data']) : null;
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

class AccountStatementModel2Data {
  int? currentPage;
  List<AccountStatementData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  var nextPageUrl;
  String? path;
  String? perPage;
  var prevPageUrl;
  int? to;
  int? total;

  AccountStatementModel2Data(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  AccountStatementModel2Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <AccountStatementData>[];
      json['data'].forEach((v) {
        data!.add(new AccountStatementData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class AccountStatementData {
  int? id;
  int? contactId;
  int? salesRepresentativeId;
  String? reference;
  String? description;
  String? issueDate;
  String? dueDate;
  String? status;
  String? dueAmount;
  String? paidAmount;
  String? total;
  String? notes;
  String? pdf;
  String? termsConditions;
  String? qrcodeString;
  String? paymentMethod;
  String? createdAt;
  String? updatedAt;
  String? type;
  var debit;
  var credit;
  String? date;
  Contact? contact;
  String? invoiceStatus;
  Inventory? inventory;
  Contact? owner;
  List<InvoicePayments>? invoicePayments;
  String? amount;
  String? kind;
  int? accountId;
  int? unAllocateAmount;
  Inventory? fromLocation;
  String? issuanceReason;
  String? totalAmount;
  String? remainingAmount;
  int? invoiceId;

  AccountStatementData(
      {this.id,
        this.contactId,
        this.salesRepresentativeId,
        this.reference,
        this.description,
        this.issueDate,
        this.dueDate,
        this.status,
        this.dueAmount,
        this.paidAmount,
        this.total,
        this.notes,
        this.pdf,
        this.termsConditions,
        this.qrcodeString,
        this.paymentMethod,
        this.createdAt,
        this.updatedAt,
        this.type,
        this.debit,
        this.credit,
        this.date,
        this.contact,
        this.invoiceStatus,
        this.inventory,
        this.owner,
        this.invoicePayments,
        this.amount,
        this.kind,
        this.accountId,
        this.unAllocateAmount,
        this.fromLocation,
        this.issuanceReason,
        this.totalAmount,
        this.remainingAmount,
        this.invoiceId});

  AccountStatementData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    contactId = json['contact_id'];
    salesRepresentativeId = json['sales_representative_id'];
    reference = json['reference'];
    description = json['description'];
    issueDate = json['issue_date'];
    dueDate = json['due_date'];
    status = json['status'];
    dueAmount = json['due_amount'];
    paidAmount = json['paid_amount'];
    total = json['total'];
    notes = json['notes'];
    pdf = json['pdf'];
    termsConditions = json['terms_conditions'];
    qrcodeString = json['qrcode_string'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    type = json['type'];
    debit = json['debit'];
    credit = json['credit'];
    date = json['date'];
    contact =
    json['contact'] != null ? new Contact.fromJson(json['contact']) : null;
    invoiceStatus = json['invoice_status'];
    inventory = json['inventory'] != null
        ? new Inventory.fromJson(json['inventory'])
        : null;
    owner = json['owner'] != null ? new Contact.fromJson(json['owner']) : null;
    if (json['invoicePayments'] != null) {
      invoicePayments = <InvoicePayments>[];
      json['invoicePayments'].forEach((v) {
        invoicePayments!.add(new InvoicePayments.fromJson(v));
      });
    }
    amount = json['amount'];
    kind = json['kind'];
    accountId = json['account_id'];
    unAllocateAmount = json['un_allocate_amount'];
    fromLocation = json['from_location'] != null
        ? new Inventory.fromJson(json['from_location'])
        : null;
    issuanceReason = json['issuance_reason'];
    totalAmount = json['total_amount'];
    remainingAmount = json['remaining_amount'];
    invoiceId = json['invoice_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['contact_id'] = this.contactId;
    data['sales_representative_id'] = this.salesRepresentativeId;
    data['reference'] = this.reference;
    data['description'] = this.description;
    data['issue_date'] = this.issueDate;
    data['due_date'] = this.dueDate;
    data['status'] = this.status;
    data['due_amount'] = this.dueAmount;
    data['paid_amount'] = this.paidAmount;
    data['total'] = this.total;
    data['notes'] = this.notes;
    data['pdf'] = this.pdf;
    data['terms_conditions'] = this.termsConditions;
    data['qrcode_string'] = this.qrcodeString;
    data['payment_method'] = this.paymentMethod;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['type'] = this.type;
    data['debit'] = this.debit;
    data['credit'] = this.credit;
    data['date'] = this.date;
    if (this.contact != null) {
      data['contact'] = this.contact!.toJson();
    }
    data['invoice_status'] = this.invoiceStatus;
    if (this.inventory != null) {
      data['inventory'] = this.inventory!.toJson();
    }
    if (this.owner != null) {
      data['owner'] = this.owner!.toJson();
    }
    if (this.invoicePayments != null) {
      data['invoicePayments'] =
          this.invoicePayments!.map((v) => v.toJson()).toList();
    }
    data['amount'] = this.amount;
    data['kind'] = this.kind;
    data['account_id'] = this.accountId;
    data['un_allocate_amount'] = this.unAllocateAmount;
    if (this.fromLocation != null) {
      data['from_location'] = this.fromLocation!.toJson();
    }
    data['issuance_reason'] = this.issuanceReason;
    data['total_amount'] = this.totalAmount;
    data['remaining_amount'] = this.remainingAmount;
    data['invoice_id'] = this.invoiceId;
    return data;
  }
}

class Contact {
  int? id;
  var categoryId;
  int? customerClassificationId;
  List<String>? deviceToken;
  String? locale;
  int? isAndroid;
  String? name;
  var type;
  String? points;
  String? organization;
  String? email;
  String? phoneNumber;
  String? taxNumber;
  String? status;
  var rememberToken;
  String? createdAt;
  String? updatedAt;
  var deletedAt;
  int? blocked;
  int? closingBalance;
  int? overdue;
  int? totalInvoicesCount;
  double? totalInvoicesAmount;
  int? totalOutStanding;
  int? totalPaid;
  List<Branches>? branches;
  ShippingAddress? shippingAddress;
  BillingAddress? billingAddress;

  Contact(
      {this.id,
        this.categoryId,
        this.customerClassificationId,
        this.deviceToken,
        this.locale,
        this.isAndroid,
        this.name,
        this.type,
        this.points,
        this.organization,
        this.email,
        this.phoneNumber,
        this.taxNumber,
        this.status,
        this.rememberToken,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.blocked,
        this.closingBalance,
        this.overdue,
        this.totalInvoicesCount,
        this.totalInvoicesAmount,
        this.totalOutStanding,
        this.totalPaid,
        this.branches,
        this.shippingAddress,
        this.billingAddress});

  Contact.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    customerClassificationId = json['customer_classification_id'];
    deviceToken = json['device_token'].cast<String>();
    locale = json['locale'];
    isAndroid = json['is_android'];
    name = json['name'];
    type = json['type'];
    points = json['points'];
    organization = json['organization'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    taxNumber = json['tax_number'];
    status = json['status'];
    rememberToken = json['remember_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    blocked = json['blocked'];
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
    data['category_id'] = this.categoryId;
    data['customer_classification_id'] = this.customerClassificationId;
    data['device_token'] = this.deviceToken;
    data['locale'] = this.locale;
    data['is_android'] = this.isAndroid;
    data['name'] = this.name;
    data['type'] = this.type;
    data['points'] = this.points;
    data['organization'] = this.organization;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['tax_number'] = this.taxNumber;
    data['status'] = this.status;
    data['remember_token'] = this.rememberToken;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['blocked'] = this.blocked;
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
  var categoryId;
  int? customerClassificationId;
  List<String>? deviceToken;
  String? locale;
  int? isAndroid;
  String? name;
  var type;
  String? points;
  String? organization;
  String? email;
  String? phoneNumber;
  String? taxNumber;
  String? status;
  String? createdAt;
  String? updatedAt;
  var deletedAt;
  int? blocked;

  Branches(
      {this.id,
        this.categoryId,
        this.customerClassificationId,
        this.deviceToken,
        this.locale,
        this.isAndroid,
        this.name,
        this.type,
        this.points,
        this.organization,
        this.email,
        this.phoneNumber,
        this.taxNumber,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.blocked});

  Branches.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    customerClassificationId = json['customer_classification_id'];
    deviceToken = json['device_token'].cast<String>();
    locale = json['locale'];
    isAndroid = json['is_android'];
    name = json['name'];
    type = json['type'];
    points = json['points'];
    organization = json['organization'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    taxNumber = json['tax_number'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    blocked = json['blocked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['customer_classification_id'] = this.customerClassificationId;
    data['device_token'] = this.deviceToken;
    data['locale'] = this.locale;
    data['is_android'] = this.isAndroid;
    data['name'] = this.name;
    data['type'] = this.type;
    data['points'] = this.points;
    data['organization'] = this.organization;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['tax_number'] = this.taxNumber;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['blocked'] = this.blocked;
    return data;
  }
}

class ShippingAddress {
  int? id;
  int? contactId;
  var isDefault;
  String? shippingAddress;
  String? shippingCity;
  String? shippingState;
  String? shippingZip;
  var shippingCountry;
  var shippingBuildingNumber;
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
  var isDefault;
  String? billingAddress;
  String? billingCity;
  String? billingState;
  String? billingZip;
  var billingCountry;
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

class Inventory {
  int? id;
  String? arName;
  String? name;
  int? accountId;
  var shippingAddressId;
  String? createdAt;
  String? updatedAt;

  Inventory(
      {this.id,
        this.arName,
        this.name,
        this.accountId,
        this.shippingAddressId,
        this.createdAt,
        this.updatedAt});

  Inventory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    arName = json['ar_name'];
    name = json['name'];
    accountId = json['account_id'];
    shippingAddressId = json['shipping_address_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ar_name'] = this.arName;
    data['name'] = this.name;
    data['account_id'] = this.accountId;
    data['shipping_address_id'] = this.shippingAddressId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class InvoicePayments {
  int? id;
  int? invoiceId;
  String? amount;
  String? date;
  String? sourceType;
  String? allocateeType;
  int? allocateeId;
  String? createdAt;
  String? updatedAt;

  InvoicePayments(
      {this.id,
        this.invoiceId,
        this.amount,
        this.date,
        this.sourceType,
        this.allocateeType,
        this.allocateeId,
        this.createdAt,
        this.updatedAt});

  InvoicePayments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceId = json['invoice_id'];
    amount = json['amount'];
    date = json['date'];
    sourceType = json['source_type'];
    allocateeType = json['allocatee_type'];
    allocateeId = json['allocatee_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['invoice_id'] = this.invoiceId;
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['source_type'] = this.sourceType;
    data['allocatee_type'] = this.allocateeType;
    data['allocatee_id'] = this.allocateeId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
// class AccountStatementModel2 {
//   bool? status;
//   int? code;
//   AccountStatementModel2Data? data;
//   String? msg;
//
//   AccountStatementModel2({this.status, this.code, this.data, this.msg});
//
//   AccountStatementModel2.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     code = json['code'];
//     data = json['data'] != null ? new AccountStatementModel2Data.fromJson(json['data']) : null;
//     msg = json['msg'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['code'] = this.code;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     data['msg'] = this.msg;
//     return data;
//   }
// }
//
// class AccountStatementModel2Data {
//   List<AccountStatementData>? data;
//
//
//
//   AccountStatementModel2Data(
//       {
//         this.data,
//        });
//
//   AccountStatementModel2Data.fromJson(Map<String, dynamic> json) {
//     if (json['data'] != null) {
//       data = <AccountStatementData>[];
//       json['data'].forEach((v) {
//         data!.add(new AccountStatementData.fromJson(v));
//       });
//     }
//
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//
//     return data;
//   }
// }
//
// class AccountStatementData {
//   int? id;
//   int? contactId;
//   String? reference;
//   String? description;
//   String? issueDate;
//   String? dueDate;
//   String? status;
//   String? dueAmount;
//   String? paidAmount;
//   String? total;
//   String? notes;
//   String? termsConditions;
//   String? qrcodeString;
//   var paymentMethod;
//   String? createdAt;
//   String? updatedAt;
//   String? type;
//   var debit;
//   var credit;
//   String? date;
//   Contact? contact;
//   Inventory? inventory;
//   Owner? owner;
//   String? amount;
//   String? kind;
//   int? accountId;
//   int? unAllocateAmount;
//   Inventory? fromLocation;
//
//   AccountStatementData(
//       {this.id,
//         this.contactId,
//         this.reference,
//         this.description,
//         this.issueDate,
//         this.dueDate,
//         this.status,
//         this.dueAmount,
//         this.paidAmount,
//         this.total,
//         this.notes,
//         this.termsConditions,
//         this.qrcodeString,
//         this.paymentMethod,
//         this.createdAt,
//         this.updatedAt,
//         this.type,
//         this.debit,
//         this.credit,
//         this.date,
//         this.contact,
//         this.inventory,
//         this.owner,
//         this.amount,
//         this.kind,
//         this.accountId,
//         this.unAllocateAmount,
//         this.fromLocation});
//
//   AccountStatementData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     contactId = json['contact_id'];
//     reference = json['reference'];
//     description = json['description'];
//     issueDate = json['issue_date'];
//     dueDate = json['due_date'];
//     status = json['status'];
//     dueAmount = json['due_amount'];
//     paidAmount = json['paid_amount'];
//     total = json['total'];
//     notes = json['notes'];
//     termsConditions = json['terms_conditions'];
//     qrcodeString = json['qrcode_string'];
//     paymentMethod = json['payment_method'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     type = json['type'];
//     debit = json['debit'];
//     credit = json['credit'];
//     date = json['date'];
//     contact =
//     json['contact'] != null ? new Contact.fromJson(json['contact']) : null;
//     inventory = json['inventory'] != null
//         ? new Inventory.fromJson(json['inventory'])
//         : null;
//     owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
//     amount = json['amount'];
//     kind = json['kind'];
//     accountId = json['account_id'];
//     unAllocateAmount = json['un_allocate_amount'];
//     fromLocation = json['from_location'] != null
//         ? new Inventory.fromJson(json['from_location'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['contact_id'] = this.contactId;
//     data['reference'] = this.reference;
//     data['description'] = this.description;
//     data['issue_date'] = this.issueDate;
//     data['due_date'] = this.dueDate;
//     data['status'] = this.status;
//     data['due_amount'] = this.dueAmount;
//     data['paid_amount'] = this.paidAmount;
//     data['total'] = this.total;
//     data['notes'] = this.notes;
//     data['terms_conditions'] = this.termsConditions;
//     data['qrcode_string'] = this.qrcodeString;
//     data['payment_method'] = this.paymentMethod;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['type'] = this.type;
//     data['debit'] = this.debit;
//     data['credit'] = this.credit;
//     data['date'] = this.date;
//     if (this.contact != null) {
//       data['contact'] = this.contact!.toJson();
//     }
//     if (this.inventory != null) {
//       data['inventory'] = this.inventory!.toJson();
//     }
//     if (this.owner != null) {
//       data['owner'] = this.owner!.toJson();
//     }
//     data['amount'] = this.amount;
//     data['kind'] = this.kind;
//     data['account_id'] = this.accountId;
//     data['un_allocate_amount'] = this.unAllocateAmount;
//     if (this.fromLocation != null) {
//       data['from_location'] = this.fromLocation!.toJson();
//     }
//     return data;
//   }
// }
//
// class Contact {
//   int? id;
//   List<String>? deviceToken;
//   String? locale;
//   String? name;
//   String? organization;
//   String? email;
//   String? phoneNumber;
//   String? taxNumber;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//   num? closingBalance;
//   num? overdue;
//   num? totalInvoicesCount;
//   num? totalInvoicesAmount;
//   num? totalOutStanding;
//   num? totalPaid;
//   List<Branches>? branches;
//   ShippingAddress? shippingAddress;
//   BillingAddress? billingAddress;
//
//   Contact(
//       {this.id,
//         this.deviceToken,
//         this.locale,
//         this.name,
//         this.organization,
//         this.email,
//         this.phoneNumber,
//         this.taxNumber,
//         this.status,
//         this.createdAt,
//         this.updatedAt,
//         this.closingBalance,
//         this.overdue,
//         this.totalInvoicesCount,
//         this.totalInvoicesAmount,
//         this.totalOutStanding,
//         this.totalPaid,
//         this.branches,
//         this.shippingAddress,
//         this.billingAddress});
//
//   Contact.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     // deviceToken = json['device_token'].cast<String>();
//     deviceToken = json['device_token'] != null && json['device_token'] is List
//         ? List<String>.from(json['device_token'])
//         : [];
//     locale = json['locale'];
//     name = json['name'];
//     organization = json['organization'];
//     email = json['email'];
//     phoneNumber = json['phone_number'];
//     taxNumber = json['tax_number'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     closingBalance = json['closing_balance'];
//     overdue = json['overdue'];
//     totalInvoicesCount = json['total_invoices_count'];
//     totalInvoicesAmount = json['total_invoices_amount'];
//     totalOutStanding = json['total_out_standing'];
//     totalPaid = json['total_paid'];
//     if (json['branches'] != null) {
//       branches = <Branches>[];
//       json['branches'].forEach((v) {
//         branches!.add(new Branches.fromJson(v));
//       });
//     }
//     shippingAddress = json['shipping_address'] != null
//         ? new ShippingAddress.fromJson(json['shipping_address'])
//         : null;
//     billingAddress = json['billing_address'] != null
//         ? new BillingAddress.fromJson(json['billing_address'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['device_token'] = this.deviceToken;
//     data['locale'] = this.locale;
//     data['name'] = this.name;
//     data['organization'] = this.organization;
//     data['email'] = this.email;
//     data['phone_number'] = this.phoneNumber;
//     data['tax_number'] = this.taxNumber;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['closing_balance'] = this.closingBalance;
//     data['overdue'] = this.overdue;
//     data['total_invoices_count'] = this.totalInvoicesCount;
//     data['total_invoices_amount'] = this.totalInvoicesAmount;
//     data['total_out_standing'] = this.totalOutStanding;
//     data['total_paid'] = this.totalPaid;
//     if (this.branches != null) {
//       data['branches'] = this.branches!.map((v) => v.toJson()).toList();
//     }
//     if (this.shippingAddress != null) {
//       data['shipping_address'] = this.shippingAddress!.toJson();
//     }
//     if (this.billingAddress != null) {
//       data['billing_address'] = this.billingAddress!.toJson();
//     }
//     return data;
//   }
// }
//
// class Branches {
//   int? id;
//   List<String>? deviceToken;
//   String? locale;
//   String? name;
//   String? organization;
//   String? email;
//   String? phoneNumber;
//   String? taxNumber;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//
//   Branches(
//       {this.id,
//         this.deviceToken,
//         this.locale,
//         this.name,
//         this.organization,
//         this.email,
//         this.phoneNumber,
//         this.taxNumber,
//         this.status,
//         this.createdAt,
//         this.updatedAt});
//
//   Branches.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     // deviceToken = json['device_token'].cast<String>();
//     deviceToken = json['device_token'] != null && json['device_token'] is List
//         ? List<String>.from(json['device_token'])
//         : [];
//     locale = json['locale'];
//     name = json['name'];
//     organization = json['organization'];
//     email = json['email'];
//     phoneNumber = json['phone_number'];
//     taxNumber = json['tax_number'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['device_token'] = this.deviceToken;
//     data['locale'] = this.locale;
//     data['name'] = this.name;
//     data['organization'] = this.organization;
//     data['email'] = this.email;
//     data['phone_number'] = this.phoneNumber;
//     data['tax_number'] = this.taxNumber;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class ShippingAddress {
//   int? id;
//   int? contactId;
//   String? shippingAddress;
//   String? shippingCity;
//   String? shippingState;
//   String? shippingZip;
//
//   String? createdAt;
//   String? updatedAt;
//
//   ShippingAddress(
//       {this.id,
//         this.contactId,
//         this.shippingAddress,
//         this.shippingCity,
//         this.shippingState,
//         this.shippingZip,
//         this.createdAt,
//         this.updatedAt});
//
//   ShippingAddress.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     contactId = json['contact_id'];
//     shippingAddress = json['shipping_address'];
//     shippingCity = json['shipping_city'];
//     shippingState = json['shipping_state'];
//     shippingZip = json['shipping_zip'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['contact_id'] = this.contactId;
//     data['shipping_address'] = this.shippingAddress;
//     data['shipping_city'] = this.shippingCity;
//     data['shipping_state'] = this.shippingState;
//     data['shipping_zip'] = this.shippingZip;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class BillingAddress {
//   int? id;
//   int? contactId;
//   String? billingAddress;
//   String? billingCity;
//   String? billingState;
//   String? billingZip;
//   String? createdAt;
//   String? updatedAt;
//
//   BillingAddress(
//       {this.id,
//         this.contactId,
//         this.billingAddress,
//         this.billingCity,
//         this.billingState,
//         this.billingZip,
//         this.createdAt,
//         this.updatedAt});
//
//   BillingAddress.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     contactId = json['contact_id'];
//     billingAddress = json['billing_address'];
//     billingCity = json['billing_city'];
//     billingState = json['billing_state'];
//     billingZip = json['billing_zip'];
//
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['contact_id'] = this.contactId;
//     data['billing_address'] = this.billingAddress;
//     data['billing_city'] = this.billingCity;
//     data['billing_state'] = this.billingState;
//     data['billing_zip'] = this.billingZip;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class Inventory {
//   int? id;
//   String? arName;
//   String? name;
//   int? accountId;
//   String? createdAt;
//   String? updatedAt;
//
//   Inventory(
//       {this.id,
//         this.arName,
//         this.name,
//         this.accountId,
//         this.createdAt,
//         this.updatedAt});
//
//   Inventory.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     arName = json['ar_name'];
//     name = json['name'];
//     accountId = json['account_id'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['ar_name'] = this.arName;
//     data['name'] = this.name;
//     data['account_id'] = this.accountId;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class Owner {
//   int? id;
//   String? locale;
//   String? name;
//   String? organization;
//   String? email;
//   String? phoneNumber;
//   String? taxNumber;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//   String? commercialRegistrationNumber;
//   ShippingAddress? shippingAddress;
//
//   Owner(
//       {this.id,
//         this.locale,
//         this.name,
//         this.organization,
//         this.email,
//         this.phoneNumber,
//         this.taxNumber,
//         this.status,
//         this.createdAt,
//         this.updatedAt,
//         this.commercialRegistrationNumber,
//         this.shippingAddress});
//
//   Owner.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     locale = json['locale'];
//     name = json['name'];
//     organization = json['organization'];
//     email = json['email'];
//     phoneNumber = json['phone_number'];
//     taxNumber = json['tax_number'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     commercialRegistrationNumber = json['commercial_registration_number'];
//     shippingAddress = json['shipping_address'] != null
//         ? new ShippingAddress.fromJson(json['shipping_address'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['locale'] = this.locale;
//     data['name'] = this.name;
//     data['organization'] = this.organization;
//     data['email'] = this.email;
//     data['phone_number'] = this.phoneNumber;
//     data['tax_number'] = this.taxNumber;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['commercial_registration_number'] = this.commercialRegistrationNumber;
//     if (this.shippingAddress != null) {
//       data['shipping_address'] = this.shippingAddress!.toJson();
//     }
//     return data;
//   }
// }