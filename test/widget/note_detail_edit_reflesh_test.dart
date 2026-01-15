import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/screens/note_edit_screen.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/test_app.dart';

Future<void> _seedOneNote(InMemoryStore store) async {
  Note.resetCounter();
  final repo = NoteRepository(store);

  final note = Note(title: '初期タイトル', body: '初期本文', tag: '仕事');
  await repo.save([note]);
}

void main() {
  testWidgets('詳細→編集→保存で詳細画面の表示が更新される', (tester) async {
    await setTestSurfaceSize(tester);

    final store = InMemoryStore();
    await _seedOneNote(store);

    await tester.pumpWidget(buildTestApp(
      home: const NoteListScreen(),
      storeOverride: store,
    ));

    // 一覧が出る
    await pumpUntilFound(tester, find.text('Tagged Notes'));

    // 1) 一覧に初期タイトルが見える
    final initialTitle = find.text('初期タイトル').hitTestable();
    await pumpUntilFound(tester, initialTitle);

    // // 2) 一覧アイテムをタップして詳細へ
    await tester.tap(initialTitle);
    await tester.pump(); // 遷移開始
    await tester.pump(const Duration(milliseconds: 600)); // 遷移アニメ完了目安

    // 3) 詳細画面を待つ
    await pumpUntilFound(tester, find.text('メモ詳細').hitTestable());
    await pumpUntilFound(tester, find.text('初期タイトル').hitTestable());

    // 4) 編集アイコン（AppBar）を hitTestable で押す
    final editIcon = find.byIcon(Icons.edit).hitTestable();
    await pumpUntilFound(tester, editIcon);

    await tester.tap(editIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // 5) 編集画面（型で保証）
    await pumpUntilFound(tester, find.byType(NoteEditScreen));
    await pumpUntilFound(tester, find.text('メモを編集').hitTestable());

    // 6) タイトルを更新
    final titleField = find.widgetWithText(TextField, 'タイトル').hitTestable();
    await pumpUntilFound(tester, titleField);

    await tester.enterText(titleField, '更新後タイトル');
    await tester.pump();

    // 7) 保存（AppBar）
    final saveIcon = find.byIcon(Icons.save).hitTestable();
    await pumpUntilFound(tester, saveIcon);

    await tester.tap(saveIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600)); // pop完了目安

    // 8) 保存後に詳細へ戻り、表示が更新されている
    await pumpUntilFound(tester, find.text('メモ詳細').hitTestable());

    // 「更新後タイトル」が見えることを待つ
    await pumpUntilFound(tester, find.text('更新後タイトル').hitTestable());

    // 「初期タイトル」が “見えていない” ことを保証（ツリー残存を避ける）
    await pumpUntilGone(tester, find.text('初期タイトル').hitTestable());
    expect(find.text('初期タイトル').hitTestable(), findsNothing);
  });
}
