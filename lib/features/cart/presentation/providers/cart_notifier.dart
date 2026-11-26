import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/cart_providers.dart';
import 'cart_state.dart';

part 'cart_notifier.g.dart';

/// Drives the cart page. Loads the cart on first build and exposes
/// mutations that keep the UI in sync with the server state.
/// keepAlive ensures the cart badge stays up-to-date across all tabs.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  @override
  CartState build() {
    _loadCart();
    return const CartState(isLoading: true);
  }

  Future<void> _loadCart() async {
    final result = await ref.read(getCartUseCaseProvider).call();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (cart) => state = state.copyWith(
        isLoading: false,
        cart: cart,
        errorMessage: null,
      ),
    );
  }

  /// Adds [quantity] units of [productId] to the cart.
  Future<void> addItem(int productId, int quantity) async {
    final result =
        await ref.read(addCartItemUseCaseProvider).call(productId, quantity);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (cart) => state = state.copyWith(cart: cart, errorMessage: null),
    );
  }

  /// Updates the quantity of [itemId].
  Future<void> updateItem(int itemId, int quantity) async {
    final result =
        await ref.read(updateCartItemUseCaseProvider).call(itemId, quantity);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (cart) => state = state.copyWith(cart: cart, errorMessage: null),
    );
  }

  /// Removes [itemId] from the cart.
  Future<void> removeItem(int itemId) async {
    final result = await ref.read(removeCartItemUseCaseProvider).call(itemId);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (cart) => state = state.copyWith(cart: cart, errorMessage: null),
    );
  }

  /// Submits the cart as an order. Duplicate-submit protection via isCheckingOut flag.
  Future<void> checkout() async {
    if (state.isCheckingOut) return;
    state = state.copyWith(isCheckingOut: true, errorMessage: null);
    final result = await ref.read(checkoutUseCaseProvider).call();
    result.fold(
      (failure) => state = state.copyWith(
        isCheckingOut: false,
        errorMessage: failure.message,
      ),
      (order) => state = state.copyWith(
        isCheckingOut: false,
        cart: null,
        lastOrder: order,
      ),
    );
  }

  /// Reloads the cart from the server.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _loadCart();
  }
}
