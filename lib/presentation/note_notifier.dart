import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagged_notes/di/providers.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/presentation/note_list_state.dart';

/// UI からはこの provider だけを見る（Repository/UseCase を直接触らない）
final noteListProvider = AsyncNotifierProvider<NoteListNotifier, NoteListState>(
  NoteListNotifier.new,
);

class NoteListNotifier extends AsyncNotifier<NoteListState> {
  // bool _busy = false;
  bool get _isBusy => state.asData?.value.busy ?? false;

  @override
  Future<NoteListState> build() async {
    final load = ref.read(loadNoteUsecaseProvider);
    final notes = await load.execute();
    return NoteListState(notes: notes, busy: false);
  }

  Future<void> refresh() async {
    await _runMutation(() async {
      final load = ref.read(loadNoteUsecaseProvider);
      return await load.execute();
    });
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
    if (_isBusy) return;

    final previous = state;
    final current = previous.asData?.value;

    // data があるなら busy=true で UI を止める（表示は保持）
    if (current != null) {
      state = AsyncData(current.copyWith(busy: true));
    }

    try {
      final notes = await action();
      state = AsyncData(NoteListState(notes: notes, busy: false));
    } catch (_) {
      // 失敗時は元に戻す（busy解除は finally が最終責務）
      state = previous;
    } finally {
      // data のときだけ busy を必ず解除する
      final v = state.asData?.value;
      if (v != null && v.busy) {
        state = AsyncData(v.copyWith(busy: false));
      }
    }
  }
}
