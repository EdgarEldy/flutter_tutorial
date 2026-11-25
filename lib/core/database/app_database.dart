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
    // Feature tables will be created here as each feature is implemented.
    // Products, cart, and orders tables are added in their respective phases.
  }
}
