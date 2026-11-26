import 'package:dio/dio.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../models/product_model.dart';

/// Contract for remote product data operations via the backend API.
/// Maps directly to GET /api/v1/products and GET /api/v1/products/{id}.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class ProductRemoteDatasource {
  /// Fetches a paginated list of products with optional filters.
  Future<PaginatedResult<ProductModel>> getProducts({
    int? categoryId,
    String? productName,
    double? minPrice,
    double? maxPrice,
    int page = 0,
    int size = 20,
  });

  /// Fetches a single product by [id].
  Future<ProductModel> getProductById(int id);
}

/// Dio-backed implementation of [ProductRemoteDatasource].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ProductRemoteDatasourceImpl implements ProductRemoteDatasource {
  const ProductRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedResult<ProductModel>> getProducts({
    int? categoryId,
    String? productName,
    double? minPrice,
    double? maxPrice,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (productName != null && productName.isNotEmpty) {
      queryParams['productName'] = productName;
    }
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;

    final response = await _dio.get<Map<String, dynamic>>(
      'api/v1/products',
      queryParameters: queryParams,
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    final content = (data['content'] as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResult<ProductModel>(
      content: content,
      page: (data['page'] as num).toInt(),
      size: (data['size'] as num).toInt(),
      totalElements: (data['totalElements'] as num).toInt(),
      totalPages: (data['totalPages'] as num).toInt(),
    );
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'api/v1/products/$id',
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return ProductModel.fromJson(data);
  }
}
