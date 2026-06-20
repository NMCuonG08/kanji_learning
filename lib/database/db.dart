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
    final merged = <int, Map<String, dynamic>>{};
    final allKeys = {...local.keys, ...remote.keys};

    for (final id in allKeys) {
      final localEntry = local[id];
      final remoteEntry = remote[id];

      if (localEntry == null && remoteEntry != null) {
        await local_db.dbSaveKanjiEntry(remoteEntry);
        merged[id] = remoteEntry;
      } else if (localEntry != null && remoteEntry == null) {
        _syncInBackground(() => ApiService.saveKanjiProgress(localEntry));
        merged[id] = localEntry;
      } else if (localEntry != null && remoteEntry != null) {
        final localTimeStr = localEntry['lastReviewed'] as String?;
        final remoteTimeStr = remoteEntry['lastReviewed'] as String?;

        DateTime? localTime = localTimeStr != null ? DateTime.tryParse(localTimeStr) : null;
        DateTime? remoteTime = remoteTimeStr != null ? DateTime.tryParse(remoteTimeStr) : null;

        if (localTime == null && remoteTime != null) {
          await local_db.dbSaveKanjiEntry(remoteEntry);
          merged[id] = remoteEntry;
        } else if (localTime != null && remoteTime == null) {
          _syncInBackground(() => ApiService.saveKanjiProgress(localEntry));
          merged[id] = localEntry;
        } else if (localTime != null && remoteTime != null) {
          if (remoteTime.isAfter(localTime)) {
            await local_db.dbSaveKanjiEntry(remoteEntry);
            merged[id] = remoteEntry;
          } else if (localTime.isAfter(remoteTime)) {
            _syncInBackground(() => ApiService.saveKanjiProgress(localEntry));
            merged[id] = localEntry;
          } else {
            merged[id] = localEntry;
          }
        } else {
          merged[id] = localEntry;
        }
      }
    }
    return merged;
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
    final merged = <int, String>{};
    final allKeys = {...local.keys, ...remote.keys};

    for (final id in allKeys) {
      final localTimeStr = local[id];
      final remoteTimeStr = remote[id];

      if (localTimeStr == null && remoteTimeStr != null) {
        await local_db.dbSaveVocabEntry(id, remoteTimeStr);
        merged[id] = remoteTimeStr;
      } else if (localTimeStr != null && remoteTimeStr == null) {
        _syncInBackground(() => ApiService.saveVocabProgress(id, localTimeStr));
        merged[id] = localTimeStr;
      } else if (localTimeStr != null && remoteTimeStr != null) {
        final localTime = DateTime.tryParse(localTimeStr);
        final remoteTime = DateTime.tryParse(remoteTimeStr);

        if (localTime == null && remoteTime != null) {
          await local_db.dbSaveVocabEntry(id, remoteTimeStr);
          merged[id] = remoteTimeStr;
        } else if (localTime != null && remoteTime == null) {
          _syncInBackground(() => ApiService.saveVocabProgress(id, localTimeStr));
          merged[id] = localTimeStr;
        } else if (localTime != null && remoteTime != null) {
          if (remoteTime.isAfter(localTime)) {
            await local_db.dbSaveVocabEntry(id, remoteTimeStr);
            merged[id] = remoteTimeStr;
          } else if (localTime.isAfter(remoteTime)) {
            _syncInBackground(() => ApiService.saveVocabProgress(id, localTimeStr));
            merged[id] = localTimeStr;
          } else {
            merged[id] = localTimeStr;
          }
        } else {
          merged[id] = localTimeStr;
        }
      }
    }
    return merged;
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
    final localList = await local_db.dbGetListeningProgress();
    if (!ApiService.isLoggedIn.value) return localList;

    final remoteList = await ApiService.getListeningProgress();
    final localSet = localList.toSet();
    final remoteSet = remoteList.toSet();

    for (final id in remoteSet) {
      if (!localSet.contains(id)) {
        await local_db.dbSaveListeningProgress(id);
        localSet.add(id);
      }
    }

    for (final id in localSet) {
      if (!remoteSet.contains(id)) {
        _syncInBackground(() => ApiService.saveListeningProgress(id));
      }
    }

    return localSet.toList();
  }

  static Future<void> resetListeningProgress() =>
      local_db.dbResetListeningProgress();

  static Future<void> saveGrammarProgress(int questionId) async {
    await local_db.dbSaveGrammarProgress(questionId);
    _syncInBackground(() => ApiService.saveGrammarProgress(questionId));
  }

  static Future<List<int>> getGrammarProgress() async {
    final localList = await local_db.dbGetGrammarProgress();
    if (!ApiService.isLoggedIn.value) return localList;

    final remoteList = await ApiService.getGrammarProgress();
    final localSet = localList.toSet();
    final remoteSet = remoteList.toSet();

    for (final id in remoteSet) {
      if (!localSet.contains(id)) {
        await local_db.dbSaveGrammarProgress(id);
        localSet.add(id);
      }
    }

    for (final id in localSet) {
      if (!remoteSet.contains(id)) {
        _syncInBackground(() => ApiService.saveGrammarProgress(id));
      }
    }

    return localSet.toList();
  }

  static Future<void> resetGrammarProgress() =>
      local_db.dbResetGrammarProgress();

  static Future<void> saveDuolingoProgress(int challengeId) async {
    await local_db.dbSaveDuolingoProgress(challengeId);
    _syncInBackground(() => ApiService.saveDuolingoProgress(challengeId));
  }

  static Future<List<int>> getDuolingoProgress() async {
    final localList = await local_db.dbGetDuolingoProgress();
    if (!ApiService.isLoggedIn.value) return localList;

    final remoteList = await ApiService.getDuolingoProgress();
    final localSet = localList.toSet();
    final remoteSet = remoteList.toSet();

    for (final id in remoteSet) {
      if (!localSet.contains(id)) {
        await local_db.dbSaveDuolingoProgress(id);
        localSet.add(id);
      }
    }

    for (final id in localSet) {
      if (!remoteSet.contains(id)) {
        _syncInBackground(() => ApiService.saveDuolingoProgress(id));
      }
    }

    return localSet.toList();
  }

  static Future<void> resetDuolingoProgress() =>
      local_db.dbResetDuolingoProgress();
}
