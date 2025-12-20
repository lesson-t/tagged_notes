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

void main() {
  testWidgets('検索アイコン押下で検索ダイアログが開く', (tester) async {
    final provider = _createProviderWithFakeRepo(initalNotes: []);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle(); // init() が走るなら落ち着くまで待つ

    // 検索アイコンをタップ
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // AlertDialog が表示される
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('検索キーワード'), findsOneWidget);
    expect(find.textContaining('タイトルや本文を検索'), findsOneWidget); 
  });

  testWidgets('検索キーワードで一覧が絞り込まれる', (tester) async {
    // 
    final initial = [
      Note(title: 'りんごメモ', body: '買うもの：りんご', tag: 'プライベート'),
      Note(title: '会議メモ', body: '議題：週次MTG', tag: '仕事'),
    ];
    final provider = _createProviderWithFakeRepo(initalNotes: initial);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle(); 

    // 起動直後：2件見えるはず（最低限タイトルで確認）
    expect(find.text('りんごメモ'), findsOneWidget);
    expect(find.text('会議メモ'), findsOneWidget);

    // 検索アイコンをタップ
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Dialog内のTextFieldへ入力（AlertDialog配下に限定して探すと堅牢）
    final dialogTextField = find.descendant(
      of: find.byType(AlertDialog), 
      matching: find.byType(TextField),
    );
    expect(dialogTextField, findsOneWidget);

    await tester.enterText(dialogTextField, 'りんご');
    await tester.pump();

    // 「検索」ボタンを押す
    await tester.tap(find.text('検索'));
    await tester.pumpAndSettle();

    // 絞り込み結果：りんごメモだけ残る
    expect(find.text('りんごメモ'), findsOneWidget);
    expect(find.text('会議メモ'), findsNothing);
  });
}