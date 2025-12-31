import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

import '../fakes/in_memory_store.dart';

NoteProvider _createProvider() {
  final store = InMemoryStore();
  final repo = NoteRepository(store);
  return NoteProvider(repo);
}

void main() {
  test('addNote: タイトルが空/空白のみの場合は追加されない', () async {
    final provider = _createProvider();

    await provider.addNote('', '本文', '仕事');
    await provider.addNote('   ', '本文', '仕事');
    await provider.addNote('\n', '本文', '仕事');

    expect(provider.notes, isEmpty);
  });
}