import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'carddata.db');
    print(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE carddata(id INTEGER PRIMARY KEY, type TEXT, value TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)',
        );
      },
    );
  }

  Future<void> insertCardData(String type, String value) async {
    final db = await database;
    await db.insert(
      'carddata',
      {'type': type, 'value': value, 'timestamp': DateTime.now().toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCardData(String timestamp) async {
    final db = await database;
    await db.delete('carddata', where: 'timestamp = ?', whereArgs: [timestamp]);
  }

  Future<List<Map<String, dynamic>>> fetchAllData() async {
    final db = await database;
    return await db.query('carddata');
  }

  Future<void> clearDatabase() async {
  final db = await database;
  await db.delete('carddata');
}

}