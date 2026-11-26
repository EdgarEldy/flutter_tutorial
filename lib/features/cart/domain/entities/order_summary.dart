/// Lightweight order summary returned after a successful checkout.
/// Contains only the fields needed to display the confirmation screen.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.totalAmount,
  });

  final int id;
  final String status;

  /// Server-computed total. Never recalculated on the client.
  final double totalAmount;
}
