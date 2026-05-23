import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/session_log.dart';
import '../models/breathing_pattern.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'respiro.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE session_logs(
        id TEXT PRIMARY KEY,
        patternId TEXT,
        durationSeconds INTEGER,
        timestamp TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE custom_patterns(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        inhaleSeconds INTEGER,
        holdInSeconds INTEGER,
        exhaleSeconds INTEGER,
        holdOutSeconds INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE custom_patterns(
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          inhaleSeconds INTEGER,
          holdInSeconds INTEGER,
          exhaleSeconds INTEGER,
          holdOutSeconds INTEGER
        )
      ''');
    }
  }

  // Insert a custom breathing pattern
  Future<int> insertCustomPattern(BreathingPattern pattern) async {
    final db = await database;
    return await db.insert(
      'custom_patterns',
      pattern.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all custom breathing patterns
  Future<List<BreathingPattern>> getCustomPatterns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('custom_patterns');
    return List.generate(maps.length, (i) => BreathingPattern.fromMap(maps[i]));
  }

  // Delete a custom breathing pattern by ID
  Future<int> deleteCustomPattern(String id) async {
    final db = await database;
    return await db.delete(
      'custom_patterns',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insert a completed breathing session log
  Future<int> insertSessionLog(SessionLog log) async {
    final db = await database;
    return await db.insert(
      'session_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all logged sessions sorted by descending date
  Future<List<SessionLog>> getAllSessionLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'session_logs',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => SessionLog.fromMap(maps[i]));
  }

  // Clear all breathing session records
  Future<int> clearAllData() async {
    final db = await database;
    // Wipe both tables to keep safety complete
    await db.delete('custom_patterns');
    return await db.delete('session_logs');
  }

  // Calculate total seconds of breathing logged
  Future<int> getTotalBreathingSeconds() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(durationSeconds) as total FROM session_logs');
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
    }
    return 0;
  }

  // Fetch unique dates on which user practiced to compute daily streak
  Future<List<String>> getUniquePracticeDates() async {
    final db = await database;
    // Extract unique YYYY-MM-DD strings
    final result = await db.rawQuery(
      "SELECT DISTINCT SUBSTR(timestamp, 1, 10) as practice_date FROM session_logs ORDER BY practice_date DESC"
    );
    return List<String>.from(result.map((row) => row['practice_date'] as String));
  }
}
