import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/note_list_rules.dart';

class DeleteNoteUsecase {
  final NoteRepository _repo;
  DeleteNoteUsecase(this._repo);

  Future<List<Note>> execute({required int id}) async {
    final notes = await _repo.load();
    final before = notes.length;

    notes.removeWhere((n) => n.id == id);

    // 変化があった時だけ save（不要I/O削減）
    if (notes.length != before) {
      await _repo.save(notes); // save 1回（条件付き）
    }
    // await _repo.save(notes);

    return NoteListRules.pinnedFirst(notes);
  }
}
