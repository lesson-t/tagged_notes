import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';

import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/test_app.dart';

// Widget _buildTestApp({required NoteProvider provider}) {
//   return ChangeNotifierProvider.value(
//     value: provider,
//     child: const MaterialApp(home: NoteListScreen()),
//   );
// }

// NoteProvider _createProvider() {
//   final store = InMemoryStore();
//   final repo = NoteRepository(store);
//   return NoteProvider(repo);
// }

// Future<void> _seedOneNote(NoteProvider provider) async {
//   await provider.addNote('削除対象メモ', '本文', '仕事');
// }

Future<void> _seedOneNote(InMemoryStore store) async {
  Note.resetCounter();
  final repo = NoteRepository(store);

  final note = Note(title: '削除対象メモ', body: '本文', tag: '仕事');
  await repo.save([note]);
}

// Future<void> _openDeleteDialog(WidgetTester tester) async {
//   // ListTile を長押し（タイトルのTextを長押しでもOK）
//   await tester.longPress(find.text('削除対象メモ'));
//   await tester.pumpAndSettle();

//   // ダイアログが開いていることを確認
//   expect(find.byType(AlertDialog), findsOneWidget);
//   expect(find.text('削除しますか？'), findsOneWidget);
// }

Future<void> _openDeleteDialog(WidgetTester tester) async {
  // 一覧に対象が出ていることを保証
  await pumpUntilFound(tester, find.text('削除対象メモ'));

  final target = find.text('削除対象メモ').hitTestable();
  await pumpUntilFound(tester, target);

  // 長押し → ダイアログ表示
  await tester.longPress(target);
  await tester.pump(); // ダイアログ描画開始

  // ダイアログが「表示中」であることを保証
  await pumpUntilFound(tester, find.byType(AlertDialog).hitTestable());
  await pumpUntilFound(tester, find.text('削除しますか？').hitTestable());
}

Future<void> _tapDialogButton(WidgetTester tester, String label) async {
  // ダイアログ内のボタンに限定して押す（同名ボタンの誤爆防止）
  final dialog = find.byType(AlertDialog);
  await pumpUntilFound(tester, dialog);

  final btn = find
      .descendant(of: dialog, matching: find.widgetWithText(TextButton, label))
      .hitTestable();

  await pumpUntilFound(tester, btn);
  await tester.tap(btn);
  await tester.pump(); // close / delete の反映開始
}

void main() {
  testWidgets('長押しで削除確認ダイアログが開く', (tester) async {
    await setTestSurfaceSize(tester);

    final store = InMemoryStore();
    await _seedOneNote(store);

    await tester.pumpWidget(buildTestApp(
      home: const NoteListScreen(),
      storeOverride: store,
    ));

    await pumpUntilFound(tester, find.text('Tagged Notes'));

    await _openDeleteDialog(tester);
  });

  testWidgets('削除ダイアログでキャンセルすると削除されない', (tester) async {
    await setTestSurfaceSize(tester);

    final store = InMemoryStore();
    await _seedOneNote(store);

    await tester.pumpWidget(buildTestApp(
      home: const NoteListScreen(),
      storeOverride: store,
    ));

    await pumpUntilFound(tester, find.text('Tagged Notes'));

    await _openDeleteDialog(tester);

    // 「キャンセル」押下
    await _tapDialogButton(tester, 'キャンセル');

    // ダイアログが閉じている
    expect(find.byType(AlertDialog).hitTestable(), findsNothing);

    // メモが残っている
    await pumpUntilFound(tester, find.text('削除対象メモ').hitTestable());
  });

  testWidgets('削除ダイアログで削除すると一覧から消える', (tester) async {
    await setTestSurfaceSize(tester);

    final store = InMemoryStore();
    await _seedOneNote(store);

    await tester.pumpWidget(buildTestApp(
      home: const NoteListScreen(),
      storeOverride: store,
    ));

    await pumpUntilFound(tester, find.text('Tagged Notes'));
    await _openDeleteDialog(tester);

    // 「削除」押下
    await _tapDialogButton(tester, '削除');

    // ダイアログが閉じている
    expect(find.byType(AlertDialog).hitTestable(), findsNothing);

    // メモが “見えていない” ことを待つ（build反映待ち）
    await pumpUntilGone(tester, find.text('削除対象メモ').hitTestable());

    // そして最終確認
    expect(find.text('削除対象メモ').hitTestable(), findsNothing);

    // 空状態が出ること（これも状態反映の完了条件として有効）
    await pumpUntilFound(tester, find.textContaining('まだメモがありません').hitTestable());
  });
}
