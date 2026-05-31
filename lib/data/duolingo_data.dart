import '../models/duolingo_challenge.dart';

final List<DuolingoChallenge> duolingoChallenges = [
  // 1. Bài 1: N1 は N2 です (Vi -> Jp)
  const DuolingoChallenge(
    id: 1,
    prompt: "Tôi là Mike Miller.",
    target: "\u308f\u305f\u3057\u306f\u30de\u30a4\u30af\u30fb\u30df\u30e9\u30fc\u3067\u3059。",
    correctOrder: ["\u308f\u305f\u3057", "\u306f", "\u30de\u30a4\u30af\u30fb\u30df\u30e9\u30fc", "\u3067\u3059"],
    jumbledTokens: ["\u3067\u3059", "\u306f", "\u30de\u30a4\u30af\u30fb\u30df\u30e9\u30fc", "\u308f\u305f\u3057", "\u3058\u3083\u3042\u308a\u307e\u305b\u3093", "\u3042\u306a\u305f"],
    furigana: {},
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 1:\n- Cấu trúc: [N1 は N2 です] (N1 là N2).\n- 'は' là trợ từ chủ ngữ (phát âm là 'wa'). 'đáp' đứng cuối câu khẳng định danh từ lịch sự.\n- 'わたし' nghĩa là 'Tôi'.",
  ),

  // 2. Bài 1: N1 は N2 じゃありません (Jp -> Vi)
  const DuolingoChallenge(
    id: 2,
    prompt: "\u30b5\u30f3\u30c8\u30b9\u3055\u3093\u306f\u5b66\u751f\u3058\u3083\u3042\u308a\u307e\u305b\u3093。",
    target: "Anh Santos không phải là sinh viên.",
    correctOrder: ["Anh Santos", "không phải là", "sinh viên."],
    jumbledTokens: ["không phải là", "học sinh", "Anh Santos", "sinh viên.", "là", "bác sĩ"],
    furigana: {
      "\u5b66\u751f": "\u304c\u304f\u305b\u3044",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["\u30b5\u30f3\u30c8\u30b9\u3055\u3093", "\u306f", "\u5b66\u751f", "\u3058\u3083\u3042\u308a\u307e\u305b\u3093"],
    explanation: "🌟 NGỮ PHÁP BÀI 1:\n- Cấu trúc: [N1 は N2 じゃありません] (N1 không phải là N2).\n- 'じゃありません' là dạng phủ định lịch sự của 'です'.\n- '学生' (がくせい) nghĩa là sinh viên/học sinh.",
  ),

  // 3. Bài 2: この N1 は N2 です (Vi -> Jp)
  const DuolingoChallenge(
    id: 3,
    prompt: "Máy tính này là của tôi.",
    target: "\u3053\u306e\u30b3\u30f3\u30d4\u30e5\u30fc\u30bf\u30fc\u306f\u308f\u305f\u3057\u306e\u3067\u3059。",
    correctOrder: ["\u3053\u306e", "\u30b3\u30f3\u30d4\u30e5\u30fc\u30bf\u30fc", "\u306f", "\u308f\u305f\u3057", "\u306e", "\u3067\u3059"],
    jumbledTokens: ["\u306f", "\u3053\u308c", "\u306e", "\u30b3\u30f3\u30d4\u30e5\u30fc\u30bf\u30fc", "\u3053\u306e", "\u3067\u3059", "\u308f\u305f\u3057", "\u3042\u306a\u305f"],
    furigana: {},
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 2:\n- Cấu trúc: [この + Danh từ + は] (Cái ... này).\n- Khác với 'これ' đứng độc lập, 'この' bắt buộc phải bổ nghĩa cho danh từ đứng ngay sau.\n- 'わたしのです' là sở hữu: 'của tôi'.",
  ),

  // 4. Bài 3: N は N(Địa điểm) です (Jp -> Vi)
  const DuolingoChallenge(
    id: 4,
    prompt: "\u304a\u624b\u6d17\u3044\u306f\u3069\u3053\u3067\u3059\u304b。",
    target: "Nhà vệ sinh ở đâu?",
    correctOrder: ["Nhà vệ sinh", "ở", "đâu?"],
    jumbledTokens: ["ở", "cái nào?", "Nhà vệ sinh", "đâu?", "phòng học", "ở đằng kia"],
    furigana: {
      "\u304a\u624b\u6d17\u3044": "\u304a\u3066\u3042\u3089\u3044",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["\u304a\u624b\u6d17\u3044", "\u306f", "\u3069\u3053", "\u3067\u3059\u304b"],
    explanation: "🌟 NGỮ PHÁP BÀI 3:\n- Cấu trúc: [N は どこ ですか] (N ở đâu?).\n- 'どこ' là nghi vấn từ chỉ địa điểm ('ở đâu').\n- 'お手洗い' (おてあらい) là từ lịch sự chỉ nhà vệ sinh.",
  ),

  // 5. Bài 4: Giờ giấc (Vi -> Jp)
  const DuolingoChallenge(
    id: 5,
    prompt: "Bây giờ là 4 giờ rưỡi.",
    target: "\u4eca\u56db\u6642\u534a\u3067\u3059。",
    correctOrder: ["\u4eca", "\u56db\u6642", "\u534a", "\u3067\u3059"],
    jumbledTokens: ["\u3067\u3059", "\u534a", "\u4e94\u6642", "\u4eca", "\u56db\u6642", "\u6628\u65e5"],
    furigana: {
      "\u4eca": "\u3044\u307e",
      "\u56db\u6642": "\u3088\u3058",
      "\u534a": "\u306f\u3093",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 4:\n- Cách nói giờ: [Số đếm + 時 (じ)]. Đặc biệt 4 giờ là '四時' (よじ) chứ không phải 'よんじ'.\n- '半' (はん) đứng sau giờ có nghĩa là 'rưỡi / 30 phút'.\n- '今' (いま) nghĩa là 'Bây giờ'.",
  ),

  // 6. Bài 4: Quá khứ & Khoảng thời gian (Jp -> Vi)
  const DuolingoChallenge(
    id: 6,
    prompt: "\u6628\u65e5\u4e5d\u6642\u304b\u3089\u4e94\u6642\u307e\u3067\u52c9\u5f37\u3057\u307e\u3057\u305f。",
    target: "Hôm qua tôi đã học từ 9 giờ đến 5 giờ.",
    correctOrder: ["Hôm qua", "tôi", "đã học", "từ 9 giờ", "đến 5 giờ."],
    jumbledTokens: ["từ 9 giờ", "Hôm nay", "đã học", "đang học", "đến 5 giờ.", "Hôm qua", "tôi"],
    furigana: {
      "\u6628\u65e5": "\u304d\u306e\u3046",
      "\u4e5d\u6642": "\u304f\u3058",
      "\u4e94\u6642": "\u3054\u3058",
      "\u52c9\u5f37": "\u3079\u3093\u304d\u3087\u3046",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["\u6628\u65e5", "\u4e5d\u6642", "\u304b\u3089", "\u4e94\u6642", "\u307e\u3067", "\u52c9\u5f37\u3057\u307e\u3057\u305f"],
    explanation: "🌟 NGỮ PHÁP BÀI 4:\n- Cấu trúc: [N1 から N2 まで] (Từ N1 đến N2).\n- Động từ chia quá khứ khẳng định đuôi '〜ました': '勉強しました' (Đã học).\n- '昨日' (きのう) là 'Hôm qua'.",
  ),

  // 7. Bài 5: Trợ từ phương tiện で & Hướng đi へ (Vi -> Jp)
  const DuolingoChallenge(
    id: 7,
    prompt: "Tôi đi đến Kyoto bằng tàu điện ngầm.",
    target: "\u5730\u4e0b\u9244\u3067\u4eac\u90fd\u3078\u884c\u304d\u307e\u3059。",
    correctOrder: ["\u5730\u4e0b\u9244", "\u3067", "\u4eac\u90fd", "\u3078", "\u884c\u304d\u307e\u3059"],
    jumbledTokens: ["\u3067", "\u4eac\u90fd", "\u884c\u304d\u307e\u3059", "\u5730\u4e0b\u9244", "\u306b", "\u3078", "\u6765\u307e\u3059", "\u6771\u4eac"],
    furigana: {
      "\u5730\u4e0b\u9244": "\u3061\u304b\u3066\u3064",
      "\u4eac\u90fd": "\u304d\u3087\u3046\u3068",
      "\u884c": "\u3044",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 5:\n- Trợ từ 'で' chỉ phương tiện đi lại (bằng...). '地下鉄' (ちかてつ) là tàu điện ngầm.\n- Trợ từ 'へ' (phát âm là 'e') chỉ hướng đi của các động từ di chuyển. '行きます' (いきます) là động từ 'đi'.",
  ),

  // 8. Bài 6: Trợ từ đối tượng を & Cùng làm と (Jp -> Vi)
  const DuolingoChallenge(
    id: 8,
    prompt: "\u5bb6\u65cf\u3068\u663c\u5fa1\u98ef\u3092\u98df\u3079\u307e\u3059。",
    target: "Tôi ăn cơm trưa cùng với gia đình.",
    correctOrder: ["Tôi", "ăn cơm trưa", "cùng với", "gia đình."],
    jumbledTokens: ["gia đình.", "Tôi", "uống trà", "ăn cơm trưa", "cùng với", "bạn bè"],
    furigana: {
      "\u5bb6\u65cf": "\u304b\u305e\u304f",
      "\u663c\u5fa1\u98ef": "\u3072\u308b\u3054\u306f\u3093",
      "\u98df": "\u305f",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["\u5bb6\u65cf", "\u3068", "\u663c\u5fa1\u98ef", "\u3092", "\u98df\u3079\u307e\u3059"],
    explanation: "🌟 NGỮ PHÁP BÀI 6:\n- Trợ từ 'と' mang nghĩa 'cùng với (ai đó)'. '家族' (かぞく) là gia đình.\n- Trợ từ 'を' đứng trước động từ ngoại động từ để chỉ đối tượng chịu tác động: '昼御飯を食べます' (ăn cơm trưa).",
  ),

  // 9. Bài 7: Trợ từ phương tiện で (Vi -> Jp)
  const DuolingoChallenge(
    id: 9,
    prompt: "Tôi viết thư bằng tiếng Nhật.",
    target: "\u65e5\u672c\u8a9e\u3067\u624b\u7d19\u3092\u66f8\u304d\u307e\u3059。",
    correctOrder: ["\u65e5\u672c\u8a9e", "\u3067", "\u624b\u7d19", "\u3092", "\u66f8\u304d\u307e\u3059"],
    jumbledTokens: ["\u624b\u7d19", "\u65e5\u672c\u8a9e", "\u3067", "\u3092", "\u66f8\u304d\u307e\u3059", "\u6771\u4eac", "\u306b"],
    furigana: {
      "\u65e5\u672c\u8a9e": "\u306b\u307b\u3093\u3054",
      "\u624b\u7d19": "\u3066\u304c\u307f",
      "\u66f8": "\u304b",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 7:\n- Cấu trúc: [Công cụ/Ngôn ngữ + で + Động từ] chỉ phương tiện, công cụ để thực hiện hành động.\n- '日本語で' = bằng tiếng Nhật. '手紙を書きます' = viết thư.",
  ),

  // 10. Bài 8: Tính từ đuôi い / な & Cụm từ nối (Jp -> Vi)
  const DuolingoChallenge(
    id: 10,
    prompt: "\u65e5\u672c\u8a9e\u306f\u9762\u767d\u3044\u3067\u3059\u304c\u96e3\u3057\u3044\u3067\u3059。",
    target: "Tiếng Nhật thú vị nhưng khó.",
    correctOrder: ["Tiếng Nhật", "thú vị", "nhưng", "khó."],
    jumbledTokens: ["tiếng Anh", "Tiếng Nhật", "thú vị", "và", "nhưng", "khó.", "dễ"],
    furigana: {
      "\u65e5\u672c\u8a9e": "\u306b\u307b\u3093\u3054",
      "\u9762\u767d\u3044": "\u304a\u3082\u3057\u308d\u3044",
      "\u96e3\u3057\u3044": "\u3080\u305a\u304b\u3057\u3044",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["\u65e5\u672c\u8a9e", "\u306f", "\u9762\u767d\u3044", "\u3067\u3059\u304c", "\u96e3\u3057\u3044", "\u3067\u3059"],
    explanation: "🌟 NGỮ PHÁP BÀI 8:\n- Tính từ đuôi 'い': '面白い' (おもしろい), '難しい' (base-64).\n- Trợ từ nối 'が' (ga) đứng giữa hai mệnh đề trái ngược mang nghĩa 'nhưng / tuy nhiên'.",
  ),

  // 11. Bài 9: Muốn làm gì (〜たいess) (Vi -> Jp)
  const DuolingoChallenge(
    id: 11,
    prompt: "Tôi muốn ăn sushi.",
    target: "\u79c1\u306f\u5bff\u53f8\u3092\u98df\u3079\u305f\u3044\u3067\u3059。",
    correctOrder: ["\u79c1", "\u306f", "\u5bff\u53f8", "\u3092", "\u98df\u3079\u305f\u3044", "\u3067\u3059"],
    jumbledTokens: ["\u98df\u3079\u305f\u3044", "\u306f", "\u5bff\u53f8", "\u3092", "\u3067\u3059", "\u79c1", "\u6765\u307e\u3059", "\u6771\u4eac"],
    furigana: {
      "\u79c1": "\u308f\u305f\u3057",
      "\u5bff\u53f8": "\u3059\u3057",
      "\u98df": "\u305f",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 13:\n- Cấu trúc: [Danh từ + を + Động từ thể ます bỏ ます + たいです] chỉ nguyện vọng muốn làm một hành động nào đó của bản thân.\n- '食べます' -> '食べたいです' (muốn ăn).",
  ),

  // 12. Bài 14: Hãy làm gì (〜てください) (Vi -> Jp)
  const DuolingoChallenge(
    id: 12,
    prompt: "Hãy viết tên ở đây.",
    target: "\u3053\u3053\u306b\u540d\u524d\u3092\u66f8\u3044\u3066\u304f\u3060\u3055\u3044。",
    correctOrder: ["\u3053\u3053", "\u306b", "\u540d\u524d", "\u3092", "\u66f8\u3044\u3066", "\u304f\u3060\u3055\u3044"],
    jumbledTokens: ["\u66f8\u3044\u3066", "\u306b", "\u3053\u3053", "\u304f\u3060\u3055\u3044", "\u540d\u524d", "\u3092", "\u3042\u306a\u305f", "\u6765\u307e\u3059"],
    furigana: {
      "\u540d\u524d": "\u306a\u307e\u3048",
      "\u66f8": "\u304b",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 14:\n- Cấu trúc: [Động từ thể て + ください] là câu yêu cầu hoặc đề nghị lịch sự người nghe thực hiện một hành động.\n- '書きます' (viết) chia thể て là '書いて'. '名前' (なまえ) nghĩa là 'tên'.",
  ),

  // 13. Bài 9: Có thể làm gì (Jp -> Vi)
  const DuolingoChallenge(
    id: 13,
    prompt: "\u79c1\u306f\u65e5\u672c\u8a9e\u304c\u5c11\u3057\u3067\u304d\u307e\u3059。",
    target: "Tôi có thể nói tiếng Nhật một chút.",
    correctOrder: ["Tôi", "có thể nói", "tiếng Nhật", "một chút."],
    jumbledTokens: ["tiếng Nhật", "Tôi", "một chút.", "không biết", "có thể nói", "rất giỏi"],
    furigana: {
      "\u79c1": "\u308f\u305f\u3057",
      "\u65e5\u672c\u8a9e": "\u306b\u307b\u3093\u3054",
      "\u5c11\u3057": "\u3059\u3053\u3057",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["\u79c1", "\u306f", "\u65e5\u672c\u8a9e", "\u304c", "\u5c11\u3057", "\u3067\u304d\u307e\u3059"],
    explanation: "🌟 NGỮ PHÁP BÀI 9:\n- Cấu trúc: [N が できます] biểu thị khả năng có thể làm N. '日本語ができます' = có thể tiếng Nhật (nói tiếng Nhật).\n- Trạng từ chỉ mức độ '少し' (すこし) nghĩa là 'một chút'.",
  ),

  // 14. Bài 10: Tồn tại vật có (あります) (Jp -> Vi)
  const DuolingoChallenge(
    id: 14,
    prompt: "\u516c\u5712\u306b\u305f\u304f\u3055\u3093\u306e\u82b1\u304c\u3042\u308a\u307e\u3059。",
    target: "Ở công viên có nhiều hoa.",
    correctOrder: ["Ở công viên", "có", "nhiều", "hoa."],
    jumbledTokens: ["Ở công viên", "có", "ít", "nhiều", "chó mèo", "hoa."],
    furigana: {
      "\u516c\u5712": "\u3053\u3046\u3048\u3093",
      "\u82b1": "\u306f\u306a",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["\u516c\u5712", "\u306b", "\u305f\u304f\u3055\u3093\u306e", "\u82b1", "\u304c\u3042\u308a\u307e\u3059"],
    explanation: "🌟 NGỮ PHÁP BÀI 10:\n- Cấu trúc: [Địa điểm + に + Vật + が あります] chỉ sự tồn tại của đồ vật, thực vật tại một vị trí ('Ở... có...').\n- '花' (はな) là hoa. '公園' (こうえん) là công viên.",
  ),

  // 15. Bài 18: Sở thích là làm gì (Vi -> Jp)
  const DuolingoChallenge(
    id: 15,
    prompt: "Sở thích của tôi là xem phim.",
    target: "\u79c1\u306e\u8da3\u5473\u306f\u6620\u753b\u3092\u898b\u308b\u3053\u3068\u3067\u3059。",
    correctOrder: ["\u79c1", "\u306e", "\u8da3\u5473", "\u306f", "\u6620\u753b", "\u3092", "\u898b\u308b", "\u3053\u3068", "\u3067\u3059"],
    jumbledTokens: ["\u8da3\u5473", "\u898b\u308b", "\u3053\u3068", "\u306e", "\u79c1", "\u306f", "\u6620\u753b", "\u3092", "\u3067\u3059", "\u6771\u4eac", "\u6765\u307e\u3059"],
    furigana: {
      "\u79c1": "\u308f\u305f\u3057",
      "\u8da3\u5473": "\u3057\u3085\u307f",
      "\u6620\u753b": "\u3048\u3044\u304c",
      "\u898b": "\u307f",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 18:\n- Cấu trúc: [趣味は + Động từ thể từ điển (V辞書形) + ことです] dùng để danh từ hóa động từ để biểu đạt sở thích là hành động nào đó.\n- '見ます' thể từ điển là '見る'. '趣味' (しゅみ) là sở thích.",
  ),

  // 16. Bài 11: Chỉ lượng từ (Vi -> Jp)
  const DuolingoChallenge(
    id: 16,
    prompt: "Có 4 quả táo ở trên bàn.",
    target: "テーブルの上にりんごが四つあります。",
    correctOrder: ["テーブル", "の", "上に", "りんご", "が", "四つ", "あります"],
    jumbledTokens: ["あります", "りんご", "が", "の", "四つ", "テーブル", "上に", "犬", "います"],
    furigana: {
      "上": "うえ",
      "四つ": "よっつ",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 11:\n- Lượng từ chỉ vật tròn/nhỏ: '四つ' (よっつ - 4 quả/cái).\n- Lượng từ đứng ngay trước động từ mà nó bổ nghĩa: 'りんごが四つあります'.\n- 'テーブルの上' là trên bàn.",
  ),

  // 17. Bài 12: So sánh hơn (Jp -> Vi)
  const DuolingoChallenge(
    id: 17,
    prompt: "きょうはきのうよりさむいです。",
    target: "Hôm nay lạnh hơn hôm qua.",
    correctOrder: ["Hôm nay", "lạnh hơn", "hôm qua."],
    jumbledTokens: ["lạnh hơn", "Hôm nay", "hôm qua.", "nóng hơn", "Hôm qua", "ngày mai"],
    furigana: {},
    type: "jp_to_vi",
    jpPromptTokens: ["きょう", "は", "きのう", "より", "さむい", "です"],
    explanation: "🌟 NGỮ PHÁP BÀI 12:\n- Cấu trúc so sánh hơn: [N1 は N2 より A です] (N1 thì ... hơn N2).\n- 'より' là từ so sánh ('hơn'). 'さむい' là lạnh.",
  ),

  // 18. Bài 13: Mục đích di chuyển (Vi -> Jp)
  const DuolingoChallenge(
    id: 18,
    prompt: "Tôi đi đến siêu thị để mua sắm.",
    target: "スーパーへ買い物に行きます。",
    correctOrder: ["スーパー", "へ", "買い物", "に", "行きます"],
    jumbledTokens: ["買い物", "スーパー", "へ", "に", "行きます", "来ます", "食べに", "デパート"],
    furigana: {
      "買い物": "かいもの",
      "行": "い",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 13:\n- Cấu trúc chỉ mục đích di chuyển: [Danh từ chỉ hành động + に + 行きます/来ます/帰ります].\n- '買い物' (かいもの) là việc mua sắm. '買い物に行きます' = đi để mua sắm.",
  ),

  // 19. Bài 14: Đang làm gì 〜ています (Jp -> Vi)
  const DuolingoChallenge(
    id: 19,
    prompt: "ミラーさんは本を読んでいます。",
    target: "Anh Miller đang đọc sách.",
    correctOrder: ["Anh Miller", "đang đọc", "sách."],
    jumbledTokens: ["đang đọc", "đang viết", "sách.", "Anh Miller", "báo", "chị Sato"],
    furigana: {
      "本": "ほん",
      "読": "よ",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["ミラーさん", "は", "本", "を", "読んでいます"],
    explanation: "🌟 NGỮ PHÁP BÀI 14:\n- Cấu trúc hiện tại tiếp diễn: [V-て + います] biểu thị hành động đang diễn ra.\n- '読みます' (đọc) chia thể て là '読んで'. '本' (ほん) là sách.",
  ),

  // 20. Bài 15: Xin phép làm gì (Vi -> Jp)
  const DuolingoChallenge(
    id: 20,
    prompt: "Tôi ngồi ở đây có được không?",
    target: "ここに座ってもいいですか。",
    correctOrder: ["ここ", "に", "座って", "も", "いい", "ですか"],
    jumbledTokens: ["座って", "ですか", "ここ", "に", "いい", "も", "入って", "đầu"],
    furigana: {
      "座": "すわ",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 15:\n- Cấu trúc xin phép: [V-て + もいいですか] (Tôi làm ... có được không?).\n- '座ります' (ngồi) chia thể て là '座って'. Đi với giới từ 'に' chỉ vị trí ngồi.",
  ),

  // 21. Bài 15: Cấm làm gì 〜てはいけません (Jp -> Vi)
  const DuolingoChallenge(
    id: 21,
    prompt: "ここで写真を撮ってはいけません。",
    target: "Không được chụp ảnh ở đây.",
    correctOrder: ["Không được", "chụp ảnh", "ở đây."],
    jumbledTokens: ["chụp ảnh", "Không được", "ở đây.", "Hãy", "vẽ tranh", "ở đằng kia"],
    furigana: {
      "写真": "しゃしん",
      "撮": "と",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["ここ", "で", "写真", "を", "撮って", "は", "いけません"],
    explanation: "🌟 NGỮ PHÁP BÀI 15:\n- Cấu trúc cấm đoán: [V-て + はいけません] (Không được làm ...).\n- '撮ります' (chụp) chia thể て là '撮って'. '写真' (しゃしん) là ảnh.",
  ),

  // 22. Bài 16: Liên kết động từ thể て (Vi -> Jp)
  const DuolingoChallenge(
    id: 22,
    prompt: "Hôm qua tôi đã xem phim rồi đi ngủ.",
    target: "昨日映画を見て寝ました。",
    correctOrder: ["昨日", "映画", "を", "見て", "寝ました"],
    jumbledTokens: ["見て", "映画", "を", "昨日", "寝ました", "勉強しました", "行きました", "朝"],
    furigana: {
      "昨日": "きのう",
      "映画": "えいが",
      "見": "み",
      "寝": "ね",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 16:\n- Cách nối các hành động theo trình tự thời gian: [V1-て + V2-て + ... + V3].\n- Thì của cả câu được quyết định ở động từ cuối cùng: '寝ました' (quá khứ).",
  ),

  // 23. Bài 17: Hãy đừng làm gì (Jp -> Vi)
  const DuolingoChallenge(
    id: 23,
    prompt: "忘れないでください。",
    target: "Xin đừng quên.",
    correctOrder: ["Xin", "đừng", "quên."],
    jumbledTokens: ["Xin", "đừng", "quên.", "hãy", "nhớ", "nói"],
    furigana: {
      "忘": "わす",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["忘れ", "ないde", "ください"],
    explanation: "🌟 NGỮ PHÁP BÀI 17:\n- Cấu trúc yêu cầu lịch sự không làm việc gì: [V-ない + でください] (Xin đừng...).\n- '忘れます' (quên) chia thể ない là '忘れない'.",
  ),

  // 24. Bài 17: Phải làm gì 〜なければなりません (Vi -> Jp)
  const DuolingoChallenge(
    id: 24,
    prompt: "Tôi phải uống thuốc.",
    target: "薬を飲まなければなりません。",
    correctOrder: ["薬", "を", "飲まなければ", "なりません"],
    jumbledTokens: ["飲まなければ", "薬", "を", "なりません", "いけません", "食べなければ", "本"],
    furigana: {
      "薬": "くすり",
      "飲": "の",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 17:\n- Cấu trúc biểu thị nghĩa vụ bắt buộc: [V-ない bỏ い + ければなりません] (Phải làm gì).\n- '薬を飲みます' = uống thuốc. Động từ '飲みます' chia thể ない -> '飲まない' -> '飲まなければなりません'.",
  ),

  // 25. Bài 19: Đã từng làm gì 〜たことがあります (Jp -> Vi)
  const DuolingoChallenge(
    id: 25,
    prompt: "富士山に登ったことがあります。",
    target: "Tôi đã từng leo núi Phú Sĩ.",
    correctOrder: ["Tôi", "đã từng", "leo", "núi Phú Sĩ."],
    jumbledTokens: ["núi Phú Sĩ.", "Tôi", "chưa từng", "leo", "đã từng", "ngắm"],
    furigana: {
      "富士山": "ふじさん",
      "登": "のぼ",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["富士山", "に", "登った", "こと", "が", "あります"],
    explanation: "🌟 NGỮ PHÁP BÀI 19:\n- Cấu trúc nói về kinh nghiệm trong quá khứ: [V-た + ことがあります] (Đã từng làm...).\n- '登ります' (leo) chia thể quá khứ ngắn V-た là '登った'. '富士山' là núi Phú Sĩ.",
  ),

  // 26. Bài 20: Thể thông thường (Vi -> Jp)
  const DuolingoChallenge(
    id: 26,
    prompt: "Hôm nay bạn rảnh không?",
    target: "今日暇。",
    correctOrder: ["今日", "暇"],
    jumbledTokens: ["暇", "今日", "忙しい", "ですか", "昨日", "は"],
    furigana: {
      "今日": "きょう",
      "暇": "ひま",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 20:\n- Thể thông thường (xuồng xã) trong giao tiếp hàng ngày.\n- Khi hỏi bằng tính từ đuôi な ở thể thông thường, lược bỏ 'だ' ở cuối câu và lên giọng ở cuối câu: '今日暇？' (Hôm nay rảnh không?).",
  ),

  // 27. Bài 21: Tôi nghĩ rằng 〜と思います (Jp -> Vi)
  const DuolingoChallenge(
    id: 27,
    prompt: "明日は雨が降ると思います。",
    target: "Tôi nghĩ ngày mai trời sẽ mưa.",
    correctOrder: ["Tôi nghĩ", "ngày mai", "trời", "sẽ mưa."],
    jumbledTokens: ["ngày mai", "hôm nay", "sẽ mưa.", "sẽ nắng", "trời", "Tôi nghĩ"],
    furigana: {
      "明日": "あした",
      "雨": "あめ",
      "降": "ふ",
      "思": "おmo",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["明日", "は", "雨", "が", "降る", "と", "思います"],
    explanation: "🌟 NGỮ PHÁP BÀI 21:\n- Cấu trúc biểu thị ý kiến, suy đoán cá nhân: [Mệnh đề thể thông thường + と思います] (Tôi nghĩ rằng...).\n- '降ります' (mưa rơi) chia thể thông thường là '降る'.",
  ),

  // 28. Bài 22: Định ngữ bổ nghĩa cho danh từ (Vi -> Jp)
  const DuolingoChallenge(
    id: 28,
    prompt: "Đây là bức ảnh tôi đã chụp hôm qua.",
    target: "これは昨日撮った写真です。",
    correctOrder: ["これ", "は", "昨日", "撮った", "写真", "です"],
    jumbledTokens: ["撮った", "写真", "です", "これ", "昨日", "は", "見る", "カメラ"],
    furigana: {
      "昨日": "きのう",
      "撮": "と",
      "写真": "しゃしん",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 22:\n- Cấu trúc định ngữ bổ nghĩa cho danh từ: [Động từ thể thông thường + Danh từ].\n- '昨日撮った写真' = bức ảnh đã chụp hôm qua. Động từ bổ nghĩa đứng trước danh từ.",
  ),

  // 29. Bài 23: Khi làm gì 〜とき (Jp -> Vi)
  const DuolingoChallenge(
    id: 29,
    prompt: "図書館で本を借りるとき,カードが必要です。",
    target: "Khi mượn sách ở thư viện cần có thẻ.",
    correctOrder: ["Khi mượn sách", "ở thư viện", "cần có", "thẻ."],
    jumbledTokens: ["Khi mượn sách", "ở thư viện", "cần có", "thẻ.", "mua sách", "hiệu sách"],
    furigana: {
      "図書館": "としょかん",
      "本": "ほん",
      "借": "か",
      "必要": "ひつよう",
    },
    type: "jp_to_vi",
    jpPromptTokens: ["図書館", "で", "本", "を", "借りる", "とき", "カード", "が", "必要", "です"],
    explanation: "🌟 NGỮ PHÁP BÀI 23:\n- Cấu trúc liên kết thời gian: [V-thông thường + とき] (Khi...).\n- '借りるとき' = khi mượn. '必要' (ひつよう) nghĩa là cần thiết / cần có.",
  ),

  // 30. Bài 24: Cho nhận hành động 〜てくれます (Vi -> Jp)
  const DuolingoChallenge(
    id: 30,
    prompt: "Mẹ mua cho tôi chiếc áo len.",
    target: "母は私にセーターを買ってくれました。",
    correctOrder: ["母", "は", "私", "に", "セーター", "を", "買って", "くれました"],
    jumbledTokens: ["買って", "くれました", "母", "は", "私", "に", "セーター", "を", "đáp", "báo"],
    furigana: {
      "母": "は{",
      "私": "わたし",
      "買": "か",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 24:\n- Cấu trúc cho nhận: [Ai đó + は + Tôi + に + V-て + くれます] (Ai đó làm việc gì tốt giúp đỡ tôi).\n- 'セーター' là áo len. '買います' chia thể て là '買って'.",
  ),
];
