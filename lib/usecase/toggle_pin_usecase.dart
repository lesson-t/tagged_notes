import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/note_list_rules.dart';

class TogglePinUsecase {
  final NoteRepository _repo;
  TogglePinUsecase(this._repo);

  Future<List<Note>> execute({required int id}) async {
    final notes = await _repo.load(); // load 1回
    final target = notes.where((n) => n.id == id).toList();

    // 対象なし：保存せずに現状を返
    if (target.isEmpty) {
      return NoteListRules.pinnedFirst(notes);
    }

    target.first.togglePin();
    await _repo.save(notes); // save 1回

    return NoteListRules.pinnedFirst(notes);
  }
}
