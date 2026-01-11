import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/usecase/toggle_pin_usecase.dart';

import '../fakes/in_memory_store.dart';
import '../helpers/usecase_test_factory.dart';

void main() {
  test('execute: isPinnedが反転し、返り値に反映される', () async {
    final store = InMemoryStore();
    final initial = [Note(title: 'A', body: 'A', tag: '仕事')];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final uc = TogglePinUsecase(repo);

    final idA = initial.first.id;

    final afterOn = await uc.execute(id: idA);
    final a1 = afterOn.firstWhere((n) => n.id == idA);
    expect(a1.isPinned, isTrue);

    final afterOff = await uc.execute(id: idA);
    final a2 = afterOff.firstWhere((n) => n.id == idA);
    expect(a2.isPinned, isFalse);
  });

  test('execute: pinnedが先頭に来る（返り値順序）', () async {
    final store = InMemoryStore();
    final initial = [
      Note(title: 'A', body: 'A', tag: '仕事'),
      Note(title: 'B', body: 'B', tag: '仕事'),
    ];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final uc = TogglePinUsecase(repo);

    final idB = initial[1].id;

    final after = await uc.execute(id: idB);

    expect(after.first.id, idB);
    expect(after.first.isPinned, isTrue);
  });

  test('execute: 存在しないidでも落ちず、現状の一覧を返す', () async {
    final store = InMemoryStore();
    final initial = [Note(title: 'A', body: 'A', tag: '仕事')];
    final repo = await createRepoSeeded(store, initialNotes: initial);
    final uc = TogglePinUsecase(repo);

    final result = await uc.execute(id: 999999);

    expect(result, hasLength(1));
    expect(result.first.title, 'A');
  });
}
