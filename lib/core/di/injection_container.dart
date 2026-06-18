import 'dart:io';

import 'package:feyam/core/config/app_config.dart';
import 'package:feyam/core/config/app_flavor.dart';
import 'package:feyam/features/auth/data/datasources/keycloak_auth_datasource.dart';
import 'package:feyam/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';
import 'package:feyam/features/auth/domain/usecases/check_auth_session.dart';
import 'package:feyam/features/auth/domain/usecases/login.dart';
import 'package:feyam/features/auth/domain/usecases/logout.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:feyam/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:feyam/features/cart/domain/usecases/add_to_cart.dart';
import 'package:feyam/features/cart/domain/usecases/get_cart.dart';
import 'package:feyam/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:feyam/features/cart/domain/usecases/update_cart_item_quantity.dart';
import 'package:feyam/features/cart/presentation/bloc/add_to_cart_bloc.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

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
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(keycloakDataSource: sl<KeycloakDataSource>()),
  );

  // Use cases
  sl.registerFactory<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<CheckAuthSessionUseCase>(
    () => CheckAuthSessionUseCase(sl<AuthRepository>()),
  );

  // Blocs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      checkAuthSessionUseCase: sl<CheckAuthSessionUseCase>(),
    ),
  );

  /**
   * Cart Module
   */

  sl.registerLazySingleton<http.Client>(() {
    final flavor = sl<AppConfig>().flavor;
    if (flavor == AppFlavor.prod.name) return http.Client();
    // Dev/staging: bypass self-signed certificate validation
    final inner = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    return IOClient(inner);
  });

  sl.registerLazySingleton(
    () => CartRemoteDataSource(
      client: sl<http.Client>(),
      secureStorage: sl<FlutterSecureStorage>(),
      apiBaseUrl: sl<AppConfig>().apiBaseUrl,
    ),
  );

  sl.registerFactory<CartRepositoryImpl>(
    () => CartRepositoryImpl(
      remoteDataSource: sl<CartRemoteDataSource>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  sl.registerFactory<AddToCartUseCase>(
    () => AddToCartUseCase(sl<CartRepositoryImpl>()),
  );

  sl.registerFactory<AddToCartBloc>(
    () => AddToCartBloc(addToCartUseCase: sl<AddToCartUseCase>()),
  );

  sl.registerFactory<GetCartUseCase>(
    () => GetCartUseCase(sl<CartRepositoryImpl>()),
  );

  sl.registerFactory<RemoveCartItemUseCase>(
    () => RemoveCartItemUseCase(sl<CartRepositoryImpl>()),
  );

  sl.registerFactory<UpdateCartItemQuantityUseCase>(
    () => UpdateCartItemQuantityUseCase(sl<CartRepositoryImpl>()),
  );

  sl.registerFactory<CartBloc>(
    () => CartBloc(
      getCartUseCase: sl<GetCartUseCase>(),
      removeCartItemUseCase: sl<RemoveCartItemUseCase>(),
      updateCartItemQuantityUseCase: sl<UpdateCartItemQuantityUseCase>(),
    ),
  );
}
