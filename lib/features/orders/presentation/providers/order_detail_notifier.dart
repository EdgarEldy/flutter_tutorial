import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/order_providers.dart';
import '../../domain/entities/order.dart';

part 'order_detail_notifier.g.dart';

/// Loads and exposes a single order for the detail page.
/// [orderId] is a family parameter passed from the route.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@riverpod
class OrderDetailNotifier extends _$OrderDetailNotifier {
  @override
  AsyncValue<Order> build(int orderId) {
    _loadOrder(orderId);
    return const AsyncLoading();
  }

  Future<void> _loadOrder(int id) async {
    final result = await ref.read(getOrderByIdUseCaseProvider).call(id);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (order) => state = AsyncData(order),
    );
  }
}
