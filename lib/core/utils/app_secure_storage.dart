import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Web-safe wrapper around [FlutterSecureStorage].
///
/// On web, FlutterSecureStorage is not supported — values are stored in
/// memory only (session-scoped). Acceptable for UI testing phase.
class AppSecureStorage {
  static const _storage = FlutterSecureStorage();
  static final Map<String, String> _webMemory = {};

  static Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      _webMemory[key] = value;
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  static Future<String?> read({required String key}) async {
    if (kIsWeb) {
      return _webMemory[key];
    }
    return _storage.read(key: key);
  }

  static Future<void> delete({required String key}) async {
    if (kIsWeb) {
      _webMemory.remove(key);
    } else {
      await _storage.delete(key: key);
    }
  }
}
