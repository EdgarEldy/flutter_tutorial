import 'package:sqflite/sqflite.dart';

/// Contract for local sqflite access to cached categories.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class CategoryLocalDatasource {
  /// Returns all cached category rows.
  Future<List<Map<String, dynamic>>> getCategories();

  /// Replaces the full categories cache in a single transaction.
  Future<void> upsertCategories(List<Map<String, dynamic>> rows);
}

/// sqflite-backed implementation of [CategoryLocalDatasource].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  const CategoryLocalDatasourceImpl(this._db);

  final Database _db;

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return _db.query('categories_cache', orderBy: 'id ASC');
  }

  @override
  Future<void> upsertCategories(List<Map<String, dynamic>> rows) async {
    await _db.transaction((txn) async {
      await txn.delete('categories_cache');
      for (final row in rows) {
        await txn.insert(
          'categories_cache',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
