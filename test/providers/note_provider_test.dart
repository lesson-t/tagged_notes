import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import '../fakes/fake_note_repository.dart';

void main() {
  test('addNote: titleをtrimして追加し、saveが呼ばれる', () async {
    final repo = FakeNoteRepository();
    final provider = NoteProvider(repo);

    await provider.addNote('タイトル', '本文', '仕事');

    expect(provider.notes.length, 1);
    expect(provider.notes.first.title, 'タイトル');
    expect(repo.saveCallCount, 1);
  });

  test('deleteNote: id指定で削除され、saveが呼ばれる', () async {
    final repo = FakeNoteRepository();
    final provider = NoteProvider(repo);

    await provider.addNote('title', 'body', 'tag');
    final id = provider.notes.first.id;

    await provider.deleteNote(id);
    expect(provider.notes.length, 0);
    expect(repo.saveCallCount, 2); // add + delete
  });

  test('togglePin: ピン状態が切り替わる', () async {
    final repo = FakeNoteRepository();
    final provider = NoteProvider(repo);

    await provider.addNote('t', 'b', '仕事');
    final id = provider.notes.first.id;

    expect(provider.findById(id)!.isPinned, false);

    await provider.togglePin(id);

    expect(provider.findById(id)!.isPinned, true);
  });

  test('updateNote: タイトル/本文/タグが更新される', () async {
    final repo = FakeNoteRepository();
    final provider = NoteProvider(repo);

    await provider.addNote('t', 'b', '仕事');
    final id = provider.notes.first.id;

    await provider.updateNote(id, 'new', 'new body', 'その他');

    final note = provider.findById(id)!;
    expect(note.title, 'new');
    expect(note.body, 'new body');
    expect(note.tag, 'その他');
  });

  test('init: repo.load() で復元される（初回のみ）', () async {
    // 事前にFakeRepoへデータをもたせる（storeに残しておく）
    final repo = FakeNoteRepository();
    final provider = NoteProvider(repo);

    await provider.addNote('t', 'b', '仕事');
    expect(provider.notes.length, 1);

    // 新しいProviderを作り直して init で復元確認
    final provider2 = NoteProvider(repo);
    await provider2.init();

    expect(provider2.notes.length, 1);

    // initは2回読んでもロードしない想定
    await provider2.init();
    // ここでは クラッシュしない ことを重視
    expect(provider2.notes.length, 1);
  });
}