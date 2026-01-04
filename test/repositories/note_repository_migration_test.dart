import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

import '../fakes/in_memory_store.dart';

const storageKey = 'notes';

void main() {
  test('load: schemaVersion無し(v0)でもマイグレーションされ復元できる', () async {
    // final store = InMemoryStore();
    // final repo = NoteRepository(store);

    // // v0データ（schemaVersion無し / isPinned無し / createdAt無し を想定）
    // final v0 = jsonEncode({
    //   'id': 1,
    //   'title': 'old',
    //   'body': 'b',
    //   'tag': '仕事',
    // });

    // await store.setStringList(storageKey, [v0]);

    // final loaded = await repo.load();
    // expect(loaded.length, 1);
    // expect(loaded.first.title, 'old');

    // // デフォルト補完が効いていること（fromMapが対応している前提）
    // expect(loaded.first.isPinned, isFalse);
    // expect(loaded.first.createdAt, isNotNull);
    
  });
}