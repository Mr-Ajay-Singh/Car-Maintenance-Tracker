import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'psoriasis_tracker.db');
    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create existing fiber_intakes table
    await db.execute('''
      CREATE TABLE fiber_intakes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT NOT NULL,
        itemName TEXT NOT NULL,
        fiberAmount REAL NOT NULL
      )
    ''');

  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

  }

}
