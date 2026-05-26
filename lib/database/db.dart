import 'db_stub.dart'
    if (dart.library.js_interop) 'db_web.dart'
    if (dart.library.io) 'db_native.dart';

class KanjiDatabase {
  static Future<void> setStatus(int kanjiId, String status) => dbSetStatus(kanjiId, status);
  static Future<void> saveProgress(int kanjiId, bool correct) => dbSaveProgress(kanjiId, correct);
  static Future<Map<int, Map<String, dynamic>>> getAllProgress() => dbGetAllProgress();
  static Future<void> resetAllProgress() => dbResetAllProgress();
}