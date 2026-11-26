/// Status values returned by the backend for an order.
enum OrderStatus { pending, confirmed, cancelled, unknown }

/// Domain entity representing a customer order.
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
