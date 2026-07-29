part of 'products_cubit.dart';

@immutable
sealed class ProductsState {}

final class ProductsInitial extends ProductsState {}

final class ProductsGetLoading extends ProductsState {}

final class ProductsGetSuccess extends ProductsState {}

final class ProductsGetError extends ProductsState {}

final class ProductsAddAndRemove extends ProductsState {}
