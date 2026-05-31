import '../services/api_service.dart';

class KanjiDatabase {
  static Future<void> setStatus(int kanjiId, String status) async {
    final now = DateTime.now();
    final nextReview = status == 'learned'
        ? now.add(const Duration(days: 5))
        : now.add(const Duration(hours: 1));
    
    final data = await ApiService.getKanjiProgress();
    Map<String, dynamic> entry;
    if (!data.containsKey(kanjiId)) {
      entry = {
        'kanjiId': kanjiId,
        'correctCount': 0,
        'wrongCount': 0,
        'lastReviewed': now.toIso8601String(),
        'masteryLevel': 0,
        'nextReviewAt': nextReview.toIso8601String(),
        'status': status,
      };
    } else {
      entry = Map<String, dynamic>.from(data[kanjiId]!);
      entry['status'] = status;
      entry['lastReviewed'] = now.toIso8601String();
      entry['nextReviewAt'] = nextReview.toIso8601String();
    }
    await ApiService.saveKanjiProgress(entry);
  }

  static Future<void> saveProgress(int kanjiId, bool correct) async {
    final now = DateTime.now();
    final nextReview = correct ? now.add(const Duration(hours: 24)) : now.add(const Duration(hours: 1));
    
    final dataMap = await ApiService.getKanjiProgress();
    Map<String, dynamic> entry;
    if (!dataMap.containsKey(kanjiId)) {
      entry = {
        'kanjiId': kanjiId,
        'correctCount': correct ? 1 : 0,
        'wrongCount': correct ? 0 : 1,
        'lastReviewed': now.toIso8601String(),
        'masteryLevel': correct ? 1 : 0,
        'nextReviewAt': nextReview.toIso8601String(),
        'status': 'learning',
      };
    } else {
      entry = Map<String, dynamic>.from(dataMap[kanjiId]!);
      int correctCount = (entry['correctCount'] as num).toInt() + (correct ? 1 : 0);
      int wrongCount = (entry['wrongCount'] as num).toInt() + (correct ? 0 : 1);
      int mastery = (entry['masteryLevel'] as num).toInt();
      mastery = correct ? (mastery + 1).clamp(0, 5) : (mastery - 1).clamp(0, 5);
      
      entry['correctCount'] = correctCount;
      entry['wrongCount'] = wrongCount;
      entry['lastReviewed'] = now.toIso8601String();
      entry['masteryLevel'] = mastery;
      entry['nextReviewAt'] = nextReview.toIso8601String();
    }
    await ApiService.saveKanjiProgress(entry);
  }

  static Future<Map<int, Map<String, dynamic>>> getAllProgress() => ApiService.getKanjiProgress();
  static Future<void> resetAllProgress() => ApiService.resetAllProgress();

  static Future<void> saveVocabProgress(int vocabId) => 
      ApiService.saveVocabProgress(vocabId, DateTime.now().toIso8601String());
  static Future<Map<int, String>> getVocabProgress() => ApiService.getVocabProgress();
  static Future<void> deleteVocabProgress(int vocabId) => ApiService.deleteVocabProgress(vocabId);
  static Future<void> resetVocabProgress() => ApiService.resetAllProgress();

  static Future<void> saveListeningProgress(int questionId) => ApiService.saveListeningProgress(questionId);
  static Future<List<int>> getListeningProgress() => ApiService.getListeningProgress();
  static Future<void> resetListeningProgress() => ApiService.resetAllProgress();

  static Future<void> saveGrammarProgress(int questionId) => ApiService.saveGrammarProgress(questionId);
  static Future<List<int>> getGrammarProgress() => ApiService.getGrammarProgress();
  static Future<void> resetGrammarProgress() => ApiService.resetAllProgress();
}