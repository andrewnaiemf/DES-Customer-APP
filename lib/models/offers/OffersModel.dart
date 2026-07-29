class OffersModel {
  bool? status;
  int? code;
  OffersData? data;
  String? msg;

  OffersModel({this.status, this.code, this.data, this.msg});

  OffersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    data = json['data'] != null ? new OffersData.fromJson(json['data']) : null;
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

class OffersData {
  int? currentPage;
  List<OfferData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  var nextPageUrl;
  String? path;
  int? perPage;
  var prevPageUrl;
  int? to;
  int? total;

  OffersData(
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

  OffersData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <OfferData>[];
      json['data'].forEach((v) {
        data!.add(new OfferData.fromJson(v));
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

class OfferData {
  int? id;
  String? title;
  String? image;
  var specialPrice;
  var special_price_tax;
  var special_price_after_tax;
  String? expiryDate;
  String? status;
  int? usageCount;
  String? createdAt;
  String? updatedAt;
  int? productsCount;
  int? customersCount;
  int? ordersCount;
  String? imageUrl;
  bool? isExpired;
  bool? isUsed;
  List<Products>? products;
  List<Customers>? customers;

  OfferData(
      {this.id,
        this.title,
        this.image,
        this.specialPrice,
        this.special_price_tax,
        this.special_price_after_tax,
        this.expiryDate,
        this.status,
        this.usageCount,
        this.createdAt,
        this.updatedAt,
        this.productsCount,
        this.customersCount,
        this.ordersCount,
        this.imageUrl,
        this.isExpired,
        this.isUsed,
        this.products,
        this.customers});

  OfferData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    specialPrice = json['special_price'];
    special_price_tax = json['special_price_tax'];
    special_price_after_tax = json['special_price_after_tax'];
    expiryDate = json['expiry_date'];
    status = json['status'];
    usageCount = json['usage_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    productsCount = json['products_count'];
    customersCount = json['customers_count'];
    ordersCount = json['orders_count'];
    imageUrl = json['image_url'];
    isExpired = json['is_expired'];
    isUsed = json['is_used'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
    if (json['customers'] != null) {
      customers = <Customers>[];
      json['customers'].forEach((v) {
        customers!.add(new Customers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image'] = this.image;
    data['special_price'] = this.specialPrice;
    data['special_price_tax'] = this.special_price_tax;
    data['special_price_after_tax'] = this.special_price_after_tax;
    data['expiry_date'] = this.expiryDate;
    data['status'] = this.status;
    data['usage_count'] = this.usageCount;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['products_count'] = this.productsCount;
    data['customers_count'] = this.customersCount;
    data['orders_count'] = this.ordersCount;
    data['image_url'] = this.imageUrl;
    data['is_expired'] = this.isExpired;
    data['is_used'] = this.isUsed;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    if (this.customers != null) {
      data['customers'] = this.customers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  int? id;
  String? nameAr;
  String? nameEn;
  String? picture;
  var customerPrice;
  Pivot? pivot;

  Products(
      {this.id,
        this.nameAr,
        this.nameEn,
        this.picture,
        this.customerPrice,
        this.pivot});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    picture = json['picture'];
    customerPrice = json['customer_price'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name_ar'] = this.nameAr;
    data['name_en'] = this.nameEn;
    data['picture'] = this.picture;
    data['customer_price'] = this.customerPrice;
    if (this.pivot != null) {
      data['pivot'] = this.pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? offerId;
  int? productId;
  int? quantity;
  String? unitPrice;
  String? createdAt;
  String? updatedAt;

  Pivot(
      {this.offerId,
        this.productId,
        this.quantity,
        this.unitPrice,
        this.createdAt,
        this.updatedAt});

  Pivot.fromJson(Map<String, dynamic> json) {
    offerId = json['offer_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    unitPrice = json['unit_price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['offer_id'] = this.offerId;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['unit_price'] = this.unitPrice;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Customers {
  int? id;
  String? name;
  String? phoneNumber;
  Pivot? pivot;
  num? closingBalance;
  num? overdue;
  num? totalInvoicesCount;
  num? totalInvoicesAmount;
  num? totalOutStanding;
  num? totalPaid;
  // List<Branches>? branches;
  ShippingAddress? shippingAddress;
  BillingAddress? billingAddress;

  Customers(
      {this.id,
        this.name,
        this.phoneNumber,
        this.pivot,
        this.closingBalance,
        this.overdue,
        this.totalInvoicesCount,
        this.totalInvoicesAmount,
        this.totalOutStanding,
        this.totalPaid,
        // this.branches,
        this.shippingAddress,
        this.billingAddress});

  Customers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phoneNumber = json['phone_number'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
    closingBalance = json['closing_balance'];
    overdue = json['overdue'];
    totalInvoicesCount = json['total_invoices_count'];
    totalInvoicesAmount = json['total_invoices_amount'];
    totalOutStanding = json['total_out_standing'];
    totalPaid = json['total_paid'];
    // if (json['branches'] != null) {
    //   branches = <Branches>[];
    //   json['branches'].forEach((v) {
    //     branches!.add(new Branches.fromJson(v));
    //   });
    // }
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
    data['name'] = this.name;
    data['phone_number'] = this.phoneNumber;
    if (this.pivot != null) {
      data['pivot'] = this.pivot!.toJson();
    }
    data['closing_balance'] = this.closingBalance;
    data['overdue'] = this.overdue;
    data['total_invoices_count'] = this.totalInvoicesCount;
    data['total_invoices_amount'] = this.totalInvoicesAmount;
    data['total_out_standing'] = this.totalOutStanding;
    data['total_paid'] = this.totalPaid;
    // if (this.branches != null) {
    //   data['branches'] = this.branches!.map((v) => v.toJson()).toList();
    // }
    if (this.shippingAddress != null) {
      data['shipping_address'] = this.shippingAddress!.toJson();
    }
    if (this.billingAddress != null) {
      data['billing_address'] = this.billingAddress!.toJson();
    }
    return data;
  }
}

// class Pivot {
//   int? offerId;
//   int? customerId;
//
//   Pivot({this.offerId, this.customerId});
//
//   Pivot.fromJson(Map<String, dynamic> json) {
//     offerId = json['offer_id'];
//     customerId = json['customer_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['offer_id'] = this.offerId;
//     data['customer_id'] = this.customerId;
//     return data;
//   }
// }

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
  Null? isDefault;
  String? shippingAddress;
  String? shippingCity;
  String? shippingState;
  String? shippingZip;
  String? shippingCountry;
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
 var isDefault;
  String? billingAddress;
  String? billingCity;
  String? billingState;
  String? billingZip;
  String? billingCountry;
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