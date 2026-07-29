import 'package:app/models/product/product_model.dart';

class SelectedProductsModel {
  static List<SelectedProductsModel> selectedProducts = [];

  late ProductModel productModel;
  late int qty;
  late int? price;

  SelectedProductsModel({required this.productModel, required this.qty,this.price});
}
