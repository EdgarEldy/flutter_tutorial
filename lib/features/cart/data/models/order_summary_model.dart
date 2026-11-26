import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order_summary.dart';

part 'order_summary_model.freezed.dart';
part 'order_summary_model.g.dart';

/// Freezed model mapping to OrderResponse from POST /api/v1/orders.
/// Only the fields needed for the checkout confirmation screen.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
@freezed
abstract class OrderSummaryModel with _$OrderSummaryModel {
  const OrderSummaryModel._();

  const factory OrderSummaryModel({
    required int id,
    required String status,
    @JsonKey(name: 'total_amount') required double totalAmount,
  }) = _OrderSummaryModel;

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryModelFromJson(json);

  /// Converts to domain entity; keeps data layer concerns out of domain.
  OrderSummary toEntity() => OrderSummary(
        id: id,
        status: status,
        totalAmount: totalAmount,
      );
}
