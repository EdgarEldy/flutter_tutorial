import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/cart.dart';
import 'cart_item_model.dart';

part 'cart_model.freezed.dart';
part 'cart_model.g.dart';

/// Freezed model mapping to CartResponse from the backend API.
/// The backend field for the total is `total` (not `total_amount`).
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@freezed
abstract class CartModel with _$CartModel {
  const CartModel._();

  const factory CartModel({
    required int id,
    @Default([]) List<CartItemModel> items,
    @JsonKey(name: 'total') required double totalAmount,
  }) = _CartModel;

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  /// Converts to domain entity; keeps data layer concerns out of domain.
  Cart toEntity() => Cart(
        id: id,
        items: items.map((i) => i.toEntity()).toList(),
        totalAmount: totalAmount,
      );
}
