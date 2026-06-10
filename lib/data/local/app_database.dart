import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tarify.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'Kolay',
        prepMinutes INTEGER NOT NULL,
        cookMinutes INTEGER NOT NULL,
        servings INTEGER NOT NULL,
        ingredients TEXT NOT NULL,
        steps TEXT NOT NULL,
        tips TEXT NOT NULL,
        notes TEXT NOT NULL,
        imagePath TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE recent_views (
        recipeId INTEGER PRIMARY KEY,
        viewedAt INTEGER NOT NULL,
        FOREIGN KEY (recipeId) REFERENCES recipes(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE recipes ADD COLUMN difficulty TEXT NOT NULL DEFAULT 'Kolay'",
      );
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE recent_views (
          recipeId INTEGER PRIMARY KEY,
          viewedAt INTEGER NOT NULL,
          FOREIGN KEY (recipeId) REFERENCES recipes(id) ON DELETE CASCADE
        )
      ''');
    }
  }
}