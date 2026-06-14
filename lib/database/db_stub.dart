// Stub — replaced by platform-specific impl
Future<void> dbSetStatus(int kanjiId, String status) async {}
Future<void> dbSaveProgress(int kanjiId, bool correct) async {}
Future<Map<int, Map<String, dynamic>>> dbGetAllProgress() async => {};
Future<void> dbResetAllProgress() async {}

Future<void> dbSaveVocabProgress(int vocabId) async {}
Future<Map<int, String>> dbGetVocabProgress() async => {};
Future<void> dbDeleteVocabProgress(int vocabId) async {}
Future<void> dbResetVocabProgress() async {}

Future<void> dbSaveListeningProgress(int questionId) async {}
Future<List<int>> dbGetListeningProgress() async => [];
Future<void> dbResetListeningProgress() async {}

Future<void> dbSaveGrammarProgress(int questionId) async {}
Future<List<int>> dbGetGrammarProgress() async => [];
Future<void> dbResetGrammarProgress() async {}

Future<void> dbSaveDuolingoProgress(int challengeId) async {}
Future<List<int>> dbGetDuolingoProgress() async => [];
Future<void> dbResetDuolingoProgress() async {}
