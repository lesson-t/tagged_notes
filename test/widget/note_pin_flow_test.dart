import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';
import 'package:tagged_notes/widgets/note_list_item.dart';

import '../fakes/fake_note_repository.dart';

Widget _buildTestApp({required NoteProvider provider}) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(home: NoteListScreen()),
  );
}

NoteProvider _createProviderWithFakeRepo({List<Note>? initalNotes}) {
  final repo = FakeNoteRepository(initial: initalNotes);

  // 位置引数（main.dart で NoteProvider(repo)）
  return NoteProvider(repo);
}

/// 2件投入（順番が大事）
Future<void> _seedTwoNotes(NoteProvider provider) async {
  await provider.addNote('メモA', '本文A', '仕事');
  await provider.addNote('メモB', '本文B', '仕事');
}

/// 「title を含む NoteListItem」の中のピンアイコンを押す
Future<void> _tapPinById(WidgetTester tester, int noteId) async {
  final pinButton = find.byKey(ValueKey('pin_button_$noteId'));
  expect(pinButton, findsOneWidget);

  await tester.tap(pinButton);
  await tester.pumpAndSettle();
}

/// 一覧の先頭 NoteListItem が、指定タイトルを含むかを検証
void _expectFirstItemHasTitle(WidgetTester tester, String title) {
  final firstItem = find.byType(NoteListItem).first;
  expect(firstItem, findsOneWidget);

  expect(
    find.descendant(of: firstItem, matching: find.text(title)),
    findsOneWidget,
  );
}

void main() {
  Finder itemOf(String title) =>
      find.ancestor(of: find.text(title), matching: find.byType(NoteListItem));

  Finder outlinedInItem(String title) => find.descendant(
    of: itemOf(title),
    matching: find.byIcon(Icons.push_pin_outlined),
  );

  Finder filledInItem(String title) =>
      find.descendant(of: itemOf(title), matching: find.byIcon(Icons.push_pin));

  testWidgets('ピン切替でアイコンが変わる', (tester) async {
    final provider = _createProviderWithFakeRepo(initalNotes: []);

    await provider.addNote('メモA', '本文A', '仕事');
    final idA = provider.notes.first.id; // ★ 実IDを取得

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    // 初期：未ピン
    expect(itemOf('メモA'), findsOneWidget);
    expect(outlinedInItem('メモA'), findsOneWidget);
    expect(filledInItem('メモA'), findsNothing);

    // ピンON
    await _tapPinById(tester, idA);
    expect(filledInItem('メモA'), findsOneWidget);
    expect(outlinedInItem('メモA'), findsNothing);

    // ピンOFF
    await _tapPinById(tester, idA);
    expect(outlinedInItem('メモA'), findsOneWidget);
    expect(filledInItem('メモA'), findsNothing);
  });

  testWidgets('ピン留めすると一覧の先頭に移動し、解除で戻る', (tester) async {
    final provider = _createProviderWithFakeRepo();
    await _seedTwoNotes(provider); // A(id=0), B(id=1)

    // ★ 実IDを取得（タイトルで引く）
    // final idA = provider.notes.firstWhere((n) => n.title == 'メモA').id;
    final idB = provider.notes.firstWhere((n) => n.title == 'メモB').id;

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    // 前提：A/B が表示されている
    expect(find.text('メモA'), findsOneWidget);
    expect(find.text('メモB'), findsOneWidget);

    // 初期は追加順：A → B（先頭は A）
    _expectFirstItemHasTitle(tester, 'メモA');

    // メモBをピン → pinned は先頭に来るはず
    await _tapPinById(tester, idB);
    _expectFirstItemHasTitle(tester, 'メモB');

    // メモBのピン解除 → 元の順序（Aが先頭）に戻るはず
    await _tapPinById(tester, idB);
    _expectFirstItemHasTitle(tester, 'メモA');
  });
}
