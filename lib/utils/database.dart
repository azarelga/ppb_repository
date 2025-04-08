import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String fileName = 'ppb_database.db';

class AppDatabase {
  AppDatabase._init();

  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(fileName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $idField $idType,
        $titleField $textType,
        $amountField $doubleType,
        $dateField $integerType,
        $typeFiled $textType,
      )
    ''');
  }

  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await instance.database;
    final id = await db.insert(tableName, transaction.toJson())
    await db.insert(
      tableName,
      transaction,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
