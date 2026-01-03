import 'dart:convert';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/storage/key_value_store.dart';

class NoteRepository {
  static const _storageKey = 'notes';

  // 現在のスキーマバージョン
  static const int currentSchemaVersion = 1;

  final KeyValueStore _store;
  NoteRepository(this._store);

  Future<void> save(List<Note> notes) async {
    final jsonList = notes.map((n) {

      final map = n.toMap();

      // 保存時に schemaVersion を付与
      final withVersion = <String, dynamic> {
        'schemaVersion': currentSchemaVersion,
        ...map,
      };

      return jsonEncode(withVersion);
    }).toList();

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

        final migrated = _migrateToCurrent(decoded);
        if (migrated == null) continue; //未対応/不正はスキップ

        result.add(Note.fromMap(decoded));
      } catch (_) {
        // JSON不正 / migration失敗  / fromMap例外などは、その要素だけ捨てる
        continue;
      }
    }

    return result;
  }

  /// Mapを currentSchemaVersion まで段階的に引き上げる
  /// - 返り値null: 復元不能としてスキップ
  Map<String, dynamic>? _migrateToCurrent(Map<String, dynamic> raw) {
    // versionが無い過去データは v0 とみなす
    var version = (raw['schemaVersion'] is int) ? raw['schemaVersion'] as int : 0;

    // 未来のversionはアプリ側が未対応なのでスキップ（安全側）
    if (version > currentSchemaVersion) return null;

    var map = Map<String, dynamic>.from(raw);

    // v0 -> v1
    if (version == 0) {
      map = _migrateV0toV1(map);
      version = 1;
    }

    // ここに v1->v2, v2->v3... を追加していく
    // if (version == 1) { map = _migrateV1toV2(map); version = 2; }

    // 念のため、最終的に version をそろえる
    map['schemaVersion'] = currentSchemaVersion;
    return map;
  }

  /// v0(バージョン無し)のデータを v1 に整形
  /// - v0は isPinned/createdAt が無い可能性があるのでデフォルト補完
  Map<String, dynamic> _migrateV0toV1(Map<String, dynamic> v0) {
    final v1 = Map<String, dynamic>.from(v0);

    // schemaVersion 付与
    v1['schemaVersion'] = 1;

    // isPinned が無い場合は false
    v1.putIfAbsent('isPinned', () => false);

    // createdAt が無い場合は「今」を入れる
    v1.putIfAbsent('createdAt', () => DateTime.now().toIso8601String());

    return v1;
  }
}
