import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _webKanjiDbKey = 'kanji_progress';
const String _webVocabDbKey = 'vocab_progress';
const String _webDuolingoDbKey = 'duolingo_progress';

// === Kanji Progress ===
Future<Map<int, Map<String, dynamic>>> dbGetAllProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final String? jsonStr = prefs.getString(_webKanjiDbKey);
  if (jsonStr == null) return {};
  try {
    final Map<String, dynamic> decoded = jsonDecode(jsonStr);
    final Map<int, Map<String, dynamic>> result = {};
    decoded.forEach((key, value) {
      final intId = int.tryParse(key);
      if (intId != null && value is Map) {
        result[intId] = Map<String, dynamic>.from(value);
      }
    });
    return result;
  } catch (e) {
    return {};
  }
}

Future<void> _saveKanjiData(Map<int, Map<String, dynamic>> data) async {
  final prefs = await SharedPreferences.getInstance();
  final Map<String, dynamic> stringKeyedData = {};
  data.forEach((key, value) {
    stringKeyedData[key.toString()] = value;
  });
  await prefs.setString(_webKanjiDbKey, jsonEncode(stringKeyedData));
}

Future<void> dbSetStatus(int kanjiId, String status) async {
  final data = await dbGetAllProgress();
  final now = DateTime.now();
  final nextReview = status == 'learned'
      ? now.add(const Duration(days: 5))
      : now.add(const Duration(hours: 1));

  if (!data.containsKey(kanjiId)) {
    data[kanjiId] = {
      'kanjiId': kanjiId,
      'correctCount': 0,
      'wrongCount': 0,
      'lastReviewed': now.toIso8601String(),
      'masteryLevel': 0,
      'nextReviewAt': nextReview.toIso8601String(),
      'status': status,
    };
  } else {
    final Map<String, dynamic> entry = Map<String, dynamic>.from(
      data[kanjiId]!,
    );
    entry['status'] = status;
    entry['lastReviewed'] = now.toIso8601String();
    entry['nextReviewAt'] = nextReview.toIso8601String();
    data[kanjiId] = entry;
  }
  await _saveKanjiData(data);
}

Future<void> dbSaveProgress(int kanjiId, bool correct) async {
  final dataMap = await dbGetAllProgress();
  final now = DateTime.now();
  final nextReview = correct
      ? now.add(const Duration(hours: 24))
      : now.add(const Duration(hours: 1));
  if (!dataMap.containsKey(kanjiId)) {
    dataMap[kanjiId] = {
      'kanjiId': kanjiId,
      'correctCount': correct ? 1 : 0,
      'wrongCount': correct ? 0 : 1,
      'lastReviewed': now.toIso8601String(),
      'masteryLevel': correct ? 1 : 0,
      'nextReviewAt': nextReview.toIso8601String(),
      'status': 'learning',
    };
  } else {
    final Map<String, dynamic> entry = Map<String, dynamic>.from(
      dataMap[kanjiId]!,
    );
    int correctCount =
        (entry['correctCount'] as num).toInt() + (correct ? 1 : 0);
    int wrongCount = (entry['wrongCount'] as num).toInt() + (correct ? 0 : 1);
    int mastery = (entry['masteryLevel'] as num).toInt();
    mastery = correct ? (mastery + 1).clamp(0, 5) : (mastery - 1).clamp(0, 5);

    entry['correctCount'] = correctCount;
    entry['wrongCount'] = wrongCount;
    entry['lastReviewed'] = now.toIso8601String();
    entry['masteryLevel'] = mastery;
    entry['nextReviewAt'] = nextReview.toIso8601String();
    dataMap[kanjiId] = entry;
  }
  await _saveKanjiData(dataMap);
}

Future<void> dbResetAllProgress() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_webKanjiDbKey);
}

// === Vocabulary Progress ===
Future<Map<int, String>> dbGetVocabProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final String? jsonStr = prefs.getString(_webVocabDbKey);
  if (jsonStr == null) return {};
  try {
    final Map<String, dynamic> decoded = jsonDecode(jsonStr);
    final Map<int, String> result = {};
    decoded.forEach((key, value) {
      final intId = int.tryParse(key);
      if (intId != null && value is String) {
        result[intId] = value;
      }
    });
    return result;
  } catch (e) {
    return {};
  }
}

Future<void> dbSaveVocabProgress(int vocabId) async {
  final data = await dbGetVocabProgress();
  data[vocabId] = DateTime.now().toIso8601String();
  final prefs = await SharedPreferences.getInstance();
  final Map<String, String> stringKeyedData = {};
  data.forEach((key, value) {
    stringKeyedData[key.toString()] = value;
  });
  await prefs.setString(_webVocabDbKey, jsonEncode(stringKeyedData));
}

Future<void> dbDeleteVocabProgress(int vocabId) async {
  final data = await dbGetVocabProgress();
  data.remove(vocabId);
  final prefs = await SharedPreferences.getInstance();
  final Map<String, String> stringKeyedData = {};
  data.forEach((key, value) {
    stringKeyedData[key.toString()] = value;
  });
  await prefs.setString(_webVocabDbKey, jsonEncode(stringKeyedData));
}

Future<void> dbResetVocabProgress() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_webVocabDbKey);
}

// === Listening Progress ===
const String _webListeningDbKey = 'listening_progress';

Future<void> dbSaveListeningProgress(int questionId) async {
  final progress = await dbGetListeningProgress();
  if (!progress.contains(questionId)) {
    progress.add(questionId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webListeningDbKey, jsonEncode(progress));
  }
}

Future<List<int>> dbGetListeningProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final String? jsonStr = prefs.getString(_webListeningDbKey);
  if (jsonStr == null) return [];
  try {
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.cast<int>();
  } catch (e) {
    return [];
  }
}

Future<void> dbResetListeningProgress() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_webListeningDbKey);
}

// === Grammar Progress ===
const String _webGrammarDbKey = 'grammar_progress';

Future<void> dbSaveGrammarProgress(int questionId) async {
  final progress = await dbGetGrammarProgress();
  if (!progress.contains(questionId)) {
    progress.add(questionId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webGrammarDbKey, jsonEncode(progress));
  }
}

Future<List<int>> dbGetGrammarProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final String? jsonStr = prefs.getString(_webGrammarDbKey);
  if (jsonStr == null) return [];
  try {
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.cast<int>();
  } catch (e) {
    return [];
  }
}

Future<void> dbResetGrammarProgress() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_webGrammarDbKey);
}

// === Duolingo Sentence Progress ===
Future<void> dbSaveDuolingoProgress(int challengeId) async {
  final progress = await dbGetDuolingoProgress();
  if (!progress.contains(challengeId)) {
    progress.add(challengeId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webDuolingoDbKey, jsonEncode(progress));
  }
}

Future<List<int>> dbGetDuolingoProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final String? jsonStr = prefs.getString(_webDuolingoDbKey);
  if (jsonStr == null) return [];
  try {
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.cast<int>();
  } catch (e) {
    return [];
  }
}

Future<void> dbResetDuolingoProgress() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_webDuolingoDbKey);
}
