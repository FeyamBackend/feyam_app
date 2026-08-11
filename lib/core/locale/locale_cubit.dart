import 'package:feyam/core/locale/language_preference_store.dart';
import 'package:feyam/features/profile/domain/repositories/language_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Drives [MaterialApp]/[CupertinoApp]'s `locale` so switching the language
/// picker in Profile takes effect immediately, without an app restart.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({
    required LanguagePreferenceStore preferenceStore,
    required LanguageRepository languageRepository,
  }) : _preferenceStore = preferenceStore,
       _languageRepository = languageRepository,
       super(const Locale('en'));

  final LanguagePreferenceStore _preferenceStore;
  final LanguageRepository _languageRepository;

  /// Reads the persisted language, if any, and emits it. Must be awaited
  /// before `runApp` so the app never flashes the wrong language on launch.
  Future<void> loadPersisted() async {
    final languageCode = await _preferenceStore.getLanguage();
    if (languageCode != null) {
      emit(Locale(languageCode));
    }
  }

  /// Applies [languageCode] immediately, persists it locally, and syncs it
  /// to the backend best-effort — a failed sync doesn't block the local
  /// change; it's simply retried the next time the user picks a language.
  Future<void> changeLanguage(String languageCode) async {
    emit(Locale(languageCode));
    await _preferenceStore.setLanguage(languageCode);
    try {
      await _languageRepository.syncLanguage(languageCode);
    } catch (_) {
      // Best-effort sync; local preference already took effect.
    }
  }
}
