import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

import '../fakes/in_memory_store.dart';

const storageKey = 'notes';

void main() {
  test('load: v0を読み込んだら self-heal で v1形式に再保存される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final v0 = jsonEncode({
      'id': 1,
      'title': 'old',
      'body': 'b',
      'tag': '仕事',
      // schemaVersion / isPinned / createdAt なし
    });

    await store.setStringList(storageKey, [v0]);

    final loaded = await repo.load();
    expect(loaded.length, 1);
    expect(loaded.first.title, 'old');

    // ★ self-heal 後の保存内容を検証
    final saved = await store.getStringList(storageKey);
    expect(saved, isNotNull);
    expect(saved!.length, 1);

    final savedMap = jsonDecode(saved.first) as Map<String, dynamic>;
    expect(savedMap['schemaVersion'], NoteRepository.currentSchemaVersion);
    expect(savedMap.containsKey('isPinned'), isTrue);
    expect(savedMap.containsKey('createdAt'), isTrue);
  });
}