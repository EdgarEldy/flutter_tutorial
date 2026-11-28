import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/product_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import 'products_state.dart';

part 'products_notifier.g.dart';

/// Drives the product list screen. Loads categories and products on start,
/// exposes search/filter actions and a pull-to-refresh operation.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@riverpod
class ProductsNotifier extends _$ProductsNotifier {
  Timer? _searchTimer;
  int _searchSequence = 0;

  @override
  ProductsState build() {
    ref.onDispose(() => _searchTimer?.cancel());
    _loadInitial();
    return const ProductsState(isLoading: true);
  }

  Future<void> _loadInitial() async {
    final categoriesResult = await ref
        .read(getCategoriesUseCaseProvider)
        .call();
    final productsResult = await ref
        .read(getProductsUseCaseProvider)
        .call(
          categoryId: state.selectedCategoryId,
          productName: state.searchQuery.isEmpty ? null : state.searchQuery,
        );

    final categories = categoriesResult.fold(
      (_) => <Category>[],
      (cats) => cats,
    );

    productsResult.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (paginated) => state = state.copyWith(
        isLoading: false,
        products: paginated.content,
        categories: categories,
        errorMessage: null,
      ),
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    final refreshResult = await ref.read(refreshProductsUseCaseProvider).call();
    if (refreshResult.isLeft()) {
      refreshResult.fold(
        (failure) => state = state.copyWith(
          isRefreshing: false,
          errorMessage: failure.message,
        ),
        (_) {},
      );
      return;
    }

    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(
          categoryId: state.selectedCategoryId,
          productName: state.searchQuery.isEmpty ? null : state.searchQuery,
        );
    result.fold(
      (failure) => state = state.copyWith(
        isRefreshing: false,
        errorMessage: failure.message,
      ),
      (paginated) => state = state.copyWith(
        isRefreshing: false,
        products: paginated.content,
        errorMessage: null,
      ),
    );
  }

  Future<void> setCategory(int? categoryId) async {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      isLoading: true,
      errorMessage: null,
    );
    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(
          categoryId: categoryId,
          productName: state.searchQuery.isEmpty ? null : state.searchQuery,
        );
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (paginated) => state = state.copyWith(
        isLoading: false,
        products: paginated.content,
        errorMessage: null,
      ),
    );
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(
      searchQuery: query,
      isLoading: true,
      errorMessage: null,
    );
    _searchTimer?.cancel();
    final sequence = ++_searchSequence;
    final completer = Completer<void>();
    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      if (sequence == _searchSequence) {
        await _executeSearch(query, sequence);
      }
      completer.complete();
    });
    await completer.future;
  }

  Future<void> _executeSearch(String query, int sequence) async {
    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(
          categoryId: state.selectedCategoryId,
          productName: query.isEmpty ? null : query,
        );
    if (sequence != _searchSequence) return;
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (paginated) => state = state.copyWith(
        isLoading: false,
        products: paginated.content,
        errorMessage: null,
      ),
    );
  }
}

/// Filtered view of the product list, computed from [ProductsNotifier] state.
/// Returns only the products matching the current category and search query.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@riverpod
List<Product> filteredProducts(Ref ref) {
  final state = ref.watch(productsProvider);
  return state.products;
}
