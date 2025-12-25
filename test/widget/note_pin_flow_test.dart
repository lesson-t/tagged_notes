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

/// 2件投入（順番が大事）
Future<void> _seedTwoNotes(NoteProvider provider) async {
  await provider.addNote('メモA', '本文A', '仕事');
  await provider.addNote('メモB', '本文B', '仕事');
}

/// タイトル行（NoteListItem）の親要素を取得して、同じ行のピンボタンを押す
Future<void> _tapPinForTitle(WidgetTester tester, String title) async {
  final tileFinder = find.ancestor(
    of: find.text(title), 
    matching: find.byType(NoteListItem),
  );
  expect(tileFinder, findsOneWidget);

  // NoteListItem内の IconButton を探して押す（ピンボタン想定）
  final pinButtonFinder = find.descendant(
    of: tileFinder, 
    matching: find.byType(IconButton),
  );

  // NoteListItem内にIconButtonが複数ある場合に備えて、pin icon を含むものを優先
  final outlined = find.descendant(
    of: tileFinder, 
    matching: find.byIcon(Icons.push_pin_outlined),
  );
  final filled = find.descendant(
    of: tileFinder, 
    matching: find.byIcon(Icons.push_pin),
  );

  if (outlined.evaluate().isNotEmpty) {
    await tester.tap(outlined);
  } else if (filled.evaluate().isNotEmpty) {
    await tester.tap(filled);
  } else {
    // 最後の手段：IconButtonが1個だけならそれを押す
    expect(pinButtonFinder, findsOneWidget);
    await tester.tap(pinButtonFinder);
  }

  await tester.pumpAndSettle();
}

void main() {

  Finder itemOf(String title) => find.ancestor(
    of: find.text(title),
    matching: find.byType(NoteListItem),
  );

  Finder outlinedInItem(String title) => find.descendant(
    of: itemOf(title),
    matching: find.byIcon(Icons.push_pin_outlined),
  );

  Finder filledInItem(String title) => find.descendant(
    of: itemOf(title),
    matching: find.byIcon(Icons.push_pin),
  );

testWidgets('ピン切替でアイコンが変わる', (tester) async {
  final provider = _createProviderWithFakeRepo(initalNotes: []);
  await provider.addNote('メモA', '本文A', '仕事');

  await tester.pumpWidget(_buildTestApp(provider: provider));
  await tester.pumpAndSettle();

  // 初期：未ピン
  expect(itemOf('メモA'), findsOneWidget);
  expect(outlinedInItem('メモA'), findsOneWidget);
  expect(filledInItem('メモA'), findsNothing);

  // ピンON
  await _tapPinForTitle(tester, 'メモA');
  expect(filledInItem('メモA'), findsOneWidget);
  expect(outlinedInItem('メモA'), findsNothing);

  // ピンOFF
  await _tapPinForTitle(tester, 'メモA');
  expect(outlinedInItem('メモA'), findsOneWidget);
  expect(filledInItem('メモA'), findsNothing);
  });
}