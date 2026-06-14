import 'dart:async';

import '../services/api_service.dart';
import 'db_stub.dart'
    if (dart.library.io) 'db_native.dart'
    if (dart.library.html) 'db_web.dart'
    as local_db;

class KanjiDatabase {
  static void _syncInBackground(Future<void> Function() action) {
    if (!ApiService.isLoggedIn.value) return;
    unawaited(() async {
      try {
        await action();
      } catch (_) {
        // Local progress is already saved; sync can retry on the next action.
      }
    }());
  }

  static Future<void> setStatus(int kanjiId, String status) async {
    await local_db.dbSetStatus(kanjiId, status);
    final entry = (await local_db.dbGetAllProgress())[kanjiId];
    if (entry != null) {
      _syncInBackground(() => ApiService.saveKanjiProgress(entry));
    }
  }

  static Future<void> saveProgress(int kanjiId, bool correct) async {
    await local_db.dbSaveProgress(kanjiId, correct);
    final entry = (await local_db.dbGetAllProgress())[kanjiId];
    if (entry != null) {
      _syncInBackground(() => ApiService.saveKanjiProgress(entry));
    }
  }

  static Future<Map<int, Map<String, dynamic>>> getAllProgress() async {
    final local = await local_db.dbGetAllProgress();
    if (!ApiService.isLoggedIn.value) return local;

    final remote = await ApiService.getKanjiProgress();
    return {...remote, ...local};
  }

  static Future<void> resetAllProgress() async {
    await local_db.dbResetAllProgress();
    _syncInBackground(ApiService.resetAllProgress);
  }

  static Future<void> saveVocabProgress(int vocabId) =>
      _saveVocabProgress(vocabId);

  static Future<void> _saveVocabProgress(int vocabId) async {
    await local_db.dbSaveVocabProgress(vocabId);
    final timestamp = (await local_db.dbGetVocabProgress())[vocabId];
    if (timestamp != null) {
      _syncInBackground(() => ApiService.saveVocabProgress(vocabId, timestamp));
    }
  }

  static Future<Map<int, String>> getVocabProgress() async {
    final local = await local_db.dbGetVocabProgress();
    if (!ApiService.isLoggedIn.value) return local;

    final remote = await ApiService.getVocabProgress();
    return {...remote, ...local};
  }

  static Future<void> deleteVocabProgress(int vocabId) async {
    await local_db.dbDeleteVocabProgress(vocabId);
    _syncInBackground(() => ApiService.deleteVocabProgress(vocabId));
  }

  static Future<void> resetVocabProgress() => local_db.dbResetVocabProgress();

  static Future<void> saveListeningProgress(int questionId) async {
    await local_db.dbSaveListeningProgress(questionId);
    _syncInBackground(() => ApiService.saveListeningProgress(questionId));
  }

  static Future<List<int>> getListeningProgress() async {
    final ids = <int>{...(await local_db.dbGetListeningProgress())};
    if (ApiService.isLoggedIn.value) {
      ids.addAll(await ApiService.getListeningProgress());
    }
    return ids.toList();
  }

  static Future<void> resetListeningProgress() =>
      local_db.dbResetListeningProgress();

  static Future<void> saveGrammarProgress(int questionId) async {
    await local_db.dbSaveGrammarProgress(questionId);
    _syncInBackground(() => ApiService.saveGrammarProgress(questionId));
  }

  static Future<List<int>> getGrammarProgress() async {
    final ids = <int>{...(await local_db.dbGetGrammarProgress())};
    if (ApiService.isLoggedIn.value) {
      ids.addAll(await ApiService.getGrammarProgress());
    }
    return ids.toList();
  }

  static Future<void> resetGrammarProgress() =>
      local_db.dbResetGrammarProgress();

  static Future<void> saveDuolingoProgress(int challengeId) async {
    await local_db.dbSaveDuolingoProgress(challengeId);
    _syncInBackground(() => ApiService.saveDuolingoProgress(challengeId));
  }

  static Future<List<int>> getDuolingoProgress() async {
    final ids = <int>{...(await local_db.dbGetDuolingoProgress())};
    if (ApiService.isLoggedIn.value) {
      ids.addAll(await ApiService.getDuolingoProgress());
    }
    return ids.toList();
  }

  static Future<void> resetDuolingoProgress() =>
      local_db.dbResetDuolingoProgress();
}
