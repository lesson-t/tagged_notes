import 'package:flutter/material.dart';
import 'package:tagged_notes/models/note.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NoteProvider with ChangeNotifier {
  static const _storageKey = 'notes';

  // 内部で持っている Note の一覧
  final List<Note> _notes = [];


  // 一覧取得（ピン付き→それ以外 の順で並び替え）
  List<Note> get notes {
    final pinned = _notes.where((n) => n.isPinned).toList();
    final others = _notes.where((n) => !n.isPinned).toList();
    return [...pinned, ...others];
  }

  NoteProvider() {
    loadNotes();
  }

  // 追加
  Future<void> addNote(String title, String body, String tag) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;
    _notes.add(
      Note(
        title: title,
        body: body, 
        tag: tag
      ),
    );
    await _saveNotes();
    notifyListeners();
  }

  // 現在の _notes を端末に保存
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _notes.map((note) => jsonEncode(note.toMap())).toList();

    await prefs.setStringList(_storageKey, jsonList);
  }

  // 端末に保存されている Note 一覧を読み込む
  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);

    if (jsonList == null) return;

    _notes.clear();
    _notes.addAll(
      jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Note.fromMap(map);
      }),
    );

    notifyListeners();
  }

  // 削除
  Future<void> deleteNote(int id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
    notifyListeners();
  }

  // ピン切り替え
  Future<void> togglePin(int id) async {
    final note = _notes.firstWhere(
      (n) => n.id == id,
      orElse: () => throw Exception('Note not found: id=$id')
    );
    note.togglePin();
    await _saveNotes();
    notifyListeners();
  }

  // ノートの更新（idで指定）
  Future<void> updateNote(int id, String title, String body, String tag) async {
    final note = _notes.firstWhere(
      (n) => n.id == id, 
      orElse: () => throw Exception("Note not found: id=$id")
    );
    
    note.update(title: title, body: body, tag: tag);

    await _saveNotes();
    notifyListeners();
  }
}