/// Status values returned by the backend for an order.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
enum OrderStatus { pending, confirmed, cancelled, unknown }

/// Domain entity representing a customer order.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.items,
  });

  final int id;
  final String orderNumber;
  final OrderStatus status;
  final double totalAmount;
  final List<OrderItem> items;
}

/// Domain entity representing a single line item inside an order.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  final int id;
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;
}
