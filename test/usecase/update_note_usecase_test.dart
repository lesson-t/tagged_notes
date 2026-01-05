import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/update_note_usecase.dart';

import '../fakes/in_memory_store.dart';

void main() {
  test('execute: 指定idのtitle/body/tagが更新され保存される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = UpdateNoteUsecase(repo);

    await repo.save([Note(title: 'A', body: 'b', tag: '仕事')]);
    final before = await repo.load();
    final id = before.first.id;

    expect(before.first.isPinned, isFalse);

    await uc.execute(id: id, title: 'new', body: 'new body', tag: 'その他');

    final after = await repo.load();
    expect(after, hasLength(1));
    expect(after.first.title, 'new');
    expect(after.first.body, 'new body');
    expect(after.first.tag, 'その他');
  });

    test('execute: 存在しないidでもクラッシュせずno-op', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = UpdateNoteUsecase(repo);

    await repo.save([Note(title: 'A', body: 'b', tag: '仕事')]);

    await uc.execute(id: 999999, title: 'x', body: 'y', tag: 'その他');

    final after = await repo.load();
    expect(after, hasLength(1));
    expect(after.first.title, 'A');
  });
}