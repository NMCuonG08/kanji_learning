import '../models/duolingo_challenge.dart';

final List<DuolingoChallenge> duolingoChallenges = [
  // 1. Bài 1: N1 は N2 です (Vi -> Jp)
  const DuolingoChallenge(
    id: 1,
    prompt: "Tôi là Mike Miller.",
    target: "わたしはマイク・ミラーです。",
    correctOrder: ["わたし", "は", "マイク・ミラー", "です"],
    jumbledTokens: ["です", "は", "あなた", "マイク・ミラー", "わたし", "じゃありません"],
    furigana: {},
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 1:\n- Cấu trúc: [N1 は N2 です] (N1 là N2).\n- 'は' là trợ từ chủ ngữ (phát âm là 'wa'). 'です' đứng cuối câu khẳng định danh từ lịch sự.\n- 'わたし' nghĩa là 'Tôi'.",
  ),

  // 2. Bài 1: N1 は N2 じゃありません (Jp -> Vi)
  const DuolingoChallenge(
    id: 2,
    prompt: "サントスさんは学生じゃありません。",
    target: "Anh Santos không phải là sinh viên.",
    correctOrder: ["Anh Santos", "không phải là", "sinh viên."],
    jumbledTokens: ["không phải là", "học sinh", "Anh Santos", "sinh viên.", "là", "bác sĩ"],
    furigana: {
      "学生": "がくせい",
    },
    type: "jp_to_vi",
    explanation: "🌟 NGỮ PHÁP BÀI 1:\n- Cấu trúc: [N1 は N2 じゃありません] (N1 không phải là N2).\n- 'じゃありません' là dạng phủ định lịch sự của 'です'.\n- '学生' (がくせい) nghĩa là sinh viên/học sinh.",
  ),

  // 3. Bài 2: この N1 は N2 です (Vi -> Jp)
  const DuolingoChallenge(
    id: 3,
    prompt: "Máy tính này là của tôi.",
    target: "このコンピューターはわたしのです。",
    correctOrder: ["この", "コンピューター", "は", "わたし", "の", "です"],
    jumbledTokens: ["は", "これ", "の", "コンピューター", "この", "です", "わたし", "あなた"],
    furigana: {},
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 2:\n- Cấu trúc: [この + Danh từ + は] (Cái ... này).\n- Khác với 'これ' đứng độc lập, 'この' bắt buộc phải bổ nghĩa cho danh từ đứng ngay sau.\n- 'わたしのです' là sở hữu: 'của tôi'.",
  ),

  // 4. Bài 3: N は N(Địa điểm) です (Jp -> Vi)
  const DuolingoChallenge(
    id: 4,
    prompt: "お手洗いはどこですか。",
    target: "Nhà vệ sinh ở đâu?",
    correctOrder: ["Nhà vệ sinh", "ở", "đâu?"],
    jumbledTokens: ["ở", "cái nào?", "Nhà vệ sinh", "đâu?", "phòng học", "ở đằng kia"],
    furigana: {
      "お手洗い": "おてあらい",
    },
    type: "jp_to_vi",
    explanation: "🌟 NGỮ PHÁP BÀI 3:\n- Cấu trúc: [N は どこ ですか] (N ở đâu?).\n- 'どこ' là nghi vấn từ chỉ địa điểm ('ở đâu').\n- 'お手洗い' (おてあらい) là từ lịch sự chỉ nhà vệ sinh.",
  ),

  // 5. Bài 4: Giờ giấc (Vi -> Jp)
  const DuolingoChallenge(
    id: 5,
    prompt: "Bây giờ là 4 giờ rưỡi.",
    target: "今四時半です。",
    correctOrder: ["今", "四時", "半", "です"],
    jumbledTokens: ["です", "半", "五時", "今", "四時", "昨日"],
    furigana: {
      "今": "いま",
      "四時": "よじ",
      "半": "はん",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 4:\n- Cách nói giờ: [Số đếm + 時 (じ)]. Đặc biệt 4 giờ là '四時' (よじ) chứ không phải 'よんじ'.\n- '半' (はん) đứng sau giờ có nghĩa là 'rưỡi / 30 phút'.\n- '今' (いま) nghĩa là 'Bây giờ'.",
  ),

  // 6. Bài 4: Quá khứ & Khoảng thời gian (Jp -> Vi)
  const DuolingoChallenge(
    id: 6,
    prompt: "昨日九時から五時まで勉強しました。",
    target: "Hôm qua tôi đã học từ 9 giờ đến 5 giờ.",
    correctOrder: ["Hôm qua", "tôi", "đã học", "từ 9 giờ", "đến 5 giờ."],
    jumbledTokens: ["từ 9 giờ", "Hôm nay", "đã học", "đang học", "đến 5 giờ.", "Hôm qua", "tôi"],
    furigana: {
      "昨日": "きのう",
      "九時": "くじ",
      "五時": "ごじ",
      "勉強": "べんきょう",
    },
    type: "jp_to_vi",
    explanation: "🌟 NGỮ PHÁP BÀI 4:\n- Cấu trúc: [N1 から N2 まで] (Từ N1 đến N2).\n- Động từ chia quá khứ khẳng định đuôi '〜ました': '勉強しました' (Đã học).\n- '昨日' (きのう) là 'Hôm qua'.",
  ),

  // 7. Bài 5: Trợ từ phương tiện で & Hướng đi へ (Vi -> Jp)
  const DuolingoChallenge(
    id: 7,
    prompt: "Tôi đi đến Kyoto bằng tàu điện ngầm.",
    target: "地下鉄で京都へ行きます。",
    correctOrder: ["地下鉄", "で", "京都", "へ", "行きます"],
    jumbledTokens: ["で", "京都", "行きます", "地下鉄", "に", "へ", "来ます", "東京"],
    furigana: {
      "地下鉄": "ちかてつ",
      "京都": "きょうと",
      "行": "い",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 5:\n- Trợ từ 'で' chỉ phương tiện đi lại (bằng...). '地下鉄' (ちかてつ) là tàu điện ngầm.\n- Trợ từ 'へ' (phát âm là 'e') chỉ hướng đi của các động từ di chuyển. '行きます' (いきます) là động từ 'đi'.",
  ),

  // 8. Bài 6: Trợ từ đối tượng を & Cùng làm と (Jp -> Vi)
  const DuolingoChallenge(
    id: 8,
    prompt: "家族と昼御飯を食べます。",
    target: "Tôi ăn cơm trưa cùng với gia đình.",
    correctOrder: ["Tôi", "ăn cơm trưa", "cùng với", "gia đình."],
    jumbledTokens: ["gia đình.", "Tôi", "uống trà", "ăn cơm trưa", "cùng với", "bạn bè"],
    furigana: {
      "家族": "かぞく",
      "昼御飯": "ひるごはん",
      "食": "た",
    },
    type: "jp_to_vi",
    explanation: "🌟 NGỮ PHÁP BÀI 6:\n- Trợ từ 'と' mang nghĩa 'cùng với (ai đó)'. '家族' (かぞく) là gia đình.\n- Trợ từ 'を' đứng trước động từ ngoại động từ để chỉ đối tượng chịu tác động: '昼御飯を食べます' (ăn cơm trưa).",
  ),

  // 9. Bài 7: Trợ từ phương tiện で (Vi -> Jp)
  const DuolingoChallenge(
    id: 9,
    prompt: "Tôi viết thư bằng tiếng Nhật.",
    target: "日本語で手紙を書きます。",
    correctOrder: ["日本語", "で", "手紙", "を", "書きます"],
    jumbledTokens: ["手紙", "日本語", "で", "を書きます", "を", "書きます", "英語", "に"],
    furigana: {
      "日本語": "にほんご",
      "手紙": "てがみ",
      "書": "か",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 7:\n- Cấu trúc: [Công cụ/Ngôn ngữ + で + Động từ] chỉ phương tiện, công cụ để thực hiện hành động.\n- '日本語で' = bằng tiếng Nhật. '手紙を書きます' = viết thư.",
  ),

  // 10. Bài 8: Tính từ đuôi い / な & Cụm từ nối (Jp -> Vi)
  const DuolingoChallenge(
    id: 10,
    prompt: "日本語は面白いですが難しいです。",
    target: "Tiếng Nhật thú vị nhưng khó.",
    correctOrder: ["Tiếng Nhật", "thú vị", "nhưng", "khó."],
    jumbledTokens: ["tiếng Anh", "Tiếng Nhật", "thú vị", "và", "nhưng", "khó.", "dễ"],
    furigana: {
      "日本語": "にほんご",
      "面白い": "おもしろい",
      "難しい": "むずかしい",
    },
    type: "jp_to_vi",
    explanation: "🌟 NGỮ PHÁP BÀI 8:\n- Tính từ đuôi 'い': '面白い' (thú vị), '難しい' (khó).\n- Trợ từ nối 'が' (ga) đứng giữa hai mệnh đề trái ngược mang nghĩa 'nhưng / tuy nhiên'.",
  ),

  // 11. Bài 9: Muốn làm gì (〜たいです) (Vi -> Jp)
  const DuolingoChallenge(
    id: 11,
    prompt: "Tôi muốn ăn sushi.",
    target: "私は寿司を食べたいです。",
    correctOrder: ["私", "は", "寿司", "を", "食べたい", "です"],
    jumbledTokens: ["食べたい", "は", "寿司", "を", "です", "私", "飲みたい", "天ぷら"],
    furigana: {
      "私": "わたし",
      "寿司": "すし",
      "食": "た",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 13:\n- Cấu trúc: [Danh từ + を + Động từ thể ます bỏ ます + たいです] chỉ nguyện vọng muốn làm một hành động nào đó của bản thân.\n- '食べます' -> '食べたいです' (muốn ăn).",
  ),

  // 12. Bài 14: Hãy làm gì (〜てください) (Vi -> Jp)
  const DuolingoChallenge(
    id: 12,
    prompt: "Hãy viết tên ở đây.",
    target: "ここに名前를書いてください。",
    correctOrder: ["ここ", "に", "名前", "を", "書いて", "ください"],
    jumbledTokens: ["書いて", "に", "ここ", "ください", "名前", "を", "あそこ", "読んで"],
    furigana: {
      "名前": "なまえ",
      "書": "か",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 14:\n- Cấu trúc: [Động từ thể て + ください] là câu yêu cầu hoặc đề nghị lịch sự người nghe thực hiện một hành động.\n- '書きます' (viết) chia thể て là '書いて'. '名前' (なまえ) nghĩa là 'tên'.",
  ),

  // 13. Bài 9: Có thể làm gì (Jp -> Vi)
  const DuolingoChallenge(
    id: 13,
    prompt: "私は日本語が少しできます。",
    target: "Tôi có thể nói tiếng Nhật một chút.",
    correctOrder: ["Tôi", "có thể nói", "tiếng Nhật", "một chút."],
    jumbledTokens: ["tiếng Nhật", "Tôi", "một chút.", "không biết", "có thể nói", "rất giỏi"],
    furigana: {
      "私": "わたし",
      "日本語": "にほんご",
      "少し": "すこし",
    },
    type: "jp_to_vi",
    explanation: "🌟 NGỮ PHÁP BÀI 9:\n- Cấu trúc: [N が できます] biểu thị khả năng có thể làm N. '日本語ができます' = có thể tiếng Nhật (nói tiếng Nhật).\n- Trạng từ chỉ mức độ '少し' (すこし) nghĩa là 'một chút'.",
  ),

  // 14. Bài 10: Tồn tại vật có (あります) (Jp -> Vi)
  const DuolingoChallenge(
    id: 14,
    prompt: "公園にたくさんの花があります。",
    target: "Ở công viên có nhiều hoa.",
    correctOrder: ["Ở công viên", "có", "nhiều", "hoa."],
    jumbledTokens: ["Ở công viên", "có", "ít", "nhiều", "chó mèo", "hoa."],
    furigana: {
      "公園": "こうえん",
      "花": "はな",
    },
    type: "jp_to_vi",
    explanation: "🌟 NGỮ PHÁP BÀI 10:\n- Cấu trúc: [Địa điểm + に + Vật + が あります] chỉ sự tồn tại của đồ vật, thực vật tại một vị trí ('Ở... có...').\n- '花' (はな) là hoa. '公園' (こうえん) là công viên.",
  ),

  // 15. Bài 18: Sở thích là làm gì (Vi -> Jp)
  const DuolingoChallenge(
    id: 15,
    prompt: "Sở thích của tôi là xem phim.",
    target: "私の趣味は映画を見ることです。",
    correctOrder: ["私", "の", "趣味", "は", "映画", "を", "見る", "こと", "です"],
    jumbledTokens: ["趣味", "見る", "こと", "の", "私", "は", "映画", "を", "です", "音楽", "聞く"],
    furigana: {
      "私": "わたし",
      "趣味": "しゅみ",
      "映画": "えいが",
      "見": "み",
    },
    type: "vi_to_jp",
    explanation: "🌟 NGỮ PHÁP BÀI 18:\n- Cấu trúc: [趣味は + Động từ thể từ điển (V辞書形) + ことです] dùng để danh từ hóa động từ để biểu đạt sở thích là hành động nào đó.\n- '見ます' thể từ điển là '見る'. '趣味' (しゅみ) là sở thích.",
  ),
];
