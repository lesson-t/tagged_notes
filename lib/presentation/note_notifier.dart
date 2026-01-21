import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagged_notes/di/providers.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/presentation/note_list_state.dart';

/// UI からはこの provider だけを見る（Repository/UseCase を直接触らない）
final noteListProvider = AsyncNotifierProvider<NoteListNotifier, NoteListState>(
  NoteListNotifier.new,
);

class NoteListNotifier extends AsyncNotifier<NoteListState> {
  bool _busy = false;
  bool get busy => _busy;

  @override
  Future<NoteListState> build() async {
    final load = ref.read(loadNoteUsecaseProvider);
    final notes = await load.execute();
    return NoteListState(notes: notes, busy: false);
  }

  Future<void> refresh() async {
    if (_busy) return;
    _busy = true;

    final previous = state;

    // 画面側が「loading」を出したいなら AsyncLoading を使うのは refresh のみでOK
    state = const AsyncLoading();

    try {
      final load = ref.read(loadNoteUsecaseProvider);
      final notes = await load.execute();
      state = AsyncData(NoteListState(notes: notes, busy: false));
    } catch (e) {
      state = previous; // UX安定：前状態へ戻す
    } finally {
      _busy = false;
    }
  }

  Future<void> addNote({
    required String title,
    required String body,
    required String tag,
  }) async {
    await _runMutation(() async {
      final add = ref.read(addNoteUsecaseProvider);
      final notes = await add.execute(title: title, body: body, tag: tag);
      return notes;
    });
  }

  Future<void> deleteNote({required int id}) async {
    await _runMutation(() async {
      final del = ref.read(deleteNoteUsecaseProvider);
      final notes = await del.execute(id: id);
      return notes;
    });
  }

  Future<void> togglePin({required int id}) async {
    await _runMutation(() async {
      final toggle = ref.read(togglePinUsecaseProvider);
      final notes = await toggle.execute(id: id);
      return notes;
    });
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String body,
    required String tag,
  }) async {
    await _runMutation(() async {
      final update = ref.read(updateNoteUsecaseProvider);

      final notes = await update.execute(
        id: id,
        title: title,
        body: body,
        tag: tag,
      );

      return notes;
    });
  }

  /// busy を state に反映し、UIが購読できるようにする。
  Future<void> _runMutation(Future<List<Note>> Function() action) async {
    if (_busy) return;
    _busy = true;

    final previous = state;

    // 現在の data が取れる場合、busy=true にして UI を disable できる
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(current.copyWith(busy: true));
    }

    try {
      final notes = await action();
      state = AsyncData(NoteListState(notes: notes, busy: false));
    } catch (e) {
      // 失敗時は元に戻す（busyも戻る）
      state = previous;
    } finally {
      _busy = false;
    }
  }
}
