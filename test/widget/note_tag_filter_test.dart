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

Future<void> _seedNotes(NoteProvider provider) async {
  await provider.addNote('仕事メモ', 'body', '仕事');
  await provider.addNote('私用メモ', 'body', 'プライベート');
  await provider.addNote('その他メモ', 'body', 'その他');

}

void main() {
  testWidgets('初期状態では「すべて」が選択され、全件が表示される', (tester) async {
    final provider = _createProviderWithFakeRepo();
    await _seedNotes(provider);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle(); 

    // 全件のタイトルが表示される
    expect(find.text('仕事メモ'), findsOneWidget);
    expect(find.text('私用メモ'), findsOneWidget);
    expect(find.text('その他メモ'), findsOneWidget);

    // ChoiceChip の selected 状態を直接検証
    final chipAll = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'すべて'));
    expect(chipAll.selected, isTrue);
  });

  testWidgets('タグ「仕事」を選択すると仕事メモのみ表示される', (tester) async {
    final provider = _createProviderWithFakeRepo();
    await _seedNotes(provider);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle(); 

    // 「仕事」チップを押して絞り込み
    await tester.tap(find.widgetWithText(ChoiceChip, '仕事'));
    await tester.pumpAndSettle();

    // 仕事だけ残る
    expect(find.text('仕事メモ'), findsOneWidget);
    expect(find.text('私用メモ'), findsNothing);
    expect(find.text('その他メモ'), findsNothing);

    // selected 状態の確認
    final chipWork = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '仕事'));
    expect(chipWork.selected, isTrue);

    final chipAll = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'すべて'));
    expect(chipAll.selected, isFalse);
  });
}