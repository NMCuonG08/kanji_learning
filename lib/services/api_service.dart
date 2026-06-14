import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String? _token;
  static String? _username;
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  // Dynamic base URL resolver based on active platform
  static String get baseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      // If we run 'flutter run -d chrome' locally, the app will run on port 8080+
      // but the backend runs on port 3686. In this case, redirect to port 3686 directly.
      if (origin.contains('localhost:') &&
          !origin.contains(':3686') &&
          !origin.contains(':8686')) {
        return 'http://localhost:3686';
      }
      return origin;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3686'; // Standard Android loopback IP
    }
    return 'http://localhost:3686';
  }

  static String? get currentUsername => _username;

  // Initialize service, loading credentials from storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _username = prefs.getString('auth_username');
    isLoggedIn.value = _token != null;
  }

  // --- Auth API ---

  static Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        await _saveCredentials(data['token'], data['user']['username']);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Lỗi đăng ký!'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối tới máy chủ backend!',
      };
    }
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await _saveCredentials(data['token'], data['user']['username']);
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Tài khoản hoặc mật khẩu không đúng!',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối tới máy chủ backend!',
      };
    }
  }

  static Future<void> logout() async {
    _token = null;
    _username = null;
    isLoggedIn.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('auth_username');
  }

  static Future<void> _saveCredentials(String token, String username) async {
    _token = token;
    _username = username;
    isLoggedIn.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('auth_username', username);
  }

  // --- HTTP Helpers with JWT Headers ---

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<http.Response> _get(String path) async {
    return http
        .get(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(const Duration(seconds: 5));
  }

  static Future<http.Response> _post(String path, dynamic body) async {
    return http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 5));
  }

  static Future<http.Response> _delete(String path) async {
    return http
        .delete(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(const Duration(seconds: 5));
  }

  // --- Progress Synced API ---

  // Kanji progress
  static Future<Map<int, Map<String, dynamic>>> getKanjiProgress() async {
    if (!isLoggedIn.value) return {};
    try {
      final res = await _get('/api/kanji-progress');
      if (res.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(res.body);
        final Map<int, Map<String, dynamic>> result = {};
        decoded.forEach((key, value) {
          final id = int.tryParse(key);
          if (id != null && value is Map) {
            result[id] = Map<String, dynamic>.from(value);
          }
        });
        return result;
      }
    } catch (e) {
      debugPrint('Failed to fetch Kanji progress: $e');
    }
    return {};
  }

  static Future<void> saveKanjiProgress(Map<String, dynamic> entry) async {
    if (!isLoggedIn.value) return;
    try {
      await _post('/api/kanji-progress', entry);
    } catch (e) {
      debugPrint('Failed to save Kanji progress: $e');
    }
  }

  // Vocabulary progress
  static Future<Map<int, String>> getVocabProgress() async {
    if (!isLoggedIn.value) return {};
    try {
      final res = await _get('/api/vocab-progress');
      if (res.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(res.body);
        final Map<int, String> result = {};
        decoded.forEach((key, value) {
          final id = int.tryParse(key);
          if (id != null && value is String) {
            result[id] = value;
          }
        });
        return result;
      }
    } catch (e) {
      debugPrint('Failed to fetch Vocab progress: $e');
    }
    return {};
  }

  static Future<void> saveVocabProgress(int vocabId, String timestamp) async {
    if (!isLoggedIn.value) return;
    try {
      await _post('/api/vocab-progress', {
        'vocabId': vocabId,
        'lastCorrectAt': timestamp,
      });
    } catch (e) {
      debugPrint('Failed to save Vocab progress: $e');
    }
  }

  static Future<void> deleteVocabProgress(int vocabId) async {
    if (!isLoggedIn.value) return;
    try {
      await _delete('/api/vocab-progress/$vocabId');
    } catch (e) {
      debugPrint('Failed to delete Vocab progress: $e');
    }
  }

  // Listening progress
  static Future<List<int>> getListeningProgress() async {
    if (!isLoggedIn.value) return [];
    try {
      final res = await _get('/api/listening-progress');
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        return decoded.cast<int>();
      }
    } catch (e) {
      debugPrint('Failed to fetch Listening progress: $e');
    }
    return [];
  }

  static Future<void> saveListeningProgress(int questionId) async {
    if (!isLoggedIn.value) return;
    try {
      await _post('/api/listening-progress', {'questionId': questionId});
    } catch (e) {
      debugPrint('Failed to save Listening progress: $e');
    }
  }

  // Grammar progress
  static Future<List<int>> getGrammarProgress() async {
    if (!isLoggedIn.value) return [];
    try {
      final res = await _get('/api/grammar-progress');
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        return decoded.cast<int>();
      }
    } catch (e) {
      debugPrint('Failed to fetch Grammar progress: $e');
    }
    return [];
  }

  static Future<void> saveGrammarProgress(int questionId) async {
    if (!isLoggedIn.value) return;
    try {
      await _post('/api/grammar-progress', {'questionId': questionId});
    } catch (e) {
      debugPrint('Failed to save Grammar progress: $e');
    }
  }

  // Duolingo sentence progress
  static Future<List<int>> getDuolingoProgress() async {
    if (!isLoggedIn.value) return [];
    try {
      final res = await _get('/api/duolingo-progress');
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        return decoded.cast<int>();
      }
    } catch (e) {
      debugPrint('Failed to fetch Duolingo progress: $e');
    }
    return [];
  }

  static Future<void> saveDuolingoProgress(int challengeId) async {
    if (!isLoggedIn.value) return;
    try {
      await _post('/api/duolingo-progress', {'challengeId': challengeId});
    } catch (e) {
      debugPrint('Failed to save Duolingo progress: $e');
    }
  }

  // Reset Progress
  static Future<void> resetAllProgress() async {
    if (!isLoggedIn.value) return;
    try {
      await _post('/api/reset-progress', {});
    } catch (e) {
      debugPrint('Failed to reset progress: $e');
    }
  }
}
