import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/order_providers.dart';
import 'orders_state.dart';

part 'orders_notifier.g.dart';

/// Drives the orders list screen. Loads orders on start and exposes refresh.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  @override
  OrdersState build() {
    _loadOrders();
    return const OrdersState(isLoading: true);
  }

  Future<void> _loadOrders() async {
    final result = await ref.read(getOrdersUseCaseProvider).call();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(
        isLoading: false,
        orders: orders,
        errorMessage: null,
      ),
    );
  }

  /// Invalidates the cache and fetches fresh data from the network.
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    final result = await ref.read(refreshOrdersUseCaseProvider).call();
    result.fold(
      (failure) => state = state.copyWith(
        isRefreshing: false,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(
        isRefreshing: false,
        orders: orders,
        errorMessage: null,
      ),
    );
  }
}
