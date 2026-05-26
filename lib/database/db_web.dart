// Web: no SQLite, return empty progress
Future<void> dbSetStatus(int kanjiId, String status) async {}
Future<void> dbSaveProgress(int kanjiId, bool correct) async {}
Future<Map<int, Map<String, dynamic>>> dbGetAllProgress() async => {};
Future<void> dbResetAllProgress() async {}