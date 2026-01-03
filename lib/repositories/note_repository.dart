import 'dart:convert';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/storage/key_value_store.dart';

class NoteRepository {
  static const _storageKey = 'notes';
  final KeyValueStore _store;

  NoteRepository(this._store);

  Future<void> save(List<Note> notes) async {
    final jsonList = notes.map((n) => jsonEncode(n.toMap())).toList();
    await _store.setStringList(_storageKey, jsonList);
  }

  Future<List<Note>> load() async {
    final jsonList = await _store.getStringList(_storageKey);
    if (jsonList == null || jsonList.isEmpty) return [];

    final result = <Note>[];

    for (final jsonStr in jsonList) {
      try {
        final decoded = jsonDecode(jsonStr);

        // 期待：Map<String, dynamic>
        if (decoded is! Map<String, dynamic>) {
          continue; // 型が違う要素はスキップ
        }

        result.add(Note.fromMap(decoded));
      } catch (_) {
        // JSON不正 / fromMap例外などは、その要素だけ捨てる
        continue;
      }
    }

    return result;
  }

}
