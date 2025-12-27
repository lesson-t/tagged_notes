import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

void main() {
  late NoteRepository repo;

  setUp(() {
    // 各テストを独立させる（前の保存内容を残さない）
    SharedPreferences.setMockInitialValues({});
    repo = NoteRepository();
  });

  test('save -> load で複数件のノートが復元される', () async {
    final notes = [
      Note(title: 'A', body: 'bodyA', tag: '仕事'),
      Note(title: 'B', body: 'bodyB', tag: 'プライベート'),
    ];

    await repo.save(notes);
    final loaded = await repo.load();

    expect(loaded.length, 2);
    expect(loaded[0].title, 'A');
    expect(loaded[1].title, 'B');
  });
}