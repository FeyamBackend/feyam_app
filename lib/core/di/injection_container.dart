import 'package:feyam/core/config/app_config.dart';
import 'package:feyam/core/config/app_flavor.dart';
import 'package:feyam/features/auth/data/datasources/keycloak_auth_datasource.dart';
import 'package:feyam/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:feyam/features/auth/domain/usecases/check_auth_session.dart';
import 'package:feyam/features/auth/domain/usecases/login.dart';
import 'package:feyam/features/auth/domain/usecases/logout.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final GetIt sl = GetIt.instance;

void configureDependencies({AppConfig? appConfig}) {
  if (sl.isRegistered<AppConfig>()) {
    return;
  }

  sl.registerLazySingleton<AppConfig>(
    () => appConfig ?? AppConfig.fromFlavor(AppFlavor.dev),
  );

  /**
 * Auth Module
 */

  // External dependencies
  sl.registerSingleton<FlutterAppAuth>(FlutterAppAuth());
  sl.registerSingleton<FlutterSecureStorage>(FlutterSecureStorage());

  // Data sources
  sl.registerLazySingleton(
    () => KeycloakDataSource(
      appAuth: sl<FlutterAppAuth>(),
      secureStorage: sl<FlutterSecureStorage>(),
      baseUrl: sl<AppConfig>().keycloakBaseUrl,
      realm: sl<AppConfig>().keycloakRealm,
      clientId: sl<AppConfig>().keycloakClientId,
      redirectUri: sl<AppConfig>().keycloakRedirectUri,
    ),
  );

  // Repositories
  sl.registerFactory<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(keycloakDataSource: sl<KeycloakDataSource>()),
  );

  // Use cases
  sl.registerFactory<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepositoryImpl>()),
  );

  sl.registerFactory<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepositoryImpl>()),
  );

  sl.registerFactory<CheckAuthSessionUseCase>(
    () => CheckAuthSessionUseCase(sl<AuthRepositoryImpl>()),
  );

  // Blocs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      checkAuthSessionUseCase: sl<CheckAuthSessionUseCase>(),
    ),
  );
}
