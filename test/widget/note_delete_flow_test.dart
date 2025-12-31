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
  await provider.addNote('削除対象メモ', '本文', '仕事');
}

Future<void> _openDeleteDialog(WidgetTester tester) async {
  // ListTile を長押し（タイトルのTextを長押しでもOK）
  await tester.longPress(find.text('削除対象メモ'));
  await tester.pumpAndSettle();

  // ダイアログが開いていることを確認
  expect(find.byType(AlertDialog), findsOneWidget);
  expect(find.text('削除しますか？'), findsOneWidget);
}

void main() {
  testWidgets('長押しで削除確認ダイアログが開く', (tester) async {
    final provider = _createProvider();
    await _seedOneNote(provider);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    await _openDeleteDialog(tester);
  });

  testWidgets('削除ダイアログでキャンセルすると削除されない', (tester) async {
    final provider = _createProvider();
    await _seedOneNote(provider);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    await _openDeleteDialog(tester);

    // 「キャンセル」押下
    await tester.tap(find.widgetWithText(TextButton, 'キャンセル'));
    await tester.pumpAndSettle();

    // ダイアログが閉じている
    expect(find.byType(AlertDialog), findsNothing);

    // ノートが残っている
    expect(find.text('削除対象メモ'), findsOneWidget);
  });

  testWidgets('削除ダイアログで削除すると一覧から消える', (tester) async {
    final provider = _createProvider();
    await _seedOneNote(provider);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    await _openDeleteDialog(tester);

    // 「キャンセル」押下
    await tester.tap(find.widgetWithText(TextButton, '削除'));
    await tester.pumpAndSettle();

    // ダイアログが閉じている
    expect(find.byType(AlertDialog), findsNothing);

    // ノートが消える（空状態メッセージが出るならそれも確認）
    expect(find.text('削除対象メモ'), findsNothing);
    expect(find.textContaining('まだメモがありません'), findsOneWidget);
  });
}
