import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {

 static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // this makes the class a singleton
  factory DatabaseHelper() => _instance;
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
        await db.execute('PRAGMA foreign_keys = ON'); // enable foreign keys
      },
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // create the tables

    // create pump table
    await db.execute('''
      CREATE TABLE pump (
        date TEXT NOT NULL,
        id TEXT PRIMARY KEY NOT NULL,
        type TEXT NOT NULL,
        rotorGeometry TEXT,
        statorGeometry TEXT,
        speedChange TEXT,
        medium TEXT,
        measurableParameter TEXT NOT NULL,
        permissibleTotalWear INTEGER NOT NULL,
        typeOfTimeEntry TEXT NOT NULL,
        solidConcentration INTEGER
      )
    ''');

    // create measurement table
    await db.execute('''
      CREATE TABLE measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        adjustmentId TEXT NOT NULL,
        date TEXT NOT NULL,
        volumeFlow INTEGER,
        pressure INTEGER,
        rotationalFrequency INTEGER NOT NULL,
        Qn INTEGER,
        pn INTEGER,
        currentOperatingHours INTEGER,  
        averageOperatingHoursPerDay INTEGER,
        FOREIGN KEY (adjustmentId) REFERENCES adjustment(id)
      )
    ''');

    // create adjustment table
    await db.execute(
      '''
      CREATE TABLE adjustment (
        id TEXT PRIMARY KEY NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL,
        pumpId TEXT NOT NULL,
        FOREIGN KEY (pumpId) REFERENCES pump(id)
      )
      '''
    );

    // create prediction table
    await db.execute('''
      CREATE TABLE prediction (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        adjustmentId TEXT NOT NULL,
        date TEXT NOT NULL,
        estimatedOperatingHours INTEGER,
        estimatedMaintenanceDate INTEGER,
        a REAL,
        b REAL,
        c REAL,
        FOREIGN KEY (adjustmentId) REFERENCES adjustment(id)
        )
      ''');

  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table, 
      data, 
      conflictAlgorithm: ConflictAlgorithm.replace // replace if the same data is inserted
    );
  }

  // 
}