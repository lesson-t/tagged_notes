import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';

import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';
import 'package:tagged_notes/widgets/note_list_item.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/test_app.dart';

/// 1件投入して id を返す
Future<int> _seedOneNote(InMemoryStore store) async {
  Note.resetCounter();
  final repo = NoteRepository(store);

  final note = Note(title: 'メモA', body: '本文A', tag: '仕事');
  final id = note.id;
  await repo.save([note]);
  return id;
}

/// 2件投入（順番が大事）
Future<({int idA, int idB})> _seedTwoNotes(InMemoryStore store) async {
  Note.resetCounter();
  final repo = NoteRepository(store);

  final noteA = Note(title: 'メモA', body: '本文A', tag: '仕事');
  final noteB = Note(title: 'メモB', body: '本文B', tag: '仕事');

  final ids = (idA: noteA.id, idB: noteB.id);

  await repo.save([noteA, noteB]);
  return ids;
}

/// 「id を持つ NoteListItem の pin ボタン」を押す
Future<void> _tapPinById(WidgetTester tester, int noteId) async {
  final pin = find.byKey(ValueKey('pin_button_$noteId')).hitTestable();

  await pumpUntilFound(tester, pin);
  await tester.tap(pin);
  await tester.pump(); // 反映開始
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
    await setTestSurfaceSize(tester);

    final store = InMemoryStore();
    final idA = await _seedOneNote(store);

    await tester.pumpWidget(
      buildTestApp(home: const NoteListScreen(), storeOverride: store),
    );

    await pumpUntilFound(tester, find.text('Tagged Notes').hitTestable());

    // 一覧に表示されるまで待つ
    await pumpUntilFound(tester, find.text('メモA').hitTestable());

    // 初期：未ピン
    expect(itemOf('メモA'), findsOneWidget);
    expect(outlinedInItem('メモA'), findsOneWidget);
    expect(filledInItem('メモA'), findsNothing);

    // ピンON
    await _tapPinById(tester, idA);
    await tester.pump(const Duration(milliseconds: 100));
    expect(filledInItem('メモA'), findsOneWidget);
    expect(outlinedInItem('メモA'), findsNothing);

    // ピンOFF
    await _tapPinById(tester, idA);
    await tester.pump(const Duration(milliseconds: 100));
    expect(outlinedInItem('メモA'), findsOneWidget);
    expect(filledInItem('メモA'), findsNothing);
  });

  testWidgets('ピン留めすると一覧の先頭に移動し、解除で戻る', (tester) async {
    await setTestSurfaceSize(tester);

    final store = InMemoryStore();
    final ids = await _seedTwoNotes(store); // 追加順：A -> B

    await tester.pumpWidget(
      buildTestApp(home: const NoteListScreen(), storeOverride: store),
    );

    // 一覧が出る
    await pumpUntilFound(tester, find.text('Tagged Notes'));

    // 前提：A/B が表示されている
    await pumpUntilFound(tester, find.text('メモA').hitTestable());
    await pumpUntilFound(tester, find.text('メモB').hitTestable());

    // 初期は追加順：A → B（先頭は A）
    _expectFirstItemHasTitle(tester, 'メモA');

    // メモBをピン → pinned は先頭に来る
    await _tapPinById(tester, ids.idB);
    await tester.pump(const Duration(milliseconds: 150));
    _expectFirstItemHasTitle(tester, 'メモB');

    // メモBのピン解除 → 元の順序（Aが先頭）に戻る
    await _tapPinById(tester, ids.idB);
    await tester.pump(const Duration(milliseconds: 150));
    _expectFirstItemHasTitle(tester, 'メモA');
  });
}
