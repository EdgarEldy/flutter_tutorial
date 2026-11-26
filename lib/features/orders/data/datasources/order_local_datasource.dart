import 'package:sqflite/sqflite.dart';
import '../models/order_model.dart';

/// Contract for local sqflite access to cached orders and their items.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
abstract interface class OrderLocalDatasource {
  /// Returns all cached order rows ordered by id descending.
  Future<List<Map<String, dynamic>>> getOrders();

  /// Replaces the full orders cache in a single transaction.
  Future<void> upsertOrders(List<OrderModel> models);

  /// Clears the entire orders cache (orders and their items).
  Future<void> deleteAllOrders();

  /// Returns one order row by [id], or null if not cached.
  Future<Map<String, dynamic>?> getOrderById(int id);

  /// Returns the cached item rows for a given [orderId].
  Future<List<Map<String, dynamic>>> getOrderItems(int orderId);
}

/// sqflite-backed implementation of [OrderLocalDatasource].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class OrderLocalDatasourceImpl implements OrderLocalDatasource {
  const OrderLocalDatasourceImpl(this._db);

  final Database _db;

  @override
  Future<List<Map<String, dynamic>>> getOrders() async {
    return _db.query('orders_cache', orderBy: 'id DESC');
  }

  @override
  Future<void> upsertOrders(List<OrderModel> models) async {
    await _db.transaction((txn) async {
      await txn.delete('order_items_cache');
      await txn.delete('orders_cache');
      for (final model in models) {
        await txn.insert(
          'orders_cache',
          model.toCacheRow(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        for (final item in model.items) {
          await txn.insert(
            'order_items_cache',
            item.toCacheRow(model.id),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  @override
  Future<void> deleteAllOrders() async {
    await _db.transaction((txn) async {
      await txn.delete('order_items_cache');
      await txn.delete('orders_cache');
    });
  }

  @override
  Future<Map<String, dynamic>?> getOrderById(int id) async {
    final rows = await _db.query(
      'orders_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    return _db.query(
      'order_items_cache',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }
}
