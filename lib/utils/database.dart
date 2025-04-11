import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ppb_repository/model/transaction.model.dart' as app_model;

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

    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${app_model.tableName}(
        ${app_model.idField} ${app_model.idType},
        ${app_model.titleField} ${app_model.textType},
        ${app_model.amountField} ${app_model.doubleType},
        ${app_model.dateField} ${app_model.textType},
        ${app_model.typeField} ${app_model.textType}
      )
    ''');
  }

  Future<void> insertTransaction(app_model.Transaction transaction) async {
    final db = await instance.database;
    await db.insert(
      app_model.tableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTransaction(app_model.Transaction transaction) async {
    final db = await instance.database;
    await db.update(
      app_model.tableName,
      transaction.toMap(),
      where: '${app_model.idField} = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await instance.database;
    await db.delete(
      app_model.tableName,
      where: '${app_model.idField} = ?',
      whereArgs: [id],
    );
  }

  Future<List<app_model.Transaction>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query(app_model.tableName);
    return result.map((json) => app_model.Transaction.fromJson(json)).toList();
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
