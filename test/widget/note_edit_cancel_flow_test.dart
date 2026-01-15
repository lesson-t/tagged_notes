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

  final note = Note(title: '元タイトル', body: '元本文', tag: '仕事');
  await repo.save([note]);
}

void main() {
  testWidgets('編集画面で変更しても、保存せずに戻ると詳細は更新されない', (tester) async {
    await setTestSurfaceSize(tester);

    // 1) store を用意して seed
    final store = InMemoryStore();
    await _seedOneNote(store);
    
    // 2) ProviderScope を InMemoryStore で上書きしてアプリを起動
    await tester.pumpWidget(buildTestApp(
      home: const NoteListScreen(),
      storeOverride: store,
      ));
    await pumpUntilFound(tester, find.text('Tagged Notes'));

    // 3) 一覧に seeded note が出ている
    await pumpUntilFound(tester, find.text('元タイトル'));
    await tester.tap(find.text('元タイトル'));
    await tester.pump();

    // 4) 詳細に元タイトル/元本文が表示
    await pumpUntilFound(tester, find.text('メモ詳細'));
    expect(find.text('元タイトル'), findsAtLeastNWidgets(1));
    expect(find.text('元本文'), findsAtLeastNWidgets(1));

    // 5) 詳細 → 編集
    final editIcon = find.byIcon(Icons.edit);
    await pumpUntilFound(tester, editIcon);

    // 「ヒットテスト可能なもの」だけに絞る
    final editHit = editIcon.hitTestable();
    await pumpUntilFound(tester, editHit);

    await tester.tap(editHit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await pumpUntilFound(tester, find.byType(NoteEditScreen));
    expect(find.text('メモを編集'), findsOneWidget);

    // 6) 未保存で変更
    final titleField = find.widgetWithText(TextField, 'タイトル');
    final bodyField = find.widgetWithText(TextField, '本文');

    await pumpUntilFound(tester, titleField);
    await pumpUntilFound(tester, bodyField);

    await tester.enterText(titleField, '変更後タイトル');
    await tester.enterText(bodyField, '変更後本文');
    await tester.pump();

    // 7) 保存せずに戻る
    final back = find.byType(BackButton).hitTestable();
    await pumpUntilFound(tester, back);
    await tester.tap(back);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // 8) 詳細に戻ったことを保証
    await pumpUntilFound(tester, find.text('メモ詳細').hitTestable());
    
    // 編集画面が“見えていない”こと（ツリー上に残っていても良い）
    expect(find.text('メモを編集').hitTestable(), findsNothing);

    // 元の表示を確認
    expect(find.text('元タイトル'), findsAtLeastNWidgets(1));
    expect(find.text('元本文'), findsAtLeastNWidgets(1));
  });
}
