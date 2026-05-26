class KanjiExample {
  final String word;
  final String reading;
  final String meaningVi;

  const KanjiExample({
    required this.word,
    required this.reading,
    required this.meaningVi,
  });
}

class Kanji {
  final int id;
  final String character;
  final String onyomi;
  final String kunyomi;
  final String meaningVi;
  final String radical;
  final String radicalMeaningVi;
  final String radicalNote;
  final int jlptLevel;
  final int strokeCount;
  final List<KanjiExample> examples;

  const Kanji({
    required this.id,
    required this.character,
    required this.onyomi,
    required this.kunyomi,
    required this.meaningVi,
    required this.radical,
    required this.radicalMeaningVi,
    required this.radicalNote,
    required this.jlptLevel,
    required this.strokeCount,
    required this.examples,
  });
}

class KanjiProgress {
  final int kanjiId;
  final int correctCount;
  final int wrongCount;
  final DateTime lastReviewed;
  final DateTime? nextReviewAt;
  final int masteryLevel;

  const KanjiProgress({
    required this.kanjiId,
    required this.correctCount,
    required this.wrongCount,
    required this.lastReviewed,
    this.nextReviewAt,
    required this.masteryLevel,
  });

  KanjiProgress copyWith({
    int? correctCount,
    int? wrongCount,
    DateTime? lastReviewed,
    DateTime? nextReviewAt,
    int? masteryLevel,
  }) {
    return KanjiProgress(
      kanjiId: kanjiId,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }
}