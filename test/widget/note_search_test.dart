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
    Note(title: '仕事メモA', body: '本文A', tag: '仕事'),
    Note(title: '仕事メモB', body: '本文B', tag: '仕事'),
    Note(title: '私用メモC', body: '本文C', tag: 'プライベート'),
  ];
  await repo.save(notes);
}

Future<void> _seedInitialNotes(
  InMemoryStore store,
  List<Note> initialNotes,
) async {
  Note.resetCounter();
  final repo = NoteRepository(store);
  await repo.save(initialNotes);
}

/// 検索ダイアログを開いて検索実行（ダイアログ配下に限定して操作する）
Future<void> _openSearchDialogAndSearch(
  WidgetTester tester,
  String query,
) async {
  // 検索アイコンを「押せるもの」に限定
  final searchIcon = find.byIcon(Icons.search).hitTestable();
  await pumpUntilFound(tester, searchIcon);
  await tester.tap(searchIcon);
  await tester.pump(); // ダイアログ描画開始

  final dialog = find.byType(AlertDialog).hitTestable();
  await pumpUntilFound(tester, dialog);

  final tf = find.descendant(of: dialog, matching: find.byType(TextField));
  await pumpUntilFound(tester, tf);
  await tester.enterText(tf, query);
  await tester.pump();

  final searchBtn = find
      .descendant(of: dialog, matching: find.widgetWithText(TextButton, '検索'))
      .hitTestable();

  await pumpUntilFound(tester, searchBtn);
  await tester.tap(searchBtn);
  await tester.pump(); // 絞り込み反映開始

  // 画面側の rebuild まで少し進める（pumpAndSettle回避）
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('検索アイコン押下で検索ダイアログが開く', (tester) async {
    await setTestSurfaceSize(tester);

    final store = InMemoryStore();
    // ダイアログ表示だけなら seed 不要だが、画面が安定するよう最低限 1件入れてもOK
    await _seedInitialNotes(store, [
      Note(title: 'メモA', body: '本文A', tag: '仕事'),
    ]);

    await tester.pumpWidget(
      buildTestApp(home: const NoteListScreen(), storeOverride: store),
    );

    await pumpUntilFound(tester, find.text('Tagged Notes').hitTestable());

    // 検索アイコン tap → AlertDialog 表示確認
    final searchIcon = find.byIcon(Icons.search).hitTestable();
    await pumpUntilFound(tester, searchIcon);
    await tester.tap(searchIcon);
    await tester.pump();

    final dialog = find.byType(AlertDialog).hitTestable();
    await pumpUntilFound(tester, dialog);

    expect(find.text('検索キーワード'), findsOneWidget);
    expect(find.textContaining('タイトルや本文を検索'), findsOneWidget);
  });

  testWidgets('検索キーワードで一覧が絞り込まれる', (tester) async {
    await setTestSurfaceSize(tester);

    final store = InMemoryStore();
    await _seedInitialNotes(store, [
      Note(title: 'りんごメモ', body: '買うもの：りんご', tag: 'プライベート'),
      Note(title: '会議メモ', body: '議題：週次MTG', tag: '仕事'),
    ]);

    await tester.pumpWidget(
      buildTestApp(home: const NoteListScreen(), storeOverride: store),
    );

    await pumpUntilFound(tester, find.text('Tagged Notes').hitTestable());

    // 起動直後：2件見える
    await pumpUntilFound(tester, find.text('りんごメモ').hitTestable());
    await pumpUntilFound(tester, find.text('会議メモ').hitTestable());

    // 検索「りんご」
    await _openSearchDialogAndSearch(tester, 'りんご');

    // 絞り込み結果：りんごメモだけ
    await pumpUntilFound(tester, find.text('りんごメモ').hitTestable());
    expect(find.text('会議メモ'), findsNothing);
  });

  // feature/widget-test-tag-and-search
  testWidgets('タグ絞り込み後、検索でさらに絞り込める（AND条件）', (tester) async {
    // 縦長にしてチップ等が出やすいように
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final store = InMemoryStore();
    await _seedNotes(store);

    await tester.pumpWidget(
      buildTestApp(home: const NoteListScreen(), storeOverride: store),
    );

    await pumpUntilFound(tester, find.text('Tagged Notes').hitTestable());

    // まず全件が見える
    await pumpUntilFound(tester, find.text('仕事メモA').hitTestable());
    await pumpUntilFound(tester, find.text('仕事メモB').hitTestable());
    await pumpUntilFound(tester, find.text('私用メモC').hitTestable());

    // 1) タグ「仕事」を選択 → 仕事だけになる
    final workChip = find.widgetWithText(ChoiceChip, '仕事').hitTestable();
    await pumpUntilFound(tester, workChip);
    await tester.tap(workChip);
    await tester.pump(const Duration(milliseconds: 200));

    await pumpUntilFound(tester, find.text('仕事メモA').hitTestable());
    await pumpUntilFound(tester, find.text('仕事メモB').hitTestable());
    expect(find.text('私用メモC'), findsNothing);

    // 2) 検索「B」 → 仕事メモBだけ
    await _openSearchDialogAndSearch(tester, 'B');

    expect(find.text('仕事メモA'), findsNothing);
    await pumpUntilFound(tester, find.text('仕事メモB').hitTestable());
    expect(find.text('私用メモC'), findsNothing);
  });
}
