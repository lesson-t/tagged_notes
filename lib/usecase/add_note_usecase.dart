import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

class AddNoteUsecase {
  final NoteRepository _repo;

  AddNoteUsecase(this._repo);

  Future<void> execute({
    required String title,
    required String body,
    required String tag,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final notes = await _repo.load();
    notes.add(Note(title: trimmed, body: body, tag: tag));

    await _repo.save(notes);
  }
}
