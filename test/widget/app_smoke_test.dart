import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/di/providers.dart';
import 'package:tagged_notes/main.dart';

import '../fakes/in_memory_store.dart';

void main() {
  testWidgets('アプリが起動して一覧画面が表示される', (tester) async {
    // アプリ起動
    // app.main();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // 永続化をテスト用に差し替え（SharedPreferences依存を排除）
          keyValueStoreProvider.overrideWithValue(InMemoryStore()),
        ],
        child: const MyApp(),
      ),
    );

    // 初回ロードの1フレーム進める
    await tester.pump();

    for (var i = 0; i < 50; i++) {
      if (find.text('Tagged Notes').evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 50));
    }

    // NoteListScreen　の　AppBar　タイトルが表示される
    expect(find.text('Tagged Notes'), findsOneWidget);
  });
}
