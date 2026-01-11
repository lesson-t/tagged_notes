import 'package:tagged_notes/storage/key_value_store.dart';

class InMemoryStore implements KeyValueStore {
  final Map<String, Object?> _map = {};

  @override
  Future<List<String>?> getStringList(String key) async {
    final v = _map[key];
    return  v is  List<String> ? List<String>.from(v) : null;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _map[key] = List<String>.from(value);
  }
}
