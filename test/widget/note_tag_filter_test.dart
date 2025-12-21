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

  await provider.addNote('仕事メモA', '本文A', '仕事');
  await provider.addNote('仕事メモB', '本文B', '仕事');
  await provider.addNote('私用メモC', '本文C', 'プライベート');
}

Future<void> _openSearchDialogAndSearch(WidgetTester tester, String query) async {
  // 検索アイコン → ダイアログ表示
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();

  // // AlertDialog の中の TextField に文字を入れる
  final dialogFinder = find.byType(AlertDialog);
  expect(dialogFinder, findsOneWidget);

  final textFieldInDialog = find.descendant(
    of: dialogFinder, 
    matching: find.byType(TextField),
  );
  expect(textFieldInDialog, findsOneWidget);

  await tester.enterText(textFieldInDialog, query);
  await tester.pump();

  // AlertDialog の actions 内の「検索」ボタン押下
  final searchButtonInDialog = find.descendant(
    of: dialogFinder,
    matching: find.widgetWithText(TextButton, '検索'),
  );
  expect(searchButtonInDialog, findsOneWidget);

  await tester.tap(searchButtonInDialog);
  await tester.pumpAndSettle();
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

  // feature/widget-test-tag-and-search
  testWidgets('タグ絞り込み後、検索でさらに絞り込める（AND条件）', (tester) async {
    // 画面を縦長にして、ListView が全件描画しやすいようにする
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null); // 後片付け
    });

    final provider = _createProviderWithFakeRepo();
    await _seedNotes(provider);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    // まず全件が見える
    expect(find.text('仕事メモA'), findsOneWidget);
    expect(find.text('仕事メモB'), findsOneWidget);
    expect(find.text('私用メモC'), findsOneWidget);

    // 1) タグ「仕事」を選択 → 仕事だけになる
    await tester.tap(find.widgetWithText(ChoiceChip, '仕事'));
    await tester.pumpAndSettle();

    expect(find.text('仕事メモA'), findsOneWidget);
    expect(find.text('仕事メモB'), findsOneWidget);
    expect(find.text('私用メモC'), findsNothing);

    // 2) 検索「B」 → 仕事メモBだけ残る（タグ条件AND検索条件）
    await _openSearchDialogAndSearch(tester, 'B');

    expect(find.text('仕事メモA'), findsNothing);
    expect(find.text('仕事メモB'), findsOneWidget);
    expect(find.text('私用メモC'), findsNothing);
  });
}