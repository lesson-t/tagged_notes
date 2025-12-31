import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

import '../fakes/in_memory_store.dart';

Widget _buildTestApp({required NoteProvider provider}) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(home: NoteListScreen()),
  );
}

// NoteProvider _createProviderWithFakeRepo({List<Note>? initalNotes}) {
//   final repo = FakeNoteRepository(initial: initalNotes);

//   // 位置引数（main.dart で NoteProvider(repo)）
//   return NoteProvider(repo);
// }

NoteProvider _createProvider() {
  final store = InMemoryStore();
  final repo = NoteRepository(store);
  return NoteProvider(repo);
}

Future<void> _seedOneNote(NoteProvider provider) async {
  await provider.addNote('元タイトル', '元本文', '仕事');
}

void main() {
  testWidgets('編集画面で変更しても、保存せずに戻ると詳細は更新されない', (tester) async {
    final provider = _createProvider();
    await _seedOneNote(provider);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    // 1) 一覧 → 詳細（タイトルタップ）
    expect(find.text('元タイトル'), findsOneWidget);
    await tester.tap(find.text('元タイトル'));
    await tester.pumpAndSettle();

    // 詳細に元タイトル/元本文が表示される前提
    expect(find.text('元タイトル'), findsOneWidget);
    expect(find.text('元本文'), findsOneWidget);

    // 2) 詳細 → 編集（AppBarの編集アイコン）
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // 編集画面（編集モード）
    expect(find.text('メモを編集'), findsOneWidget);

    // 3) タイトル/本文を変更（未保存）
    await tester.enterText(find.widgetWithText(TextField, 'タイトル'), '変更後タイトル');
    await tester.enterText(find.widgetWithText(TextField, '本文'), '変更後本文');
    await tester.pump();

    // 4) 保存せずに戻る（AppBar leading）
    // MaterialApp + Scaffold の AppBar なら tooltip 'Back' が基本
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // 5) 詳細に戻った後、表示が元のままを確認
    expect(find.text('元タイトル'), findsOneWidget);
    expect(find.text('元本文'), findsOneWidget);

    // 変更後が出ていない
    expect(find.text('変更後タイトル'), findsNothing);
    expect(find.text('変更後本文'), findsNothing);
  });
}
