import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/storage/key_value_store.dart';

class NoteRepository {
  static const _storageKey = 'notes';
  final KeyValueStore _store;

  NoteRepository(this._store);

  Future<List<Note>> load() async {
    // final perfs = await SharedPreferences.getInstance();
    final jsonList = await _store.getStringList(_storageKey);
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Note.fromMap(map);
    }).toList();
  }

  Future<void> save(List<Note> notes) async {
    // final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((n) => jsonEncode(n.toMap())).toList();
    await _store.setStringList(_storageKey, jsonList);
  }
}
