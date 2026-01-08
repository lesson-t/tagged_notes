import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/note_list_rules.dart';

class UpdateNoteUsecase {
  final NoteRepository _repo;

  UpdateNoteUsecase(this._repo);

  Future<List<Note>> execute({
    required int id,
    required String title,
    required String body,
    required String tag,
  }) async {
    final notes = await _repo.load(); // load 1回
    final targets = notes.where((n) => n.id == id).toList();

    if (targets.isEmpty) {
      return NoteListRules.pinnedFirst(notes);
    }

    targets.first.update(title: title.trim(), body: body, tag: tag);

    await _repo.save(notes); // save 1回// save 1回

    return NoteListRules.pinnedFirst(notes);
  }
}
