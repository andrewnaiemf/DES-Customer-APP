class OfferModelInOrder {
  int? id;
  String? title;
  String? specialPrice;
  String? expiryDate;
  String? status;
  String? image;
  String? imageUrl;
  bool? isExpired;
  bool? isUsed;
  num? specialPriceTax;
  num? specialPriceAfterTax;

  OfferModelInOrder(
      {this.id,
        this.title,
        this.specialPrice,
        this.expiryDate,
        this.status,
        this.image,
        this.imageUrl,
        this.isExpired,
        this.isUsed,
        this.specialPriceTax,
        this.specialPriceAfterTax});

  OfferModelInOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    specialPrice = json['special_price'];
    expiryDate = json['expiry_date'];
    status = json['status'];
    image = json['image'];
    imageUrl = json['image_url'];
    isExpired = json['is_expired'];
    isUsed = json['is_used'];
    specialPriceTax = json['special_price_tax'];
    specialPriceAfterTax = json['special_price_after_tax'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['special_price'] = this.specialPrice;
    data['expiry_date'] = this.expiryDate;
    data['status'] = this.status;
    data['image'] = this.image;
    data['image_url'] = this.imageUrl;
    data['is_expired'] = this.isExpired;
    data['is_used'] = this.isUsed;
    data['special_price_tax'] = this.specialPriceTax;
    data['special_price_after_tax'] = this.specialPriceAfterTax;
    return data;
  }
}