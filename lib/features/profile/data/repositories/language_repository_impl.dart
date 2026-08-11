import 'package:feyam/features/profile/data/datasources/language_remote_datasource.dart';
import 'package:feyam/features/profile/domain/repositories/language_repository.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  LanguageRepositoryImpl({required LanguageRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final LanguageRemoteDataSource _remoteDataSource;

  @override
  Future<void> syncLanguage(String languageCode) {
    return _remoteDataSource.updateLanguage(languageCode);
  }
}
