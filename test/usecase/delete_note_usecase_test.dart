import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/usecase/delete_note_usecase.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/usecase_test_factory.dart';

void main() {
  test('execute: 指定idのノートが削除される', () async {
    final store = InMemoryStore();
    final initial = [
      Note(title: 'A', body: 'A', tag: '仕事'),
      Note(title: 'B', body: 'B', tag: '仕事'),
    ];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final uc = DeleteNoteUsecase(repo);

    final idA = initial.first.id; // Noteが自動採番でidを持つ
    final result = await uc.execute(id: idA);

    expect(result.any((n) => n.id == idA), isFalse);
    expect(result, hasLength(1));
    expect(result.first.title, 'B');
  });

  test('execute: 存在しないidでも落ちず、現状の一覧を返す(no-op)', () async {
    final store = InMemoryStore();
    final initial = [Note(title: 'A', body: 'A', tag: '仕事')];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final uc = DeleteNoteUsecase(repo);

    final result = await uc.execute(id: 999999);

    expect(result, hasLength(1));
    expect(result.first.title, 'A');
  });
}
