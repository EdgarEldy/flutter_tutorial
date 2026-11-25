import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static const String _databaseName = 'flutter_tutorial.db';
  static const int _databaseVersion = 1;

  static Future<Database> open() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Products cache tables (phase: product-catalog)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products_cache (
        id INTEGER PRIMARY KEY,
        product_name TEXT NOT NULL,
        unit_price REAL NOT NULL,
        description TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        category_id INTEGER,
        category_name TEXT,
        cached_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_images_cache (
        id INTEGER PRIMARY KEY,
        product_id INTEGER NOT NULL,
        image_url TEXT NOT NULL,
        alt_text TEXT,
        is_primary INTEGER NOT NULL DEFAULT 0,
        display_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products_cache(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories_cache (
        id INTEGER PRIMARY KEY,
        category_name TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');
  }
}
