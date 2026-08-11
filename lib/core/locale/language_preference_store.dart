import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguagePreferenceStore {
  static const String _languageKey = 'preferred_language';

  final FlutterSecureStorage _secureStorage;

  LanguagePreferenceStore({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  Future<String?> getLanguage() {
    return _secureStorage.read(key: _languageKey);
  }

  Future<void> setLanguage(String languageCode) {
    return _secureStorage.write(key: _languageKey, value: languageCode);
  }
}
