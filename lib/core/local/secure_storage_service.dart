import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_service.dart';

class SecureStorageService implements StorageService {
  final FlutterSecureStorage _secureStorage;

  SecureStorageService(this._secureStorage);

  @override
  Future<bool> setString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
    return true;
  }

  @override
  Future<String?> getString(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    await _secureStorage.write(key: key, value: value.toString());
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = await _secureStorage.read(key: key);
    return value != null ? int.tryParse(value) : null;
  }

  @override
  Future<bool> remove(String key) async {
    await _secureStorage.delete(key: key);
    return true;
  }

  @override
  Future<bool> containsKey(String key) async {
    final value = await _secureStorage.read(key: key);
    return value != null;
  }

  @override
  Future<bool> setBool(String key, bool value1) async {
    await _secureStorage.write(key: key, value: value1.toString());
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    String? value = await _secureStorage.read(key: key);
    if (value != null) {
      return value.toLowerCase() ==
          'true'; // Converts the stored string back to a boolean
    }
    return null;
  }

  /// Save a List<Map<String, dynamic>> securely
  // @override
  // Future<void> setListMap(String key, List<Map<String, dynamic>> value) async {
  //   try {
  //     final jsonString = jsonEncode(value);
  //     await _secureStorage.write(key: key, value: jsonString);
  //   } catch (e) {
  //     print('Failed to save list to secure storage');
  //   }
  // }

  /// Read a List<Map<String, dynamic>> from secure storage
  // @override
  // Future<List<Map<String, dynamic>>> getListMap(String key) async {
  //   try {
  //     final jsonString = await _secureStorage.read(key: key);
  //     if (jsonString == null || jsonString.isEmpty) {
  //       return [];
  //     }
  //     final decoded = jsonDecode(jsonString);
  //     if (decoded is! List) {
  //       return [];
  //     }
  //     return decoded
  //         .whereType<Map>()
  //         .map((e) => Map<String, dynamic>.from(e))
  //         .toList();
  //   } catch (e) {
  //     return [];
  //   }
  // }

  @override
  Future<void> nuke() async {
    await _secureStorage.deleteAll();
  }
}
