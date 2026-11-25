import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/category.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

/// Freezed model mapping the backend CategoryResponse JSON object.
/// Only id and category_name are used; products list is ignored on mobile.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@freezed
abstract class CategoryModel with _$CategoryModel {
  const CategoryModel._();

  const factory CategoryModel({
    required int id,
    @JsonKey(name: 'category_name') required String categoryName,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromCacheRow(Map<String, dynamic> row) =>
      CategoryModel(
        id: row['id'] as int,
        categoryName: row['category_name'] as String,
      );

  /// Converts to domain entity.
  Category toEntity() => Category(id: id, name: categoryName);

  /// Converts to a sqflite row map.
  Map<String, dynamic> toCacheRow() => {
        'id': id,
        'category_name': categoryName,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      };
}
