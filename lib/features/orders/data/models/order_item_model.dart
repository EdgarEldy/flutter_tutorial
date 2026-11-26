import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order.dart';

part 'order_item_model.freezed.dart';
part 'order_item_model.g.dart';

/// Freezed model mapping the backend OrderItemResponse JSON object.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@freezed
abstract class OrderItemModel with _$OrderItemModel {
  const OrderItemModel._();

  const factory OrderItemModel({
    required int id,
    @JsonKey(name: 'product_id') required int productId,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required int quantity,
    required double subtotal,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  /// Reconstructs an [OrderItemModel] from a sqflite cache row.
  factory OrderItemModel.fromCacheRow(Map<String, dynamic> row) =>
      OrderItemModel(
        id: row['id'] as int,
        productId: row['product_id'] as int,
        productName: row['product_name'] as String,
        unitPrice: (row['unit_price'] as num).toDouble(),
        quantity: row['quantity'] as int,
        subtotal: (row['subtotal'] as num).toDouble(),
      );

  /// Converts to a sqflite row map; [orderId] must be injected by caller.
  Map<String, dynamic> toCacheRow(int orderId) => {
        'id': id,
        'order_id': orderId,
        'product_id': productId,
        'product_name': productName,
        'unit_price': unitPrice,
        'quantity': quantity,
        'subtotal': subtotal,
      };

  /// Converts to domain entity.
  OrderItem toEntity() => OrderItem(
        id: id,
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity,
        subtotal: subtotal,
      );
}
