class VocabWord {
  final int id;
  final String word;
  final String reading;
  final String meaningVi;
  final String category;
  final String partOfSpeech;
  final int jlptLevel;

  const VocabWord({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaningVi,
    required this.category,
    required this.partOfSpeech,
    required this.jlptLevel,
  });
}

const Map<String, String> vocabCategories = {
  'danh_tu': '名詞 Danh từ',
  'dong_tu': '動詞 Động từ',
  'tinh_tu_i': '形容詞(い) Tính từ い',
  'tinh_tu_na': '形容動詞 Tính từ な',
  'truong_tu': '副詞 Trạng từ',
  'dai_tu': '代名詞 Đại từ',
  'thoi_gian': '時間詞 Từ chỉ thời gian',
  'so_dem': '数詞 Số đếm',
  'mau_sac': '色名詞 Màu sắc',
  'tu_hoi': '疑問詞 Từ để hỏi',
  'lien_tu': '接続詞 Liên từ',
  'cam_than': '感動詞 Cảm thán',
};