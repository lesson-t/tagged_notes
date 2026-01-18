import 'package:tagged_notes/models/note.dart';

class NoteListState {
  final List<Note> notes;
  final bool busy;

  const NoteListState({
    required this.notes,
    required this.busy,
  });

  NoteListState copyWith({
    List<Note>? notes,
    bool? busy,
  }) {
    return NoteListState(
      notes: notes ?? this.notes, 
      busy: busy ?? this.busy,
    );
  }
}