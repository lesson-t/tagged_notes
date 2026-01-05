import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/toggle_pin_usecase.dart';

import '../fakes/in_memory_store.dart';

void main() {
  test('execute: isPinnedが反転して保存される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = TogglePinUsecase(repo);

    await repo.save([Note(title: 'A', body: 'b', tag: '仕事')]);
    final before = await repo.load();
    final id = before.first.id;

    expect(before.first.isPinned, isFalse);

    await uc.execute(id);

    final after1 = await repo.load();
    expect(after1.first.isPinned, isTrue);

    await uc.execute(id);

    final after2 = await repo.load();
    expect(after2.first.isPinned, isFalse);
  });

    test('execute: 存在しないidでもクラッシュせずno-op', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = TogglePinUsecase(repo);

    await repo.save([Note(title: 'A', body: 'b', tag: '仕事')]);

    await uc.execute(999999);

    final after = await repo.load();
    expect(after, hasLength(1));
    expect(after.first.isPinned, isFalse);
  });
}