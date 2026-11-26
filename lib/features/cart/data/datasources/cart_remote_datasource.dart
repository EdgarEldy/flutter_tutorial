import 'package:dio/dio.dart';
import '../../domain/entities/order_summary.dart';
import '../models/order_summary_model.dart';
import '../../domain/usecases/checkout_use_case.dart';
import '../models/cart_model.dart';

/// Contract for remote cart data operations via the backend API.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
abstract interface class CartRemoteDatasource implements CheckoutDatasource {
  /// Fetches the authenticated user's cart.
  Future<CartModel> getCart();

  /// Adds [quantity] units of [productId] to the cart.
  Future<CartModel> addItem(int productId, int quantity);

  /// Updates the quantity of cart item [itemId].
  Future<CartModel> updateItem(int itemId, int quantity);

  /// Removes cart item [itemId] from the cart.
  Future<CartModel> removeItem(int itemId);

  /// Clears all items from the cart.
  Future<CartModel> clearCart();
}

/// Dio-backed implementation of [CartRemoteDatasource].
/// All paths follow the base URL convention: no leading slash.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class CartRemoteDatasourceImpl implements CartRemoteDatasource {
  const CartRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  CartModel _parseCart(Response<Map<String, dynamic>> response) {
    final data = response.data!['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }

  @override
  Future<CartModel> getCart() async {
    final response = await _dio.get<Map<String, dynamic>>('api/v1/cart');
    return _parseCart(response);
  }

  @override
  Future<CartModel> addItem(int productId, int quantity) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v1/cart/items',
      data: {'product_id': productId, 'quantity': quantity},
    );
    return _parseCart(response);
  }

  @override
  Future<CartModel> updateItem(int itemId, int quantity) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'api/v1/cart/items/$itemId',
      data: {'quantity': quantity},
    );
    return _parseCart(response);
  }

  @override
  Future<CartModel> removeItem(int itemId) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      'api/v1/cart/items/$itemId',
    );
    return _parseCart(response);
  }

  @override
  Future<CartModel> clearCart() async {
    final response = await _dio.delete<Map<String, dynamic>>(
      'api/v1/cart/items',
    );
    return _parseCart(response);
  }

  @override
  Future<OrderSummary> checkout() async {
    final response = await _dio.post<Map<String, dynamic>>('api/v1/orders');
    final data = response.data!['data'] as Map<String, dynamic>;
    return OrderSummaryModel.fromJson(data).toEntity();
  }
}
