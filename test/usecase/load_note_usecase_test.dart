import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/load_note_usecase.dart';

import '../fakes/in_memory_store.dart';

void main() {
  test('execute: pinnedが先頭に来る', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = LoadNoteUsecase(repo);

    final a = Note(title: 'A', body: 'b', tag: '仕事'); // not pinned
    final b = Note(title: 'B', body: 'b', tag: '仕事');
    b.togglePin();

    await repo.save([a, b]);

    final loaded = await uc.execute();
    expect(loaded, hasLength(2));
    expect(loaded.first.title, 'B');
    expect(loaded.last.title, 'A');
  });

  test('execute: pinnedが複数ある場合は pinned群→others群 の順', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = LoadNoteUsecase(repo);

    final a = Note(title: 'A', body: 'b', tag: '仕事');
    final b = Note(title: 'B', body: 'b', tag: '仕事')..togglePin();
    final c = Note(title: 'C', body: 'b', tag: '仕事')..togglePin();

    await repo.save([a, b, c]);

    final loaded = await uc.execute();
    expect(loaded.map((e) => e.title).toList(), ['B', 'C', 'A']);
  });
}
