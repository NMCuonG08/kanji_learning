class DuolingoChallenge {
  final int id;
  final String prompt; // The translation/prompt shown to the user
  final String target; // The final correct complete sentence
  final List<String> correctOrder; // List of correct tokens in order
  final List<String> jumbledTokens; // Shuffled tokens including distractors
  final Map<String, String> furigana; // Map of Kanji words to their Furigana readings
  final String type; // 'vi_to_jp' (dịch sang tiếng Nhật) or 'jp_to_vi' (dịch sang tiếng Việt)
  final String explanation; // Educational explanation of the grammar and vocabulary

  const DuolingoChallenge({
    required this.id,
    required this.prompt,
    required this.target,
    required this.correctOrder,
    required this.jumbledTokens,
    required this.furigana,
    required this.type,
    required this.explanation,
  });
}
