import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

import '../fakes/in_memory_store.dart';

void main() {
  test('load: nullなら空リスト', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final loaded = await repo.load();
    expect(loaded, isEmpty);
  });

  test('load: 不正JSONが混ざっていてもクラッシュせず有効分だけ復元', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final ok1 = jsonEncode(Note(title: 'A', body: 'b', tag: '仕事').toMap());
    final broken = '{ invalid json';
    final ok2 = jsonEncode(Note(title: 'B', body: 'b', tag: '仕事').toMap());

    await store.setStringList('notes', [ok1, broken, ok2]);

    final loaded = await repo.load();
    expect(loaded.length, 2);
    expect(loaded[0].title, 'A');
    expect(loaded[1].title, 'B');
  });

  test('load: JSONは読めるがMapではない要素はスキップ', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final ok = jsonEncode(Note(title: 'A', body: 'b', tag: '仕事').toMap());
    final notMap = jsonEncode([1, 2,3]); // List

    await store.setStringList('notes', [ok, notMap]);

    final loaded = await repo.load();
    expect(loaded.length, 1);
    expect(loaded.first.title, 'A');
  });

  test('load: Mapでも必須キー欠損の要素はスキップ（fromMapが例外を投げる前提）', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final ok = jsonEncode(Note(title: 'A', body: 'b', tag: '仕事').toMap());
    final missing = jsonEncode({'id': 999}); // title等が欠損

    await store.setStringList('notes', [ok, missing]);

    final loaded = await repo.load();
    expect(loaded.length, 1);
    expect(loaded.first.title, 'A');
  });
}