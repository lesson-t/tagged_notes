import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

import '../fakes/fake_note_repository.dart';

Widget _buildTestApp({required NoteProvider provider}) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(
      home: NoteListScreen(),
    ),
  );
}

NoteProvider _createProviderWithFakeRepo({List<Note>? initalNotes}) {
  final repo = FakeNoteRepository(initial: initalNotes);

  // 位置引数（main.dart で NoteProvider(repo)）
  return NoteProvider(repo);
}

Future<void> _seedOneNote(NoteProvider provider) async {
  await provider.addNote('元タイトル', '元本文', '仕事');
}

void main() {
  testWidgets('編集画面で変更しても、保存せずに戻ると詳細は更新されない', (tester) async {
  final provider = _createProviderWithFakeRepo(initalNotes: []);
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

  // 編集画面（編集モード）

  // 3) タイトル/本文を変更（未保存）

  // 4) 保存せずに戻る（AppBar leading）
  // MaterialApp + Scaffold の AppBar なら tooltip 'Back' が基本


  // 5) 詳細に戻った後、表示が元のままを確認

  // 変更後が出ていない


  });
}