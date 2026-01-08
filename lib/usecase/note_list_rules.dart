import 'package:tagged_notes/models/note.dart';

/// 一覧表示のルール（Pinned優先など）を集約
class NoteListRules {
  static List<Note> pinnedFirst(List<Note> notes) {
    final pinned = notes.where((n) => n.isPinned).toList();
    final others = notes.where((n) => !n.isPinned).toList();
    return [...pinned, ...others];
  }
}
