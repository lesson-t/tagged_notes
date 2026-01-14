import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('一覧画面が表示され、空状態メッセージが出る', (tester) async {
    await tester.pumpWidget(buildTestApp(home: const NoteListScreen()));
    await pumpUntilFound(tester, find.text('Tagged Notes'));

    // データ0件なら空状態
    await pumpUntilFound(tester, find.textContaining('まだメモがありません'));
  });

  testWidgets('FAB押下で新規メモ画面へ遷移する', (tester) async {
    await tester.pumpWidget(buildTestApp(home: const NoteListScreen()));
    await pumpUntilFound(tester, find.text('Tagged Notes'));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // NoteEditScreen の AppBar タイトル（新規時）
    await pumpUntilFound(tester, find.text('新規メモ'));
  });

  testWidgets('新規メモを作成して保存すると一覧に反映される', (tester) async {
    await tester.pumpWidget(buildTestApp(home: const NoteListScreen()));
    await pumpUntilFound(tester, find.text('Tagged Notes'));

    // 1) FAB -> 新規メモ画面
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await pumpUntilFound(tester, find.text('新規メモ'));

    // 2) タイトル/本文を入力
    await tester.enterText(find.widgetWithText(TextField, 'タイトル'), 'テストタイトル');
    await tester.enterText(find.widgetWithText(TextField, '本文'), 'テスト本文');
    await tester.pump();

    // 3) 保存アイコン押下
    final saveButton = find.byIcon(Icons.save);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    // 一覧に戻り、作成したメモが表示される
    await pumpUntilFound(tester, find.text('テストタイトル'));
  });
}
