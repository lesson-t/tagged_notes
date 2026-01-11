import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/storage/key_value_store.dart';

Future<NoteRepository> createRepoSeeded(
  KeyValueStore store, {
  List<Note> initialNotes = const [],
  }) async {
  final repo = NoteRepository(store);

  // 永続化領域に事前投入（UseCaseは repo.load() から読むため）
  await repo.save(initialNotes);
  
  return repo;
}