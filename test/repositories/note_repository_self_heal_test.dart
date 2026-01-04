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

  test('load: 未来versionはスキップされ、self-healで上書きされない', () async {
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

    // 未来versionだけ入れておく
    await store.setStringList(storageKey, [future]);

    final loaded = await repo.load();
    expect(loaded, isEmpty);

    // ★ self-heal が走っても、空で上書きしないこと
    final after = await store.getStringList(storageKey);
    expect(after, isNotNull);
    expect(after, equals([future]));
  });

  test('load: schemaVersionが同じでも欠損補完が起きたらself-healされる', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final brokenV1 = jsonEncode({
      'schemaVersion': NoteRepository.currentSchemaVersion,
      'id': 1,
      'title': 'v1-but-broken',
      'body': 'b',
      'tag': '仕事',
      'isPinned': false,
      // createdAt が欠損
    });

    await store.setStringList(storageKey, [brokenV1]);

    final loaded = await repo.load();
    expect(loaded.length, 1);

    final saved = await store.getStringList(storageKey);
    expect(saved, isNotNull);
    final savedMap = jsonDecode(saved!.first) as Map<String, dynamic>;
    expect(savedMap.containsKey('createdAt'), isTrue);
  });
}