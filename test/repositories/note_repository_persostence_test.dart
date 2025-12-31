import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import '../fakes/in_memory_store.dart';

void main() {
  test('save -> load で複数件のノートが復元される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final notes = [
      Note(title: 'A', body: 'bodyA', tag: '仕事'),
      Note(title: 'B', body: 'bodyB', tag: 'プライベート'),
    ];
    await repo.save(notes);

    final loaded = await repo.load();

    expect(loaded.length, 2);
    expect(loaded[0].title, 'A');
    expect(loaded[1].title, 'B');
  });

  test('isPinned が save -> load で保持される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final n = Note(title: 'A', body: 'bodyA', tag: '仕事');
    n.togglePin(); // pinned = true

    await repo.save([n]);
    final loaded = await repo.load();

    expect(loaded.length, 1);
    expect(loaded.first.isPinned, isTrue);
  });

  test('createdAt が save -> load で保持される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    final n = Note(title: 'A', body: 'bodyA', tag: '仕事');

    await repo.save([n]);
    final loaded = await repo.load();

    expect(loaded.length, 1);

    // DateTimeは完全一致できる設計（toMap/fromMapがISO文字列などで正しく往復できている前提）
    expect(loaded.first.createdAt, equals(n.createdAt));
  });

  test('空リストを保存すると load も空になる', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    await repo.save([]);
    final loaded = await repo.load();

    expect(loaded, isEmpty);
  });

  test('上書き保存すると最新状態で復元される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);

    await repo.save([Note(title: 'A', body: 'bodyA', tag: '仕事')]);
    await repo.save([Note(title: 'B', body: 'bodyB', tag: '仕事')]);

    final loaded = await repo.load();
    expect(loaded.length, 1);
    expect(loaded.first.title, 'B');
  });
}
