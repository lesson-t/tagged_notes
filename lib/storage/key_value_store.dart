abstract class KeyValueStore {
  Future<List<String?>> getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
}