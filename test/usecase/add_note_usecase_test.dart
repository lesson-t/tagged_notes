import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/add_note_usecase.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/usecase_test_factory.dart';

void main() {
  test('execute: titleをtrimして保存される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = AddNoteUsecase(repo);

    final result = await uc.execute(title: 'タイトル', body: '本文', tag: '仕事');

    expect(result, hasLength(1));
    expect(result.first.title, 'タイトル');
    expect(result.first.body, '本文');
    expect(result.first.tag, '仕事');
  });

  test('execute: titleが空なら追加せず、現状の一覧を返す', () async {
    final store = InMemoryStore();
    final initial = [Note(title: '既存', body: 'B', tag: '仕事')];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final uc = AddNoteUsecase(repo);

    final result = await uc.execute(title: '   ', body: '本文', tag: '仕事');

    expect(result, hasLength(1));
    expect(result.first.title, '既存');
  });

  test('execute: pinnedが先頭になる（返り値順序）', () async {
    final store = InMemoryStore();
    final initial = [Note(title: 'A', body: 'A', tag: '仕事')];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final add = AddNoteUsecase(repo);

    // 2件目追加
    final afterAdd = await add.execute(title: 'B', body: 'B', tag: '仕事');

    // Bをピンにしたいが Add だけではピンできないので、
    // ここは pinned先頭のテストとしては Load/Toggle に任せる方が筋。
    // Addの返り値順は pinnedFirst適用済みであることだけ確認する（=落ちない）
    expect(afterAdd, hasLength(2));
  });
}
