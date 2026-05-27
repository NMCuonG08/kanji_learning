import 'db_stub.dart'
    if (dart.library.js_interop) 'db_web.dart'
    if (dart.library.io) 'db_native.dart';

class KanjiDatabase {
  static Future<void> setStatus(int kanjiId, String status) => dbSetStatus(kanjiId, status);
  static Future<void> saveProgress(int kanjiId, bool correct) => dbSaveProgress(kanjiId, correct);
  static Future<Map<int, Map<String, dynamic>>> getAllProgress() => dbGetAllProgress();
  static Future<void> resetAllProgress() => dbResetAllProgress();

  static Future<void> saveVocabProgress(int vocabId) => dbSaveVocabProgress(vocabId);
  static Future<Map<int, String>> getVocabProgress() => dbGetVocabProgress();
  static Future<void> resetVocabProgress() => dbResetVocabProgress();

  static Future<void> saveListeningProgress(int questionId) => dbSaveListeningProgress(questionId);
  static Future<List<int>> getListeningProgress() => dbGetListeningProgress();
  static Future<void> resetListeningProgress() => dbResetListeningProgress();
}