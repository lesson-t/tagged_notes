class Note {
  final int id; // 一意ID
  String title; // タイトル（必須）
  String body; // 本文
  String tag; // ”仕事”/”プライベート”/”その他”
  final DateTime createdAt; // 作成日時
  bool isPinned; // ピン留め

  // ID採番用カウンター（アプリ内で共有）
  static int _counter = 0;

  // コンストラクタ
  Note({required this.title, this.body = "", required this.tag})
    : id = _counter++,
      createdAt = DateTime.now(),
      isPinned = false;

  // 永続化用の内部コンストラクタ
  Note._internal({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
    required this.createdAt,
    required this.isPinned,
  });

  // 保存用 :Map に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(), // 文字列にする
      'isPinned': isPinned,
    };
  }

  // 読込用 :Map から復元
  factory Note.fromMap(Map<String, dynamic> map) {
    final note = Note._internal(
      id: map['id'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      tag: map['tag'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isPinned: map['isPinned'] as bool,
    );

    if (note.id >= _counter) {
      _counter = note.id + 1;
    }

    return note;
  }

  // ピンの切り替え（true ⇔ false）
  void togglePin() {
    isPinned = !isPinned;
  }

  // update
  void update({
    required String title,
    required String body,
    required String tag,
  }) {
    this.title = title;
    this.body = body;
    this.tag = tag;
  }
}
