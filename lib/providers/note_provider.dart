import 'package:flutter/material.dart';
import 'package:tagged_notes/models/note.dart';

class NoteProvider with ChangeNotifier {
  // 内部で持っている Note の一覧
  final List<Note> _notes = [];


  // 一覧取得（ピン付き→それ以外 の順で並び替え）
  List<Note> get notes {
    final pinned = _notes.where((n) => n.isPinned).toList();
    final others = _notes.where((n) => !n.isPinned).toList();
    return [...pinned, ...others];
  }

  // 追加
  void addNote(String title, String body, String tag) {
    _notes.add(
      Note(
        title: title,
        body: body, 
        tag: tag
      ),
    );
    notifyListeners();
  }

  // 削除
  void deleteNote(int id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // ピン切り替え
  void togglePin(int id) {
    final note = _notes.firstWhere(
      (n) => n.id == id,
      orElse: () => throw Exception('Note not found: id=$id')
    );
    note.togglePin();
    notifyListeners();
  }
}