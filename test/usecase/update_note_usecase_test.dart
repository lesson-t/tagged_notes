import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/usecase/update_note_usecase.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/usecase_test_factory.dart';

void main() {
  setUp(() {
    Note.resetCounter();
  });
  
  test('execute: 指定idのtitle/body/tagが更新され、返り値に反映される', () async {
    final store = InMemoryStore();
    final initial = [Note(title: 'A', body: 'A', tag: '仕事')];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final uc = UpdateNoteUsecase(repo);

    final idA = initial.first.id;

    final after = await uc.execute(
      id: idA,
      title: '更新後',
      body: '本文2',
      tag: 'プライベート',
    );

    final updated = after.firstWhere((n) => n.id == idA);
    expect(updated.title, '更新後');
    expect(updated.body, '本文2');
    expect(updated.tag, 'プライベート');
  });

  test('execute: 存在しないidでもクラッシュせずno-op', () async {
    final store = InMemoryStore();
    final initial = [Note(title: 'A', body: 'A', tag: '仕事')];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final uc = UpdateNoteUsecase(repo);

    final result = await uc.execute(
      id: 999999,
      title: '更新後',
      body: '本文2',
      tag: '仕事',
    );

    expect(result, hasLength(1));
    expect(result.first.title, 'A');
  });

    test('execute: titleが空（trim後）なら no-op（更新しない）', () async {
    final store = InMemoryStore();
    final initial = [Note(title: 'A', body: 'A', tag: '仕事')];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final uc = UpdateNoteUsecase(repo);

    final idA = initial.first.id;

    final after = await uc.execute(
      id: idA,
      title: '   ',
      body: '本文2',
      tag: 'プライベート',
    );

    final kept = after.firstWhere((n) => n.id == idA);
    // 変わっていないことを確認
    expect(kept.title, 'A');
    expect(kept.body, 'A');
    expect(kept.tag, '仕事');
  });
}
