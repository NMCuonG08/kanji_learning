import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/match_game_screen.dart';
import 'screens/listening_quiz_screen.dart';
import 'screens/grammar_quiz_screen.dart';
import 'screens/duolingo_quiz_screen.dart';
import 'screens/vocab_match_game_screen.dart';
import 'screens/vocabulary_screen.dart';
import 'models/kanji.dart';
import 'models/listening_question.dart';
import 'models/vocab.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.loadThemePreference();
  runApp(const KanjiApp());
}

class KanjiApp extends StatelessWidget {
  const KanjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Kanji Master',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE94560),
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAFAFA),
            appBarTheme: AppBarTheme(
              backgroundColor: isDark ? const Color(0xFF16213E) : const Color(0xFFFAFAFA),
              foregroundColor: isDark ? Colors.white : Colors.black,
              elevation: 0,
            ),
          ),
          initialRoute: '/',
          onGenerateRoute: (settings) {
            final name = settings.name ?? '/';
            
            // Check routing match
            switch (name) {
              case '/':
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const HomeScreen(),
                );
              case '/quiz':
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                final list = args['kanjiList'] as List<Kanji>? ?? [];
                final title = args['title'] as String? ?? 'Học';
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => QuizScreen(kanjiList: list, title: title),
                );
              case '/match-game':
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                final pool = args['pool'] as List<Kanji>? ?? [];
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => MatchGameScreen(pool: pool),
                );
              case '/detail':
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                final kanji = args['kanji'] as Kanji;
                final mastery = args['mastery'] as int? ?? 0;
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => DetailScreen(kanji: kanji, mastery: mastery),
                );
              case '/grammar-quiz':
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const GrammarQuizScreen(),
                );
              case '/duolingo-quiz':
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const DuolingoQuizScreen(),
                );
              case '/listening-quiz':
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                final question = args['question'] as ListeningQuestion;
                final onComplete = args['onComplete'] as VoidCallback;
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => ListeningQuizScreen(
                    question: question,
                    onComplete: onComplete,
                  ),
                );
              case '/vocab-match-game':
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                final pool = args['pool'] as List<VocabWord>? ?? [];
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => VocabMatchGameScreen(pool: pool),
                );
              case '/vocab-topic-detail':
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                final topic = args['topic'] as TopicMeta;
                final initialProgress = args['initialProgress'] as Map<int, String>? ?? {};
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => VocabTopicDetailScreen(
                    topic: topic,
                    initialProgress: initialProgress,
                  ),
                );
              case '/vocab-flashcard':
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                final topic = args['topic'] as TopicMeta;
                final wordsBatch = args['wordsBatch'] as List<VocabWord>? ?? [];
                final initialProgress = args['initialProgress'] as Map<int, String>? ?? {};
                final isReviewMode = args['isReviewMode'] as bool? ?? false;
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => VocabFlashcardScreen(
                    topic: topic,
                    wordsBatch: wordsBatch,
                    initialProgress: initialProgress,
                    isReviewMode: isReviewMode,
                  ),
                );
              default:
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => const HomeScreen(),
                );
            }
          },
        );
      },
    );
  }
}