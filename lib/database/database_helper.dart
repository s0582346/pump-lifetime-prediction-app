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

    // create pumps table
    await db.execute('''
      CREATE TABLE pumps (
        date TEXT NOT NULL,
        id TEXT PRIMARY KEY NOT NULL,
        type TEXT NOT NULL,
        name TEXT,
        rotorGeometry TEXT,
        numberOfStages TEXT,
        speedChange TEXT,
        medium TEXT,
        viscosityLevel TEXT,
        measurableParameter TEXT NOT NULL,
        permissibleTotalWear INTEGER NOT NULL,
        typeOfTimeEntry TEXT NOT NULL,
        solidConcentration INTEGER
      )
    ''');

    // create measurements table
    await db.execute('''
      CREATE TABLE measurements (
        id TEXT PRIMARY KEY NOT NULL,
        adjustmentId TEXT NOT NULL,
        date TEXT NOT NULL,
        volumeFlow INTEGER,
        pressure INTEGER,
        rotationalFrequency INTEGER NOT NULL,
        Qn INTEGER,
        pn INTEGER,
        QnTotal INTEGER,
        pnTotal INTEGER,
        currentOperatingHours INTEGER,  
        averageOperatingHoursPerDay INTEGER,
        FOREIGN KEY (adjustmentId) REFERENCES adjustments(id) ON DELETE CASCADE
      )
    ''');

    // create adjustments table
    await db.execute(
      '''
      CREATE TABLE adjustments (
        id TEXT PRIMARY KEY NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL,
        pumpId TEXT NOT NULL,
        FOREIGN KEY (pumpId) REFERENCES pumps(id) ON DELETE CASCADE
      )
      '''
    );

    // create predictions table
    await db.execute('''
      CREATE TABLE predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        adjustmentId TEXT NOT NULL,
        date TEXT NOT NULL,
        estimatedOperatingHours INTEGER,
        estimatedMaintenanceDate INTEGER,
        residualWear INTEGER,
        a REAL,
        b REAL,
        c REAL,
        FOREIGN KEY (adjustmentId) REFERENCES adjustments(id) ON DELETE CASCADE
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