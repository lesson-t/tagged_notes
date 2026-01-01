import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

import '../fakes/in_memory_store.dart';

Widget _buildTestApp({required NoteProvider provider}) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(home: NoteListScreen()),
  );
}

NoteProvider _createProvider() {
  final store = InMemoryStore();
  final repo = NoteRepository(store);
  return NoteProvider(repo);
}

Future<void> seed(NoteProvider provider) async {
  await provider.addNote('仕事メモA', '本文', '仕事');
}

Future<void> openSearchAndSearch(WidgetTester tester, String query) async {
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();

  final dialog = find.byType(AlertDialog);
  final tf = find.descendant(of: dialog, matching: find.byType(TextField));
  await tester.enterText(tf, query);
  await tester.pumpAndSettle();

  final searchBtn = find.descendant(
    of: dialog,
    matching: find.widgetWithText(TextButton, '検索'),
  );
  await tester.tap(searchBtn);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('検索で0件になると「条件に一致するメモがありません。」が表示される', (tester) async {
    final provider = _createProvider();
    await seed(provider);

    await tester.pumpWidget(_buildTestApp(provider: provider));
    await tester.pumpAndSettle();

    // 0件になる検索
    await openSearchAndSearch(tester, '存在しないキーワード');

    expect(find.text('仕事メモA'), findsNothing);
    expect(find.text('条件に一致するメモがありません。'), findsOneWidget);
  });
}
