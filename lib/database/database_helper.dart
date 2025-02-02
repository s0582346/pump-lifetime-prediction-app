import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {

 static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  // private constructor
   DatabaseHelper._internal();

  // initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

   Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
  
    print('Database path: $dbPath');

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // create the tables

    // create pump table
    await db.execute('''
      CREATE TABLE pump (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        type TEXT NOT NULL,
        medium TEXT NOT NULL,
        measurableParameter TEXT NOT NULL,
        permissibleTotalWear INTEGER NOT NULL
        solidConcentration INTEGER
      )
    ''');

    // create measurement table
    await db.execute('''
      CREATE TABLE measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        date TEXT NOT NULL,
        volumeFlow INTEGER,
        pressure INTEGER,
        rotationalFrequency INTEGER NOT NULL,
        currentOperatingHours INTEGER,
        averageOperatingHoursPerDay INTEGER
        FOREIGN KEY (adjustment_id) REFERENCES adjustment(id)
      )
    ''');

    // create adjustment table
    await db.execute(
      '''
      CREATE TABLE adjustment (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        date TEXT NOT NULL,
        pump_id INT NOT NULL,
        FOREIGN KEY (pump_id) REFERENCES pump(id)
      )
      '''
    );
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table, 
      data, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
}