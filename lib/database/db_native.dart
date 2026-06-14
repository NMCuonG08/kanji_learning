import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;

Database? _database;
bool _initialized = false;

void _initFactory() {
  if (_initialized) return;
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  _initialized = true;
}

Future<Database> _getDb() async {
  if (_database != null) return _database!;
  _initFactory();
  final dbPath = await getDatabasesPath();
  _database = await openDatabase(
    join(dbPath, 'kanji_learning.db'),
    version: 7,
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
      await db.execute('''
        CREATE TABLE vocab_progress(
          vocabId INTEGER PRIMARY KEY,
          lastCorrectAt TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE listening_progress(
          questionId INTEGER PRIMARY KEY,
          completedAt TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE grammar_progress(
          questionId INTEGER PRIMARY KEY,
          completedAt TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE duolingo_progress(
          challengeId INTEGER PRIMARY KEY,
          completedAt TEXT
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE progress ADD COLUMN nextReviewAt TEXT');
      }
      if (oldVersion < 3) {
        await db.execute(
          "ALTER TABLE progress ADD COLUMN status TEXT DEFAULT 'new'",
        );
      }
      if (oldVersion < 4) {
        await db.execute('''
          CREATE TABLE vocab_progress(
            vocabId INTEGER PRIMARY KEY,
            lastCorrectAt TEXT
          )
        ''');
      }
      if (oldVersion < 5) {
        await db.execute('''
          CREATE TABLE listening_progress(
            questionId INTEGER PRIMARY KEY,
            completedAt TEXT
          )
        ''');
      }
      if (oldVersion < 6) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS grammar_progress(
            questionId INTEGER PRIMARY KEY,
            completedAt TEXT
          )
        ''');
      }
      if (oldVersion < 7) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS duolingo_progress(
            challengeId INTEGER PRIMARY KEY,
            completedAt TEXT
          )
        ''');
      }
    },
  );
  return _database!;
}

Future<void> dbSetStatus(int kanjiId, String status) async {
  final db = await _getDb();
  final now = DateTime.now();
  final nextReview = status == 'learned'
      ? now.add(const Duration(days: 5))
      : now.add(const Duration(hours: 1));
  final existing = await db.query(
    'progress',
    where: 'kanjiId = ?',
    whereArgs: [kanjiId],
  );
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
    await db.update(
      'progress',
      {
        'status': status,
        'lastReviewed': now.toIso8601String(),
        'nextReviewAt': nextReview.toIso8601String(),
      },
      where: 'kanjiId = ?',
      whereArgs: [kanjiId],
    );
  }
}

Future<void> dbSaveProgress(int kanjiId, bool correct) async {
  final db = await _getDb();
  final existing = await db.query(
    'progress',
    where: 'kanjiId = ?',
    whereArgs: [kanjiId],
  );
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
    mastery = correct ? (mastery + 1).clamp(0, 5) : (mastery - 1).clamp(0, 5);
    await db.update(
      'progress',
      {
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'lastReviewed': now.toIso8601String(),
        'masteryLevel': mastery,
        'nextReviewAt': nextReview.toIso8601String(),
      },
      where: 'kanjiId = ?',
      whereArgs: [kanjiId],
    );
  }
}

Future<Map<int, Map<String, dynamic>>> dbGetAllProgress() async {
  final db = await _getDb();
  final rows = await db.query('progress');
  final result = <int, Map<String, dynamic>>{};
  for (final row in rows) {
    result[row['kanjiId'] as int] = row;
  }
  return result;
}

Future<void> dbResetAllProgress() async {
  final db = await _getDb();
  await db.delete('progress');
}

Future<void> dbSaveVocabProgress(int vocabId) async {
  final db = await _getDb();
  final now = DateTime.now().toIso8601String();
  await db.insert('vocab_progress', {
    'vocabId': vocabId,
    'lastCorrectAt': now,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<Map<int, String>> dbGetVocabProgress() async {
  final db = await _getDb();
  final List<Map<String, dynamic>> rows = await db.query('vocab_progress');
  final result = <int, String>{};
  for (final row in rows) {
    result[row['vocabId'] as int] = row['lastCorrectAt'] as String;
  }
  return result;
}

Future<void> dbDeleteVocabProgress(int vocabId) async {
  final db = await _getDb();
  await db.delete('vocab_progress', where: 'vocabId = ?', whereArgs: [vocabId]);
}

Future<void> dbResetVocabProgress() async {
  final db = await _getDb();
  await db.delete('vocab_progress');
}

Future<void> dbSaveListeningProgress(int questionId) async {
  final db = await _getDb();
  final now = DateTime.now().toIso8601String();
  await db.insert('listening_progress', {
    'questionId': questionId,
    'completedAt': now,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<int>> dbGetListeningProgress() async {
  final db = await _getDb();
  final List<Map<String, dynamic>> rows = await db.query('listening_progress');
  return rows.map((row) => row['questionId'] as int).toList();
}

Future<void> dbResetListeningProgress() async {
  final db = await _getDb();
  await db.delete('listening_progress');
}

Future<void> dbSaveGrammarProgress(int questionId) async {
  final db = await _getDb();
  final now = DateTime.now().toIso8601String();
  await db.insert('grammar_progress', {
    'questionId': questionId,
    'completedAt': now,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<int>> dbGetGrammarProgress() async {
  final db = await _getDb();
  final List<Map<String, dynamic>> rows = await db.query('grammar_progress');
  return rows.map((row) => row['questionId'] as int).toList();
}

Future<void> dbResetGrammarProgress() async {
  final db = await _getDb();
  await db.delete('grammar_progress');
}

Future<void> dbSaveDuolingoProgress(int challengeId) async {
  final db = await _getDb();
  final now = DateTime.now().toIso8601String();
  await db.insert('duolingo_progress', {
    'challengeId': challengeId,
    'completedAt': now,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<int>> dbGetDuolingoProgress() async {
  final db = await _getDb();
  final List<Map<String, dynamic>> rows = await db.query('duolingo_progress');
  return rows.map((row) => row['challengeId'] as int).toList();
}

Future<void> dbResetDuolingoProgress() async {
  final db = await _getDb();
  await db.delete('duolingo_progress');
}
