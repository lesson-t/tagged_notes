import 'package:tagged_notes/repositories/note_repository.dart';

class UpdateNoteUsecase {
  final NoteRepository _repo;

  UpdateNoteUsecase(this._repo);

  Future<void> execute({
    required int id,
    required String title,
    required String body,
    required String tag,
  }) async {
    final notes = await _repo.load();
    final note = notes.where((n) => n.id == id).toList();
    if (note.isEmpty) return;

    note.first.update(title: title.trim(), body: body, tag: tag);
    await _repo.save(notes);
  }
}
