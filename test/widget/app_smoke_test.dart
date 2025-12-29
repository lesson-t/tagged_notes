import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/main.dart' as app;

void main() {
  testWidgets('アプリが起動して一覧画面が表示される', (tester) async {
    // アプリ起動
    app.main();

    // 初期描画・アニメーション・非同期処理を待つ
    await tester.pumpAndSettle();

    // NoteListScreen　の　AppBar　タイトルが表示される
    expect(find.text('Tagged Notes'), findsOneWidget);
  });
}
