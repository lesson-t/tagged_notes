import 'package:tagged_notes/repositories/note_repository.dart';

class TogglePinUsecase {
  final NoteRepository _repo;

  TogglePinUsecase(this._repo);

  Future<void> execute({required int id}) async {
    final notes = await _repo.load();
    final note = notes.where((n) => n.id == id).toList();

    if (note.isEmpty) return;

    note.first.togglePin();
    await _repo.save(notes);
  }
}
