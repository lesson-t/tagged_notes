import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

class LoadNoteUsecase {
  final NoteRepository _repo;

  LoadNoteUsecase(this._repo);

  Future<List<Note>> execute() => _repo.load();
}