import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagged_notes/di/providers.dart';
import 'package:tagged_notes/models/note.dart';

/// UI からはこの provider だけを見る（Repository/UseCase を直接触らない）
final noteListProvider = AsyncNotifierProvider<NoteListNotifier, List<Note>>(
  NoteListNotifier.new,
);

class NoteListNotifier extends AsyncNotifier<List<Note>> {
  bool _busy = false;
  bool get busy => _busy;

  @override
  Future<List<Note>> build() async {
    final load = ref.read(loadNoteUsecaseProvider);
    return load.execute();
  }

  Future<void> refresh() async {
    await _run(() async {
      final load = ref.read(loadNoteUsecaseProvider);
      return load.execute();
    }, setLoading: true);
  }

  Future<void> addNote({
    required String title,
    required String body,
    required String tag,
  }) async {
    await _run(() async {
      final add = ref.read(addNoteUsecaseProvider);
      return add.execute(title: title, body: body, tag: tag);
    });
  }

  Future<void> deleteNote({required int id}) async {
    await _run(() async {
      final del = ref.read(deleteNoteUsecaseProvider);
      return del.execute(id: id);
    });
  }

  Future<void> togglePin({required int id}) async {
    await _run(() async {
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
    await _run(() async {
      final update = ref.read(updateNoteUsecaseProvider);
      return update.execute(id: id, title: title, body: body, tag: tag);
    });
  }

  Future<void> _run(
    Future<List<Note>> Function() task, {
    bool setLoading = false,
  }) async {
    if (_busy) return;
    _busy = true;

    final previous = state;
    if (setLoading) {
      state = const AsyncLoading();
    }

    try {
      state = await AsyncValue.guard(task);

      // UX方針：失敗時は直前状態へ戻す
      if (state.hasError) {
        state = previous;
      }
    } finally {
      _busy = false;
    }
  }
}
