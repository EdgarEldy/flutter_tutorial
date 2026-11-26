import 'package:dio/dio.dart';
import '../models/category_model.dart';

/// Contract for remote category data operations via the backend API.
/// Maps directly to GET /api/v1/categories.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class CategoryRemoteDatasource {
  /// Fetches the full list of categories (page size 100 to get all at once).
  Future<List<CategoryModel>> getCategories();
}

/// Dio-backed implementation of [CategoryRemoteDatasource].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  const CategoryRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'api/v1/categories',
      queryParameters: {'page': 0, 'size': 100},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    return content
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
