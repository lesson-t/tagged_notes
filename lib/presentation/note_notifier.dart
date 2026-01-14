import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagged_notes/di/providers.dart';
import 'package:tagged_notes/models/note.dart';

/// UI からはこの provider だけを見る（Repository/UseCase を直接触らない）
final noteListProvider = AsyncNotifierProvider<NoteListNotifier, List<Note>>(
  NoteListNotifier.new,
);

class NoteListNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final load = ref.read(loadNoteUsecaseProvider);
    return load.execute();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final load = ref.read(loadNoteUsecaseProvider);
      return load.execute();
    });
  }

  Future<void> addNote({
    required String title,
    required String body,
    required String tag,
  }) async {
    state = await AsyncValue.guard(() async {
      final add = ref.read(addNoteUsecaseProvider);
      return add.execute(title: title, body: body, tag: tag);
    });
  }

  Future<void> deleteNote({required int id}) async {
    state = await AsyncValue.guard(() async {
      final del = ref.read(deleteNoteUsecaseProvider);
      return del.execute(id: id);
    });
  }

  Future<void> togglePin({required int id}) async {
    state = await AsyncValue.guard(() async {
      final toggle = ref.read(togglePinUsecaseProvider);
      return toggle.execute(id: id);
    });
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String body,
    required String tag,
  }) async {
    state = await AsyncValue.guard(() async {
      final update = ref.read(updateNoteUsecaseProvider);
      return update.execute(id: id, title: title, body: body, tag: tag);
    });
  }
}
