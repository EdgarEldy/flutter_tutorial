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
  @override
  ProductsState build() {
    _loadInitial();
    return const ProductsState(isLoading: true);
  }

  Future<void> _loadInitial() async {
    final categoriesResult =
        await ref.read(getCategoriesUseCaseProvider).call();
    final productsResult = await ref.read(getProductsUseCaseProvider).call(
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

    // Force a full network fetch and cache replacement before reading back.
    // Without this step, getProductsUseCase would return stale cached data
    // when no filter is active, making pull-to-refresh a no-op.
    final refreshResult =
        await ref.read(refreshProductsUseCaseProvider).call();
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

    final result = await ref.read(getProductsUseCaseProvider).call(
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
    final result = await ref.read(getProductsUseCaseProvider).call(
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
    final result = await ref.read(getProductsUseCaseProvider).call(
          categoryId: state.selectedCategoryId,
          productName: query.isEmpty ? null : query,
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
