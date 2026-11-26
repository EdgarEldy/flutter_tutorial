import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order.dart';
import 'order_item_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

/// Freezed model mapping the backend OrderResponse JSON object.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@freezed
abstract class OrderModel with _$OrderModel {
  const OrderModel._();

  const factory OrderModel({
    required int id,
    @JsonKey(name: 'order_number') required String orderNumber,
    required String status,
    @JsonKey(name: 'total_amount') required double totalAmount,
    @Default([]) List<OrderItemModel> items,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  /// Reconstructs an [OrderModel] from a sqflite cache row plus its item rows.
  factory OrderModel.fromCacheRow(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> itemRows,
  ) =>
      OrderModel(
        id: row['id'] as int,
        orderNumber: row['order_number'] as String,
        status: row['status'] as String,
        totalAmount: (row['total_amount'] as num).toDouble(),
        items: itemRows.map(OrderItemModel.fromCacheRow).toList(),
      );

  /// Converts to a sqflite row map; items are stored in a separate table.
  Map<String, dynamic> toCacheRow() => {
        'id': id,
        'order_number': orderNumber,
        'status': status,
        'total_amount': totalAmount,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      };

  /// Maps the raw backend status string to the domain [OrderStatus] enum.
  OrderStatus get orderStatus => switch (status.toUpperCase()) {
        'PENDING' => OrderStatus.pending,
        'CONFIRMED' => OrderStatus.confirmed,
        'CANCELLED' => OrderStatus.cancelled,
        _ => OrderStatus.unknown,
      };

  /// Converts to domain entity.
  Order toEntity() => Order(
        id: id,
        orderNumber: orderNumber,
        status: orderStatus,
        totalAmount: totalAmount,
        items: items.map((i) => i.toEntity()).toList(),
      );
}
