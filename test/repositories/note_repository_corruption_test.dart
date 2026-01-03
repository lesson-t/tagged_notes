import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

import '../fakes/in_memory_store.dart';

void main() {
  test('load: nullなら空リスト', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final loaded = await repo.load();
    expect(loaded, isEmpty);
  });
}