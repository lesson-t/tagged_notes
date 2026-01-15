import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';

import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/test_app.dart';


Future<void> _seedNotes(InMemoryStore store) async {
  Note.resetCounter();
  final repo = NoteRepository(store);

  final notes = [
    Note(title: '仕事メモ', body: 'body', tag: '仕事'),
    Note(title: '私用メモ', body: 'body', tag: 'プライベート'),
    Note(title: 'その他メモ', body: 'body', tag: 'その他'),
  ];
  await repo.save(notes);
}

Finder chipByLabel(String label) =>
    find.widgetWithText(ChoiceChip, label).hitTestable();

ChoiceChip readChip(WidgetTester tester, String label) {
  final f = chipByLabel(label);
  expect(f, findsOneWidget);
  return tester.widget<ChoiceChip>(f);
}

Future<void> setTallSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 2000));
  addTearDown(() async => tester.binding.setSurfaceSize(null));
}

void main() {
  testWidgets('初期状態では「すべて」が選択され、全件が表示される', (tester) async {
    await setTallSurface(tester);

    final store = InMemoryStore();
    await _seedNotes(store);

    await tester.pumpWidget(buildTestApp(
      home: const NoteListScreen(),
      storeOverride: store,
    ));

    await pumpUntilFound(tester, find.text('Tagged Notes').hitTestable());

    // 起動直後、全件が見える
    await pumpUntilFound(tester, find.text('仕事メモ').hitTestable());
    await pumpUntilFound(tester, find.text('私用メモ').hitTestable());
    await pumpUntilFound(tester, find.text('その他メモ').hitTestable());

    // 「すべて」チップが表示中で selected
    await pumpUntilFound(tester, chipByLabel('すべて'));
    expect(readChip(tester, 'すべて').selected, isTrue);

    // 他のチップが未選択を確認
    expect(readChip(tester, '仕事').selected, isFalse);
  });

  testWidgets('タグ「仕事」を選択すると仕事メモのみ表示される', (tester) async {
    await setTallSurface(tester);

    final store = InMemoryStore();
    await _seedNotes(store);

    await tester.pumpWidget(buildTestApp(
      home: const NoteListScreen(),
      storeOverride: store,
    ));

    await pumpUntilFound(tester, find.text('Tagged Notes').hitTestable());

    // 「仕事」チップを押す（表示中のチップを確実に押す）
    await pumpUntilFound(tester, chipByLabel('仕事'));
    await tester.tap(chipByLabel('仕事'));
    await tester.pump(); // 状態反映開始

    // 絞り込み結果が「表示中」になるまで待つ
    await pumpUntilFound(tester, find.text('仕事メモ').hitTestable());

    // 他の項目は表示されない（hitTestableではなく通常findで十分）
    expect(find.text('私用メモ'), findsNothing);
    expect(find.text('その他メモ'), findsNothing);

    // selected 状態の確認（表示中のチップに限定して読む）
    expect(readChip(tester, '仕事').selected, isTrue);
    expect(readChip(tester, 'すべて').selected, isFalse);
  });
}
