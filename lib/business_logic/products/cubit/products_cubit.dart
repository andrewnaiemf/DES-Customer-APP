import 'dart:developer';

import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/product/product_model.dart';
import 'package:app/models/selected_products/selected_products.dart';
import 'package:app/network/services/products_services.dart';
import 'package:app/theme/colors.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  static ProductsCubit get(BuildContext context) => BlocProvider.of(context);

  bool isLoadingData = false;
  bool isLoadingAction = false;
  bool isLoadingDelete = false;

  double totalPrice = 0.0;
  double totalTax = 0.0;
  double discount = 0.0;
  double points = 0.0;
  bool isChecked = false;
  void selectProduct(BuildContext context, ProductModel productModel) {
    if (SelectedProductsModel.selectedProducts.where((element) => element.productModel == productModel).isEmpty) {
      SelectedProductsModel.selectedProducts.add(SelectedProductsModel(productModel: productModel, qty: 1));
      MyNavigator.back(context);
    } else {
      showMessage(context: context, message: 'It has already been chosen'.tr(), color: MyColors.redColor);
    }
    calcTotalPrices();
    emit(ProductsAddAndRemove());
  }

  void addQtyProduct(BuildContext context, ProductModel productModel) {
    SelectedProductsModel.selectedProducts.where((element) => element.productModel == productModel).first.qty += 1;
    calcTotalPrices();
    emit(ProductsAddAndRemove());
  }

  void qtyMinusProduct(BuildContext context, ProductModel productModel) {
    if (SelectedProductsModel.selectedProducts.where((element) => element.productModel == productModel).isNotEmpty) {
      if (SelectedProductsModel.selectedProducts.where((element) => element.productModel == productModel).first.qty == 1) {
        SelectedProductsModel.selectedProducts.remove(SelectedProductsModel.selectedProducts.where((element) => element.productModel == productModel).first);
      } else {
        SelectedProductsModel.selectedProducts.where((element) => element.productModel == productModel).first.qty -= 1;
      }
    } else {
      showMessage(context: context, message: 'The product cannot be deleted'.tr(), color: MyColors.redColor);
    }

    calcTotalPrices();

    emit(ProductsAddAndRemove());
  }

  void calcTotalPrices() {
    totalPrice = 0.0;
    totalTax = 0.0;
    for (var product in SelectedProductsModel.selectedProducts) {
      totalPrice = totalPrice + (double.parse(product.productModel.customers!.first.pivot.price) * product.qty);
      totalTax = totalTax + (((double.parse(product.productModel.tax?.rate ?? '0.0') / 100) * double.parse(product.productModel.customers!.first.pivot.price)) * product.qty);
    }
  }


  List<ProductModel> allProducts = [];
  DateTime? _lastFetchTime; // ✅ Cache timer
  static const Duration _cacheValidDuration = Duration(minutes: 10);
  
  Future<void> getProducts({bool forceRefresh = false}) async {
    // ✅ تجنب إعادة تحميل البيانات إذا الكاش صالح
    if (!forceRefresh && allProducts.isNotEmpty && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
      return;
    }
    try {
      isLoadingData = true;
      emit(ProductsGetLoading());
      allProducts = await ProductsServices.getData();
      _lastFetchTime = DateTime.now();
      isLoadingData = false;
      emit(ProductsGetSuccess());
    } catch (e) {
      log('$e');
      isLoadingData = false;
      emit(ProductsGetError());
    }
  }
}
