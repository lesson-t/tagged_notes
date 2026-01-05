import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

class LoadNoteUsecase {
  final NoteRepository _repo;

  LoadNoteUsecase(this._repo);

  Future<List<Note>> execute() async {
    final notes = await _repo.load();

    final pinned = notes.where((n) => n.isPinned).toList();
    final others = notes.where((n) => !n.isPinned).toList();

    return [...pinned, ...others];
  }
}
