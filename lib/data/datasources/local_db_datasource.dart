// lib/data/datasources/local_db_datasource.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/meal.dart';
import '../../core/constants/app_constants.dart';

class LocalDbDatasource {
  static Database? _db;

  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError('SQLite is not supported on Web');
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbFileName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.favouritesTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT,
        area TEXT,
        instructions TEXT,
        thumbnail TEXT,
        tags TEXT,
        youtubeUrl TEXT,
        sourceUrl TEXT,
        ingredients TEXT,
        savedAt INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');
  }

  // Save favourite
  Future<void> saveFavourite(Meal meal) async {
    if (kIsWeb) return;
    final db = await database;
    await db.insert(
      AppConstants.favouritesTable,
      meal.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Remove favourite
  Future<void> removeFavourite(String id) async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete(
      AppConstants.favouritesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if favourite
  Future<bool> isFavourite(String id) async {
    if (kIsWeb) return false;
    final db = await database;
    final result = await db.query(
      AppConstants.favouritesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Get all favourites
  Future<List<Meal>> getFavourites() async {
    if (kIsWeb) return [];
    final db = await database;
    final maps = await db.query(
      AppConstants.favouritesTable,
      orderBy: 'savedAt DESC',
    );
    return maps.map((m) => Meal.fromDbMap(m)).toList();
  }

  // Get favourite IDs
  Future<Set<String>> getFavouriteIds() async {
    if (kIsWeb) return {};
    final db = await database;
    final maps =
        await db.query(AppConstants.favouritesTable, columns: ['id']);
    return maps.map((m) => m['id'] as String).toSet();
  }
}
