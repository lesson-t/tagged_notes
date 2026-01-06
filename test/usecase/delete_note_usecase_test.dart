import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/delete_note_usecase.dart';

import '../fakes/in_memory_store.dart';

void main() {
  test('execute: 指定idのノートが削除される', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = DeleteNoteUsecase(repo);

    // 事前に保存しておく（UseCase単体なのでProviderは使わない）

    await repo.save([
      Note(title: 'A', body: 'b', tag: '仕事'),
      Note(title: 'B', body: 'b', tag: '仕事'),
    ]);

    final before = await repo.load();
    final deleteId = before.firstWhere((n) => n.title == 'B').id;

    await uc.execute(id: deleteId);

    final after = await repo.load();
    expect(after.any((n) => n.title == 'B'), isFalse);
    expect(after.any((n) => n.title == 'A'), isTrue);
  });

  test('execute: 存在しないidでもクラッシュせずno-op', () async {
    final store = InMemoryStore();
    final repo = NoteRepository(store);
    final uc = DeleteNoteUsecase(repo);

    await repo.save([Note(title: 'A', body: 'b', tag: '仕事')]);

    await uc.execute(id: 999999);

    final after = await repo.load();
    expect(after, hasLength(1));
    expect(after.first.title, 'A');
  });
}
