class Note {
  final int id;       // 一意ID
  String title;       // タイトル（必須）
  String body;        // 本文
  String tag;         // ”仕事”/”プライベート”/”その他”
  final DateTime createdAt; // 作成日時
  bool isPinned;      // ピン留め

  // ID採番用カウンター（アプリ内で共有）
  static int _counter = 0;

  Note({
    required this.title,
    this.body = "",
    required this.tag,
  }) : id = _counter++,
       createdAt = DateTime.now(),
       isPinned = false;

  // ピンの切り替え（true ⇔ false）
  void togglePin() {
    isPinned = !isPinned;
  }

  // update
  void update({required String title, required String body, required String tag}) {
    this.title = title;
    this.body = body;
    this.tag = tag;
  }
}