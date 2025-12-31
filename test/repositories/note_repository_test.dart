import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

import '../fakes/in_memory_store.dart';

void main() {
  test('save -> load でノートが復元される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final notes = [
      Note(title: 't1', body: 'b1', tag: '仕事'),
      Note(title: 't2', body: 'b2', tag: 'その他'),
    ];

    await repo.save(notes);
    final loaded = await repo.load();

    expect(loaded.length, 2);
    expect(loaded[0].title, 't1');
    expect(loaded[1].tag, 'その他');
  });
}
