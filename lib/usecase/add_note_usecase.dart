import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/note_list_rules.dart';

class AddNoteUsecase {
  final NoteRepository _repo;

  AddNoteUsecase(this._repo);

  Future<List<Note>> execute({
    required String title,
    required String body,
    required String tag,
  }) async {
    final trimmed = title.trim();
    final notes = await _repo.load(); // load 1回

    // タイトルが空の場合は追加せず、現在の一覧をそのまま返す
    if (trimmed.isEmpty) {
      return NoteListRules.pinnedFirst(notes);
    }

    notes.add(Note(title: trimmed, body: body, tag: tag));
    await _repo.save(notes); // save 1回

    return NoteListRules.pinnedFirst(notes);
  }
}
