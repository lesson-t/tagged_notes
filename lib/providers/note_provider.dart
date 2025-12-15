import 'package:flutter/material.dart';
import 'package:tagged_notes/models/note.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NoteProvider with ChangeNotifier {
  static const _storageKey = 'notes';

  // 内部で持っている Note の一覧
  final List<Note> _notes = [];

  // 初期化済みかどうかのフラグ（複数回 init() が呼ばれても安全にするため） 
  bool _isInitialized = false;

  // コンストラクタでは何もしない（非同期を呼ばない） 
  NoteProvider();


  // 一覧取得（ピン付き→それ以外 の順で並び替え）
  List<Note> get notes {
    final pinned = _notes.where((n) => n.isPinned).toList();
    final others = _notes.where((n) => !n.isPinned).toList();
    return [...pinned, ...others];
  }

  // 初期化メソッド
  Future<void> init() async {
    if (_isInitialized) return;
    await loadNotes();
    _isInitialized = true;
  }

  // 端末に保存されている Note 一覧を読み込む
  Future<void> loadNotes() async {
    final perfs = await SharedPreferences.getInstance();
    final jsonList = perfs.getStringList(_storageKey);

    if (jsonList == null) {
      // 初回起動などで何も保存されていない場合
      notifyListeners(); // 一応呼んでおいてもよいが、省略も可
      return;
    }

    _notes.clear();
    _notes.addAll(
      jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Note.fromMap(map);
      }),
    );

    notifyListeners();
  }

  // 追加
  Future<void> addNote(String title, String body, String tag) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;
    _notes.add(
      Note(
        title: trimmedTitle,
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

  Note? findById(int id) {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }
}