class GrammarPoint {
  final int id;
  final String pattern;
  final String meaningVi;
  final String usage;
  final String example;
  final String exampleReading;
  final String exampleVi;
  final int jlptLevel;

  const GrammarPoint({
    required this.id,
    required this.pattern,
    required this.meaningVi,
    required this.usage,
    required this.example,
    required this.exampleReading,
    required this.exampleVi,
    required this.jlptLevel,
  });
}

class GrammarQuestion {
  final int id;
  final int lesson;
  final String question;
  final String translation;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const GrammarQuestion({
    required this.id,
    required this.lesson,
    required this.question,
    required this.translation,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}