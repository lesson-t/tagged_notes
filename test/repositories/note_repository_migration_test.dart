import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

import '../fakes/in_memory_store.dart';

const storageKey = 'notes';

void main() {
  test('load: schemaVersion無し(v0)でもマイグレーションされ復元できる', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    // v0データ（schemaVersion無し / isPinned無し / createdAt無し を想定）
    final v0 = jsonEncode({
      'id': 1,
      'title': 'old',
      'body': 'b',
      'tag': '仕事',
    });

    await store.setStringList(storageKey, [v0]);

    final loaded = await repo.load();
    expect(loaded.length, 1);
    expect(loaded.first.title, 'old');

    // デフォルト補完が効いていること（fromMapが対応している前提）
    expect(loaded.first.isPinned, isFalse);
    expect(loaded.first.createdAt, isNotNull);
    
  });

  test('load: 未来のschemaVersionはスキップされる（クラッシュしない）', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final future = jsonEncode({
      'schemaVersion': 999,
      'id': 1,
      'title': 'future',
      'body': 'b',
      'tag': '仕事',
      'isPinned': false,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await store.setStringList(storageKey, [future]);

    final loaded = await repo.load();
    expect(loaded, isEmpty);
  });

  test('save: schemaVersionが付与されて保存される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    await repo.save([Note(title: 'A', body: 'b', tag: '仕事')]);

    final raw = await store.getStringList(storageKey);
    expect(raw, isNotEmpty);
    final decoded = jsonDecode(raw!.first) as Map<String, dynamic>;

    expect(decoded['schemaVersion'], NoteRepository.currentSchemaVersion);
  });
}