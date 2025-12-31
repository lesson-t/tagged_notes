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

NoteProvider _createProvider() {
  final store = InMemoryStore();
  final repo = NoteRepository(store);
  return NoteProvider(repo);
}

Future<void> _seedOneNote(NoteProvider provider) async {
  await provider.addNote('初期タイトル', '初期本文', '仕事');
}

void main() {
  testWidgets('詳細→編集→保存で詳細画面の表示が更新される', (tester) async {
    final provider = _createProvider();
    await _seedOneNote(provider);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle(); // init() が走るなら落ち着くまで待つ

    // 1) 一覧に初期タイトルが見える
    expect(find.text('初期タイトル'), findsOneWidget);

    // 2) 一覧アイテムをタップして詳細へ
    await tester.tap(find.text('初期タイトル'));
    await tester.pumpAndSettle();

    // 3) 詳細画面で初期タイトルが見える（DetailのUIに合わせて調整可）
    expect(find.text('初期タイトル'), findsOneWidget);

    // 4) 編集アイコンを押して編集画面へ
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // 5) タイトルを更新
    // NoteEditScreen が labelText 'タイトル' の TextField を持っている前提
    final titleField = find.widgetWithText(TextField, 'タイトル');
    expect(titleField, findsOneWidget);

    await tester.enterText(titleField, '更新後タイトル');
    await tester.pump();

    // 6) 保存
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // 7) 保存後に詳細へ戻り、表示が更新されている
    expect(find.text('更新後タイトル'), findsOneWidget);
    expect(find.text('初期タイトル'), findsNothing);
  });
}
