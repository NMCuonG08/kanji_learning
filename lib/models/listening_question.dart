class ListeningQuestion {
  final int id;
  final String taskType; // 'task1' | 'task2' | 'task3' | 'task4'
  final String situationVi; // Ngữ cảnh (Tiếng Việt)
  final String situationJa; // Ngữ cảnh câu hỏi để đọc (Tiếng Nhật)
  final String questionTextJa; // Câu hỏi viết bằng chữ Nhật
  final String questionAudioText; // Câu hỏi đọc bằng âm thanh
  final List<String> audioPhrases; // Đoạn hội thoại cần phát âm
  final List<String> options; // Danh sách lựa chọn hiển thị (Ví dụ: 4 lựa chọn, hoặc "Đáp án 1, 2, 3")
  final List<String> optionAudioTexts; // Text để TTS phát âm cho đáp án (đặc biệt là Mondai 3 & 4)
  final int correctOptionIndex; // Index của đáp án đúng (0-indexed)
  final String explanationVi; // Giải thích chi tiết và dịch nghĩa câu hỏi
  final List<String> scriptLines; // Transcript chi tiết để hiển thị khi xem đáp án

  const ListeningQuestion({
    required this.id,
    required this.taskType,
    required this.situationVi,
    required this.situationJa,
    required this.questionTextJa,
    required this.questionAudioText,
    required this.audioPhrases,
    required this.options,
    required this.optionAudioTexts,
    required this.correctOptionIndex,
    required this.explanationVi,
    required this.scriptLines,
  });
}
