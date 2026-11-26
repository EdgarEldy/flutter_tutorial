import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/order_summary.dart';

part 'cart_state.freezed.dart';

/// Immutable UI state for the cart page and cart badge.
/// isLoading covers the initial fetch; isCheckingOut guards the checkout flow.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@freezed
abstract class CartState with _$CartState {
  const factory CartState({
    Cart? cart,
    @Default(false) bool isLoading,
    @Default(false) bool isCheckingOut,
    String? errorMessage,
    OrderSummary? lastOrder,
  }) = _CartState;
}
