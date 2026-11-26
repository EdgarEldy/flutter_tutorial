// Domain entities for the shopping cart.
// Pure Dart classes with no Flutter or data-layer dependencies.

/// A single item within the user's cart.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class CartItem {
  const CartItem({
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

/// The user's shopping cart, containing items and a server-computed total.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class Cart {
  const Cart({
    required this.id,
    required this.items,
    required this.totalAmount,
  });

  final int id;
  final List<CartItem> items;

  /// Server-computed total. Never recalculated on the client.
  final double totalAmount;

  /// Total number of individual units across all items.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
