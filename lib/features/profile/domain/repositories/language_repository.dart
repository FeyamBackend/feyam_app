abstract class LanguageRepository {
  /// Sends the user's chosen language ("es"/"en") to the backend so
  /// system-generated notifications can be localized. Callers should treat
  /// failures as non-fatal — the local choice already took effect.
  Future<void> syncLanguage(String languageCode);
}
