import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/usecase/load_note_usecase.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/usecase_test_factory.dart';

void main() {
  setUp(() {
    Note.resetCounter();
  });

  test('execute: pinnedが先頭に来る', () async {
    final store = InMemoryStore();

    final a = Note(title: 'A', body: 'A', tag: '仕事');
    final b = Note(title: 'B', body: 'B', tag: '仕事')..togglePin();

    final repo = await createRepoSeeded(store, initialNotes: [a, b]);
    final uc = LoadNoteUsecase(repo);

    final result = await uc.execute();

    expect(result.first.title, 'B');
    expect(result.first.isPinned, isTrue);
  });
}
