import 'package:tagged_notes/repositories/note_repository.dart';

class DeleteNoteUsecase {
  final NoteRepository _repo;

  DeleteNoteUsecase(this._repo);

  Future<void> execute(int id) async {
    final notes = await _repo.load();
    notes.removeWhere((n) => n.id == id);
    await _repo.save(notes);
  }
}