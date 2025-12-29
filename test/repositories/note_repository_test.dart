import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

void main() {
  setUp(() {
    // shared_preferences をメモリ上で動かす（端末不要）
    SharedPreferences.setMockInitialValues({});
  });

  test('save -> load でノートが復元される', () async {
    final repo = NoteRepository();

    final notes = [
      Note(title: 't1', body: 'b1', tag: '仕事'),
      Note(title: 't2', body: 'b2', tag: 'その他'),
    ];

    await repo.save(notes);
    final loaded = await repo.load();

    expect(loaded.length, 2);
    expect(loaded[0].title, 't1');
    expect(loaded[1].tag, 'その他');
  });
}
