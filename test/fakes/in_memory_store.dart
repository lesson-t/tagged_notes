import 'package:tagged_notes/storage/key_value_store.dart';

class InMemoryStore implements KeyValueStore {
  final Map<String, List<String>> _data = {};

  @override
  Future<List<String>?> getStringList(String key) async {
    final v = _data[key];
    if (v == null) return null;
    return List<String>.from(v);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _data[key] = List<String>.from(value);
  }
}