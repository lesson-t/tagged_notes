import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/add_note_usecase.dart';

import '../fakes/in_memory_store.dart';

void main() {
  test('execute: titleをtrimして保存される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = AddNoteUsecase(repo);

    await uc.execute(title: 'タイトル', body: '本文', tag: '仕事');

    final loaded = await repo.load();
    expect(loaded, hasLength(1));
    expect(loaded.first.title, 'タイトル');
    expect(loaded.first.body, '本文');
    expect(loaded.first.tag, '仕事');
  });

  test('execute: titleが空/空白のみなら何もしない', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = AddNoteUsecase(repo);

    await uc.execute(title: '', body: '本文', tag: '仕事');
    await uc.execute(title: '   ', body: '本文', tag: '仕事');

    final loaded = await repo.load();
    expect(loaded, isEmpty);
  });
}
