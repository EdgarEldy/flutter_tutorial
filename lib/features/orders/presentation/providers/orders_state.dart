import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order.dart';

part 'orders_state.freezed.dart';

/// Immutable UI state for the orders list page.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@freezed
abstract class OrdersState with _$OrdersState {
  const factory OrdersState({
    @Default([]) List<Order> orders,
    @Default(true) bool isLoading,
    @Default(false) bool isRefreshing,
    String? errorMessage,
  }) = _OrdersState;
}
