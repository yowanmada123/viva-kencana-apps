import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/sales_activity/submit_data.dart';

class SalesActivityLocalDatabase {
  static final SalesActivityLocalDatabase instance = SalesActivityLocalDatabase._init();
  static Database? _database;

  SalesActivityLocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sales_activity.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE customer_visit (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customerId TEXT,
      customerName TEXT,
      data TEXT
    )
    ''');
  }

  Future<int> insertActivity(SalesActivityFormData formData) async {
    final db = await instance.database;
    return await db.insert('customer_visit', {
      'customerId': formData.customerId.toString(),
      'customerName': formData.customerName,
      'data': formData.toJson(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingActivities() async {
    final db = await instance.database;
    return await db.query('customer_visit');
  }

  Future<void> deleteActivity(int id) async {
    final db = await instance.database;
    await db.delete('customer_visit', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
