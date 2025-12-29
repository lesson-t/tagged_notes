import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

import '../fakes/fake_note_repository.dart';

Widget _buildTestApp({required NoteProvider provider}) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(home: NoteListScreen()),
  );
}

NoteProvider _createProviderWithFakeRepo() {
  final repo = FakeNoteRepository();

  // 位置引数（main.dart で NoteProvider(repo)）
  return NoteProvider(repo);
}

void main() {
  testWidgets('一覧画面が表示され、空状態メッセージが出る', (tester) async {
    final provider = _createProviderWithFakeRepo();

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle(); // init() のmicrotask等を持つ

    expect(find.text('Tagged Notes'), findsOneWidget);
    expect(find.textContaining('まだメモがありません'), findsOneWidget);
  });

  testWidgets('FAB押下で新規メモ画面へ遷移する', (tester) async {
    final provider = _createProviderWithFakeRepo();

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // NoteEditScreen の AppBar タイトル（新規時）
    expect(find.text('新規メモ'), findsOneWidget);
  });

  testWidgets('新規メモを作成して保存すると一覧に反映される', (tester) async {
    final provider = _createProviderWithFakeRepo();

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    // 1) FAB -> 新規メモ画面
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 2) タイトル/本文を入力
    await tester.enterText(find.widgetWithText(TextField, 'タイトル'), 'テストタイトル');
    await tester.enterText(find.widgetWithText(TextField, '本文'), 'テスト本文');
    await tester.pump();

    // 3) 保存アイコン押下
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // 一覧に戻り、作成したメモが表示される
    expect(find.text('テストタイトル'), findsOneWidget);
  });
}
