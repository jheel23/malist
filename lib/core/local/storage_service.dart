abstract class StorageService {
  Future<bool> setString(String key, String value);
  Future<String?> getString(String key);
  Future<bool> setInt(String key, int value);
  Future<int?> getInt(String key);
  Future<bool> setBool(String key, bool value); // Set a boolean value
  Future<bool?> getBool(String key);
  Future<bool> remove(String key);
  Future<bool> containsKey(String key);
  // Future<bool> setListMap(String key, List<Map<String, dynamic>> value);
  // Future<List<Map<String, dynamic>>?> getListMap(String key);
  Future<void> nuke();
}
