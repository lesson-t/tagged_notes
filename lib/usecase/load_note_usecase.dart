import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/note_list_rules.dart';

class LoadNoteUsecase {
  final NoteRepository _repo;
  LoadNoteUsecase(this._repo);

  Future<List<Note>> execute() async {
    final notes = await _repo.load();
    return NoteListRules.pinnedFirst(notes);
  }
}
