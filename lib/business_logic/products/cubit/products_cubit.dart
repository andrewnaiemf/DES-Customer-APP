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
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 10);
  static const int _perPage = 20;
  int _currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  Future<void> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && allProducts.isNotEmpty && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
      return;
    }
    try {
      isLoadingData = true;
      emit(ProductsGetLoading());
      _currentPage = 1;
      allProducts = await ProductsServices.getData(page: 1, perPage: _perPage);
      hasMore = allProducts.length >= _perPage;
      _lastFetchTime = DateTime.now();
      isLoadingData = false;
      emit(ProductsGetSuccess());
    } catch (e) {
      log('$e');
      isLoadingData = false;
      emit(ProductsGetError());
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isLoadingData) return;
    isLoadingMore = true;
    emit(ProductsGetLoading());
    try {
      final nextPage = _currentPage + 1;
      final items = await ProductsServices.getData(page: nextPage, perPage: _perPage);
      if (items.isEmpty) {
        hasMore = false;
      } else {
        allProducts.addAll(items);
        _currentPage = nextPage;
        hasMore = items.length >= _perPage;
      }
      isLoadingMore = false;
      emit(ProductsGetSuccess());
    } catch (e) {
      isLoadingMore = false;
      emit(ProductsGetError());
    }
  }
}
