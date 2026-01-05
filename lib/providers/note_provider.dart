import 'package:flutter/material.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/add_note_usecase.dart';

class NoteProvider with ChangeNotifier {
  final AddNoteUsecase _add;
  final NoteRepository _repo;

  // 内部で持っている Note の一覧
  List<Note> _notes = [];

  // 初期化済みかどうかのフラグ（複数回 init() が呼ばれても安全にするため）
  bool _isInitialized = false;

  // NoteProvider({NoteRepository? repo}) : _repo = repo ?? NoteRepository();
  NoteProvider(this._repo)
    : _add = AddNoteUsecase(_repo);

  // 一覧取得（ピン付き→それ以外 の順で並び替え）
  // List<Note> get notes {
  //   final pinned = _notes.where((n) => n.isPinned).toList();
  //   final others = _notes.where((n) => !n.isPinned).toList();
  //   return [...pinned, ...others];
  // }

  List<Note> get notes => _notes;

  Note? findById(int id) {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  // 初期化メソッド
  // Future<void> init() async {
  //   if (_isInitialized) return;
  //   // await loadNotes();
  //   // _isInitialized = true;

  //   final loaded = await _repo.load();
  //   _notes
  //     ..clear()
  //     ..addAll(loaded);

  //   _isInitialized = true;
  //   notifyListeners();
  // }
  Future<void> init() async {
    if (_isInitialized) return;
    _notes = await _repo.load();
    _isInitialized = true;
    notifyListeners();
  }

  // 追加
  // Future<void> addNote(String title, String body, String tag) async {
  //   final trimmedTitle = title.trim();
  //   if (trimmedTitle.isEmpty) return;
  //   _notes.add(Note(title: trimmedTitle, body: body, tag: tag));
  //   await _repo.save(_notes);
  //   notifyListeners();
  // }
  Future<void> addNote(String title, String body, String tag) async {
    await _add.execute(title: title, body: body, tag: tag);
    _notes = await _repo.load();
    notifyListeners();
  }

  // 削除
  Future<void> deleteNote(int id) async {
    final before = _notes.length;

    _notes.removeWhere((n) => n.id == id);
    if (_notes.length == before) return;

    await _repo.save(_notes);
    notifyListeners();
  }

  // ピン切り替え
  Future<void> togglePin(int id) async {
    final note = findById(id);
    if (note == null) return; // 存在しなければ何もしない

    note.togglePin();
    await _repo.save(_notes);
    notifyListeners();
  }

  // ノートの更新（idで指定）
  Future<void> updateNote(int id, String title, String body, String tag) async {
    final note = findById(id);
    if (note == null) return;

    note.update(title: title, body: body, tag: tag);
    await _repo.save(_notes);
    notifyListeners();
  }
}
