import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// Freezed model mapping the backend ProductImageResponse JSON object.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@freezed
abstract class ProductImageModel with _$ProductImageModel {
  const ProductImageModel._();

  const factory ProductImageModel({
    required int id,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'alt_text') String? altText,
    @JsonKey(name: 'is_primary') required bool isPrimary,
    @JsonKey(name: 'display_order') required int displayOrder,
  }) = _ProductImageModel;

  factory ProductImageModel.fromJson(Map<String, dynamic> json) =>
      _$ProductImageModelFromJson(json);

  factory ProductImageModel.fromCacheRow(Map<String, dynamic> row) =>
      ProductImageModel(
        id: row['id'] as int,
        imageUrl: row['image_url'] as String,
        altText: row['alt_text'] as String?,
        isPrimary: (row['is_primary'] as int) == 1,
        displayOrder: row['display_order'] as int,
      );

  /// Converts to domain entity.
  ProductImage toEntity() => ProductImage(
        id: id,
        imageUrl: imageUrl,
        altText: altText,
        isPrimary: isPrimary,
        displayOrder: displayOrder,
      );

  /// Converts to a sqflite row map; product_id must be injected by caller.
  Map<String, dynamic> toCacheRow(int productId) => {
        'id': id,
        'product_id': productId,
        'image_url': imageUrl,
        'alt_text': altText,
        'is_primary': isPrimary ? 1 : 0,
        'display_order': displayOrder,
      };
}

/// Freezed model mapping the backend ProductResponse JSON object.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@freezed
abstract class ProductModel with _$ProductModel {
  const ProductModel._();

  const factory ProductModel({
    required int id,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'unit_price') required double unitPrice,
    String? description,
    required bool active,
    @JsonKey(name: 'category_id') int? categoryId,
    @JsonKey(name: 'category_name') String? categoryName,
    @Default([]) List<ProductImageModel> images,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  factory ProductModel.fromCacheRow(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> imageRows,
  ) =>
      ProductModel(
        id: row['id'] as int,
        productName: row['product_name'] as String,
        unitPrice: (row['unit_price'] as num).toDouble(),
        description: row['description'] as String?,
        active: (row['active'] as int) == 1,
        categoryId: row['category_id'] as int?,
        categoryName: row['category_name'] as String?,
        images: imageRows.map(ProductImageModel.fromCacheRow).toList(),
      );

  /// Converts to domain entity.
  Product toEntity() => Product(
        id: id,
        name: productName,
        unitPrice: unitPrice,
        description: description,
        active: active,
        categoryId: categoryId,
        categoryName: categoryName,
        images: images.map((i) => i.toEntity()).toList(),
      );

  /// Converts to a sqflite row map; images are stored separately.
  Map<String, dynamic> toCacheRow() => {
        'id': id,
        'product_name': productName,
        'unit_price': unitPrice,
        'description': description,
        'active': active ? 1 : 0,
        'category_id': categoryId,
        'category_name': categoryName,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      };
}
