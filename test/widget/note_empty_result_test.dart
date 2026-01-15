import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/test_app.dart';

Future<void> _seedOneNote(InMemoryStore store) async {
  Note.resetCounter();
  final repo = NoteRepository(store);

  final note = Note(title: '仕事メモA', body: '本文', tag: '仕事');
  await repo.save([note]);
}

/// pumpAndSettle を使わず、Dialog操作を「表示中（hitTestable）」基準で進める
Future<void> openSearchAndSearch(WidgetTester tester, String query) async {
  // 検索アイコンを「押せるもの」に絞って押す
  final searchBtn = find.byIcon(Icons.search).hitTestable();
  await pumpUntilFound(tester, searchBtn);
  await tester.tap(searchBtn);
  await tester.pump(); // ダイアログ表示開始

  // ダイアログが出るまで待つ（表示中に限定）
  final dialog = find.byType(AlertDialog).hitTestable();
  await pumpUntilFound(tester, dialog);

  // ダイアログ内TextFieldへ入力
  final tf = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField));
  await pumpUntilFound(tester, tf);
  await tester.enterText(tf, query);
  await tester.pump(); // 入力反映

  // 「検索」ボタンを押す（押せるものだけ）
  final submit = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.widgetWithText(TextButton, '検索'),
  ).hitTestable();

  await pumpUntilFound(tester, submit);
  await tester.tap(submit);
  await tester.pump(); // ダイアログ閉じ・検索反映開始
}

void main() {
  testWidgets('検索で0件になると「条件に一致するメモがありません。」が表示される', (tester) async {
    await setTestSurfaceSize(tester);

    // 1) store を用意して seed
    final store = InMemoryStore();
    await _seedOneNote(store);

    // 2) ProviderScope を store で上書きして起動
    await tester.pumpWidget(buildTestApp(
      home: const NoteListScreen(),
      storeOverride: store,
    ));

    // 3) 一覧表示を待つ（まず seeded note が見えることを確認）
    await pumpUntilFound(tester, find.text('Tagged Notes'));
    await pumpUntilFound(tester, find.text('仕事メモA'));

    // 4) 0件になる検索
    await openSearchAndSearch(tester, '存在しないキーワード');

    // 5) 結果表示を待つ（「表示中」基準で）
    await pumpUntilFound(tester, find.text('条件に一致するメモがありません。').hitTestable());

    expect(find.text('仕事メモA'), findsNothing);
    expect(find.text('条件に一致するメモがありません。'), findsOneWidget);
  });
}
