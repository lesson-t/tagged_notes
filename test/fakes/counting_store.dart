import 'package:tagged_notes/storage/key_value_store.dart';

class CountingStore implements KeyValueStore {
  int setCalls = 0;
  final Map<String, List<String>> _data = {};

  @override
  Future<List<String>?> getStringList(String key) async => _data[key];

  @override
  Future<void> setStringList(String key, List<String> value) async {
    setCalls++;
    _data[key] = List<String>.from(value);
  }
}
