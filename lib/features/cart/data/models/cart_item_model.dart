import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/cart.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

/// Freezed model mapping to CartItemResponse from the backend API.
/// Maps snake_case JSON fields to camelCase Dart fields.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@freezed
abstract class CartItemModel with _$CartItemModel {
  const CartItemModel._();

  const factory CartItemModel({
    required int id,
    @JsonKey(name: 'product_id') required int productId,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required int quantity,
    required double subtotal,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  /// Converts to domain entity; keeps data layer concerns out of domain.
  CartItem toEntity() => CartItem(
        id: id,
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity,
        subtotal: subtotal,
      );
}
