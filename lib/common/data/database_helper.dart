import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// DatabaseHelper - Singleton class for all database operations
///
/// Centralized access to SQLite database for offline-first storage
/// Following CLAUDE.md guidelines: All database operations must go through this class
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'car_maintenance_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create vehicles table
    await db.execute('''
      CREATE TABLE vehicles (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        vin TEXT,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        trim TEXT,
        year INTEGER NOT NULL,
        licensePlate TEXT,
        currentOdometer INTEGER NOT NULL DEFAULT 0,
        fuelType TEXT NOT NULL,
        purchaseDate TEXT,
        estimatedValue REAL,
        tags TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        isSynced INTEGER NOT NULL DEFAULT 0,
        firebaseId TEXT,
        lastSyncedAt TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_vehicles_userId ON vehicles(userId)');
    await db.execute('CREATE INDEX idx_vehicles_isSynced ON vehicles(isSynced)');

    // Create service_entries table
    await db.execute('''
      CREATE TABLE service_entries (
        id TEXT PRIMARY KEY,
        vehicleId TEXT NOT NULL,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        odometer INTEGER NOT NULL,
        serviceType TEXT NOT NULL,
        parts TEXT,
        totalCost REAL NOT NULL,
        shopId TEXT,
        shopName TEXT,
        notes TEXT,
        receiptUrls TEXT,
        warrantyCovered INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        isSynced INTEGER NOT NULL DEFAULT 0,
        firebaseId TEXT,
        lastSyncedAt TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
      )
    ''');
    await db.execute('CREATE INDEX idx_service_entries_vehicleId ON service_entries(vehicleId)');
    await db.execute('CREATE INDEX idx_service_entries_userId ON service_entries(userId)');
    await db.execute('CREATE INDEX idx_service_entries_isSynced ON service_entries(isSynced)');
    await db.execute('CREATE INDEX idx_service_entries_date ON service_entries(date DESC)');

    // Create fuel_entries table
    await db.execute('''
      CREATE TABLE fuel_entries (
        id TEXT PRIMARY KEY,
        vehicleId TEXT NOT NULL,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        odometer INTEGER NOT NULL,
        volume REAL NOT NULL,
        cost REAL NOT NULL,
        pricePerUnit REAL NOT NULL,
        stationName TEXT,
        fuelType TEXT NOT NULL,
        isFullTank INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        isSynced INTEGER NOT NULL DEFAULT 0,
        firebaseId TEXT,
        lastSyncedAt TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
      )
    ''');
    await db.execute('CREATE INDEX idx_fuel_entries_vehicleId ON fuel_entries(vehicleId)');
    await db.execute('CREATE INDEX idx_fuel_entries_userId ON fuel_entries(userId)');
    await db.execute('CREATE INDEX idx_fuel_entries_isSynced ON fuel_entries(isSynced)');
    await db.execute('CREATE INDEX idx_fuel_entries_date ON fuel_entries(date DESC)');

    // Create reminders table
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        vehicleId TEXT NOT NULL,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        dueOdometer INTEGER,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurrenceType TEXT,
        recurrenceWeekdays TEXT,
        recurrenceMonthDay INTEGER,
        recurringDays INTEGER,
        recurringOdometer INTEGER,
        notificationEnabled INTEGER NOT NULL DEFAULT 1,
        notificationDaysBefore INTEGER NOT NULL DEFAULT 7,
        notificationOdometerBefore INTEGER NOT NULL DEFAULT 500,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        isSynced INTEGER NOT NULL DEFAULT 0,
        firebaseId TEXT,
        lastSyncedAt TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
      )
    ''');
    await db.execute('CREATE INDEX idx_reminders_vehicleId ON reminders(vehicleId)');
    await db.execute('CREATE INDEX idx_reminders_userId ON reminders(userId)');
    await db.execute('CREATE INDEX idx_reminders_isSynced ON reminders(isSynced)');
    await db.execute('CREATE INDEX idx_reminders_dueDate ON reminders(dueDate)');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        vehicleId TEXT NOT NULL,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL DEFAULT 'USD',
        description TEXT,
        vendor TEXT,
        notes TEXT,
        receiptUrls TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringPeriod TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        isSynced INTEGER NOT NULL DEFAULT 0,
        firebaseId TEXT,
        lastSyncedAt TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
      )
    ''');
    await db.execute('CREATE INDEX idx_expenses_vehicleId ON expenses(vehicleId)');
    await db.execute('CREATE INDEX idx_expenses_userId ON expenses(userId)');
    await db.execute('CREATE INDEX idx_expenses_isSynced ON expenses(isSynced)');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date DESC)');
    await db.execute('CREATE INDEX idx_expenses_category ON expenses(category)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for enhanced recurrence
      await db.execute('ALTER TABLE reminders ADD COLUMN recurrenceType TEXT');
      await db.execute('ALTER TABLE reminders ADD COLUMN recurrenceWeekdays TEXT');
      await db.execute('ALTER TABLE reminders ADD COLUMN recurrenceMonthDay INTEGER');
    }
  }

  // Utility methods
  Future<void> deleteAllUserData(String userId) async {
    final db = await database;
    await db.delete('vehicles', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('service_entries', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('fuel_entries', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('reminders', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('expenses', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
