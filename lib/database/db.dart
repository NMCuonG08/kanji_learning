import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class KanjiDatabase {
  static Database? _database;
  static bool _initialized = false;

  static void _initFactory() {
    if (_initialized) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _initFactory();
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'kanji_learning.db'),
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE progress(
            kanjiId INTEGER PRIMARY KEY,
            correctCount INTEGER DEFAULT 0,
            wrongCount INTEGER DEFAULT 0,
            lastReviewed TEXT,
            masteryLevel INTEGER DEFAULT 0,
            nextReviewAt TEXT,
            status TEXT DEFAULT 'new'
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE progress ADD COLUMN nextReviewAt TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE progress ADD COLUMN status TEXT DEFAULT \'new\'');
        }
      },
    );
  }

  // status: 'new', 'learning', 'learned'
  static Future<void> setStatus(int kanjiId, String status) async {
    final db = await database;
    final now = DateTime.now();
    final nextReview = status == 'learned'
        ? now.add(const Duration(days: 5))
        : now.add(const Duration(hours: 1));

    final existing = await db.query('progress', where: 'kanjiId = ?', whereArgs: [kanjiId]);
    if (existing.isEmpty) {
      await db.insert('progress', {
        'kanjiId': kanjiId,
        'correctCount': 0,
        'wrongCount': 0,
        'lastReviewed': now.toIso8601String(),
        'masteryLevel': 0,
        'nextReviewAt': nextReview.toIso8601String(),
        'status': status,
      });
    } else {
      await db.update('progress', {
        'status': status,
        'lastReviewed': now.toIso8601String(),
        'nextReviewAt': nextReview.toIso8601String(),
      }, where: 'kanjiId = ?', whereArgs: [kanjiId]);
    }
  }

  static Future<void> saveProgress(int kanjiId, bool correct) async {
    final db = await database;
    final existing = await db.query('progress', where: 'kanjiId = ?', whereArgs: [kanjiId]);

    final now = DateTime.now();
    final nextReview = correct
        ? now.add(const Duration(hours: 24))
        : now.add(const Duration(hours: 1));

    if (existing.isEmpty) {
      await db.insert('progress', {
        'kanjiId': kanjiId,
        'correctCount': correct ? 1 : 0,
        'wrongCount': correct ? 0 : 1,
        'lastReviewed': now.toIso8601String(),
        'masteryLevel': correct ? 1 : 0,
        'nextReviewAt': nextReview.toIso8601String(),
        'status': 'learning',
      });
    } else {
      final row = existing.first;
      int correctCount = (row['correctCount'] as int) + (correct ? 1 : 0);
      int wrongCount = (row['wrongCount'] as int) + (correct ? 0 : 1);
      int mastery = row['masteryLevel'] as int;
      if (correct) {
        mastery = (mastery + 1).clamp(0, 5);
      } else {
        mastery = (mastery - 1).clamp(0, 5);
      }
      await db.update('progress', {
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'lastReviewed': now.toIso8601String(),
        'masteryLevel': mastery,
        'nextReviewAt': nextReview.toIso8601String(),
      }, where: 'kanjiId = ?', whereArgs: [kanjiId]);
    }
  }

  static Future<Map<int, Map<String, dynamic>>> getAllProgress() async {
    final db = await database;
    final rows = await db.query('progress');
    final result = <int, Map<String, dynamic>>{};
    for (final row in rows) {
      result[row['kanjiId'] as int] = row;
    }
    return result;
  }

  static Future<void> resetAllProgress() async {
    final db = await database;
    await db.delete('progress');
  }
}