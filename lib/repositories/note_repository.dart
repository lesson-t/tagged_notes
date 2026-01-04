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
      final withVersion = <String, dynamic>{
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
    var needsResave = false;

    for (final jsonStr in jsonList) {
      try {
        final decoded = jsonDecode(jsonStr);
        // 期待：Map<String, dynamic> 型が違う要素はスキップ
        if (decoded is! Map<String, dynamic>) continue;

        final migrated = _migrateToCurrent(decoded);
        if (migrated == null) continue; //未対応/不正はスキップ

        // // migrateが入った（= v0など）なら再保存対象
        // final rawVersion = (decoded['schemaVersion'] is int) ? decoded['schemaVersion'] as int : 0;
        // if (rawVersion != currentSchemaVersion) {
        //   needsResave = true;
        // }

        // ★「本当に正規化が起きたか」を didMigrate で判定
        if (migrated.didMigrate) {
          needsResave = true;
        }

        result.add(Note.fromMap(migrated.map));
      } catch (_) {
        // JSON不正 / migration失敗  / fromMap例外などは、その要素だけ捨てる
        continue;
      }
    }

    // Self-healing: 読めた分を正規化して保存し直す
    if (needsResave) {
      try {
        await save(result);
      } catch (_) {
        // 保存失敗でも load 自体は成功扱いで返す（クラッシュ回避）
      }
    }

    return result;
  }

  /// Mapを currentSchemaVersion まで段階的に引き上げる
  /// - 返り値null: 復元不能としてスキップ
  /// - didMigrate: version引上げ/欠損補完/正規化 が起きたら true
  ({Map<String, dynamic> map, bool didMigrate})? _migrateToCurrent(
    Map<String, dynamic> raw,
  ) {
    var didMigrate = false;

    // versionが無い過去データは v0 とみなす
    final rawVersion = (raw['schemaVersion'] is int)
        ? raw['schemaVersion'] as int
        : 0;

    // 未来のversionはアプリ側が未対応なのでスキップ（安全側）
    if (rawVersion > currentSchemaVersion) return null;

    var map = Map<String, dynamic>.from(raw);
    var version = rawVersion;

    // v0 -> v1
    if (version == 0) {
      final migratedV1 = _migrateV0toV1(map);
      map = migratedV1.map;
      if (migratedV1.didMigrate) didMigrate = true;
      version = 1;
    }

    // ★ v1なのに欠損してるケース（schemaVersion同じでも補完したい）
    // 例：過去のバグ・手動改変・古い保存形式など
    if (version == 1) {
      final normalized = _normalizeV1(map);
      map = normalized.map;
      if (normalized.didMigrate) didMigrate = true;
    }

    // ここに v1->v2, v2->v3... を追加していく
    // if (version == 1) { map = _migrateV1toV2(map); version = 2; }

    // 最終的に schemaVersion を current に揃える
    if (map['schemaVersion'] != currentSchemaVersion) {
      didMigrate = true;
      map['schemaVersion'] = currentSchemaVersion;
    }

    return (map: map, didMigrate: didMigrate);
  }

  /// v0(バージョン無し)のデータを v1 に整形
  /// - v0は isPinned/createdAt が無い可能性があるのでデフォルト補完
  ({Map<String, dynamic> map, bool didMigrate}) _migrateV0toV1(
    Map<String, dynamic> v0,
  ) {
    var didMigrate = false;
    final v1 = Map<String, dynamic>.from(v0);

    // schemaVersion 付与
    if (v1['schemaVersion'] != 1) {
      didMigrate = true;
      v1['schemaVersion'] = 1;
    }

    // isPinned が無い場合は false
    if (!v1.containsKey('isPinned')) {
      didMigrate = true;
      v1['isPinned'] = false;
    }

    // createdAt が無い場合は「今」を入れる
    if (!v1.containsKey('createdAt')) {
      didMigrate = true;
      v1['createdAt'] = DateTime.now().toIso8601String();
    }

    return (map: v1, didMigrate: didMigrate);
  }

  /// v1データの「欠損補完・型正規化」用（schemaVersionが同じでも治す）
  /// 将来：createdAtがintだった/空文字だった等の補正を足せる
  ({Map<String, dynamic> map, bool didMigrate}) _normalizeV1(
    Map<String, dynamic> v1,
  ) {
    var didMigrate = false;
    final normalized = Map<String, dynamic>.from(v1);

    if (!normalized.containsKey('isPinned')) {
      didMigrate = true;
      normalized['isPinned'] = false;
    }

    if (!normalized.containsKey('createdAt')) {
      didMigrate = true;
      normalized['createdAt'] = DateTime.now().toIso8601String();
    } else {
      //
      final ca = normalized['createdAt'];
      if (ca is! String || ca.isEmpty) {
        didMigrate = true;
        normalized['createdAt'] = DateTime.now().toIso8601String();
      }
    }

    return (map: normalized, didMigrate: didMigrate);
  }
}
