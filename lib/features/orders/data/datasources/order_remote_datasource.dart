import 'package:dio/dio.dart';
import '../models/order_model.dart';

/// Contract for remote order data operations via the backend API.
/// Maps directly to GET /api/v1/orders and GET /api/v1/orders/{id}.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
abstract interface class OrderRemoteDatasource {
  /// Fetches the authenticated user's paginated order list (all pages merged).
  Future<List<OrderModel>> getOrders();

  /// Fetches the detail of a single order by [id].
  Future<OrderModel> getOrderById(int id);
}

/// Dio-backed implementation of [OrderRemoteDatasource].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class OrderRemoteDatasourceImpl implements OrderRemoteDatasource {
  const OrderRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'api/v1/orders',
      queryParameters: {'page': 0, 'size': 100},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    return content
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderModel> getOrderById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'api/v1/orders/$id',
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return OrderModel.fromJson(data);
  }
}
