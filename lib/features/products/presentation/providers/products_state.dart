import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

part 'products_state.freezed.dart';

/// Immutable UI state for the product list page.
/// Holds the full product list, categories, loading flags and filter values.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@freezed
abstract class ProductsState with _$ProductsState {
  const factory ProductsState({
    @Default([]) List<Product> products,
    @Default([]) List<Category> categories,
    @Default(true) bool isLoading,
    @Default(false) bool isRefreshing,
    String? errorMessage,
    int? selectedCategoryId,
    @Default('') String searchQuery,
  }) = _ProductsState;
}
