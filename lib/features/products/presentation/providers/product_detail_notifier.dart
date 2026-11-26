import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/product_providers.dart';
import '../../domain/entities/product.dart';

part 'product_detail_notifier.g.dart';

/// Loads and exposes a single product for the detail page.
/// [productId] is a family parameter passed from the route.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@riverpod
class ProductDetailNotifier extends _$ProductDetailNotifier {
  @override
  AsyncValue<Product> build(int productId) {
    _loadProduct(productId);
    return const AsyncLoading();
  }

  Future<void> _loadProduct(int id) async {
    final result = await ref.read(getProductByIdUseCaseProvider).call(id);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (product) => state = AsyncData(product),
    );
  }
}
