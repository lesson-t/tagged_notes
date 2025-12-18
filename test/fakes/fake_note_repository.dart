import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';

class FakeNoteRepository extends NoteRepository {
  List<Note> _store;
  int saveCallCount = 0;

  FakeNoteRepository({List<Note>? initial}) : _store = initial ?? [];

  @override
  Future<List<Note>> load() async {
    // 参照渡し事故を防ぐためにコピーで返す
    return List<Note>.from(_store);
  }

  @override
  Future<void> save(List<Note> notes) async {
    saveCallCount++;
    _store = List<Note>.from(notes);
  }
}