import 'package:flutter/material.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/usecase/add_note_usecase.dart';
import 'package:tagged_notes/usecase/delete_note_usecase.dart';
import 'package:tagged_notes/usecase/load_note_usecase.dart';
import 'package:tagged_notes/usecase/toggle_pin_usecase.dart';
import 'package:tagged_notes/usecase/update_note_usecase.dart';

class NoteProvider with ChangeNotifier {
  final AddNoteUsecase _add;
  final DeleteNoteUsecase _delete;
  final TogglePinUsecase _toggle;
  final UpdateNoteUsecase _update;
  final LoadNoteUsecase _load;

  // 内部で持っている Note の一覧
  List<Note> _notes = [];

  // 初期化済みかどうかのフラグ（複数回 init() が呼ばれても安全にするため）
  bool _isInitialized = false;

  // NoteProvider({NoteRepository? repo}) : _repo = repo ?? NoteRepository();
  NoteProvider(NoteRepository repo)
    : _add = AddNoteUsecase(repo),
      _delete = DeleteNoteUsecase(repo),
      _toggle = TogglePinUsecase(repo),
      _update = UpdateNoteUsecase(repo),
      _load = LoadNoteUsecase(repo);

  List<Note> get notes => _notes;

  Note? findById(int id) {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  // 初期化メソッド
  Future<void> init() async {
    if (_isInitialized) return;
    await _reload();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _reload() async {
    _notes = await _load.execute();
  }

  // 追加
  Future<void> addNote(String title, String body, String tag) async {
    await _add.execute(title: title, body: body, tag: tag);
    await _reload();
    notifyListeners();
  }

  // 削除
  Future<void> deleteNote(int id) async {
    await _delete.execute(id: id);
    await _reload();
    notifyListeners();
  }

  // ピン切り替え
  Future<void> togglePin(int id) async {
    await _toggle.execute(id);
    await _reload();
    notifyListeners();
  }

  // ノートの更新（idで指定）
  Future<void> updateNote(int id, String title, String body, String tag) async {
    await _update.execute(id: id, title: title, body: body, tag: tag);
    await _reload();
    notifyListeners();
  }
}
