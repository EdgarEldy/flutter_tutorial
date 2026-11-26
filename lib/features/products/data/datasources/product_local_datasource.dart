import 'package:sqflite/sqflite.dart';

/// Contract for local sqflite access to products and their images.
/// All reads return raw column maps; callers convert to models/entities.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class ProductLocalDatasource {
  /// Returns all cached product rows with their images joined.
  Future<List<Map<String, dynamic>>> getProducts();

  /// Replaces the full products cache in a single transaction.
  Future<void> upsertProducts(List<Map<String, dynamic>> rows);

  /// Clears the entire products cache.
  Future<void> deleteAllProducts();

  /// Returns one product row by [id], or null if not cached.
  Future<Map<String, dynamic>?> getProductById(int id);

  /// Returns the cached product image rows for a given product [id].
  Future<List<Map<String, dynamic>>> getProductImages(int productId);
}

/// sqflite-backed implementation of [ProductLocalDatasource].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ProductLocalDatasourceImpl implements ProductLocalDatasource {
  const ProductLocalDatasourceImpl(this._db);

  final Database _db;

  @override
  Future<List<Map<String, dynamic>>> getProducts() async {
    return _db.query('products_cache', orderBy: 'id ASC');
  }

  @override
  Future<void> upsertProducts(List<Map<String, dynamic>> rows) async {
    await _db.transaction((txn) async {
      await txn.delete('product_images_cache');
      await txn.delete('products_cache');
      for (final row in rows) {
        final images = row['images'] as List<Map<String, dynamic>>? ?? [];
        final productRow = Map<String, dynamic>.from(row)..remove('images');
        await txn.insert(
          'products_cache',
          productRow,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        for (final img in images) {
          await txn.insert(
            'product_images_cache',
            img,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  @override
  Future<void> deleteAllProducts() async {
    await _db.transaction((txn) async {
      await txn.delete('product_images_cache');
      await txn.delete('products_cache');
    });
  }

  @override
  Future<Map<String, dynamic>?> getProductById(int id) async {
    final rows = await _db.query(
      'products_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<List<Map<String, dynamic>>> getProductImages(int productId) async {
    return _db.query(
      'product_images_cache',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'display_order ASC',
    );
  }
}
