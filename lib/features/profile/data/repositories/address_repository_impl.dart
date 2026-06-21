import 'dart:io';

import 'package:feyam/features/profile/data/datasources/address_remote_datasource.dart';
import 'package:feyam/features/profile/data/models/address_request_model.dart';
import 'package:feyam/features/profile/domain/entities/address_entity.dart';
import 'package:feyam/features/profile/domain/entities/address_params.dart';
import 'package:feyam/features/profile/domain/entities/country_entity.dart';
import 'package:feyam/features/profile/domain/failures/address_failure.dart';
import 'package:feyam/features/profile/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl({required AddressRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AddressRemoteDataSource _remoteDataSource;

  @override
  Future<List<AddressEntity>> getAddresses() {
    return _guard(() => _remoteDataSource.list());
  }

  @override
  Future<List<CountryEntity>> getCountries(String languageCode) {
    return _guard(() => _remoteDataSource.listCountries(languageCode));
  }

  @override
  Future<AddressEntity> createAddress(AddressParams params) {
    final request = AddressRequestModel.fromParams(params);
    return _guard(() => _remoteDataSource.create(request));
  }

  @override
  Future<AddressEntity> updateAddress(String id, AddressParams params) {
    final request = AddressRequestModel.fromParams(params);
    return _guard(() => _remoteDataSource.update(id, request));
  }

  @override
  Future<void> deleteAddress(String id) {
    return _guard(() => _remoteDataSource.delete(id));
  }

  /// Ejecuta [action] mapeando las excepciones del datasource a [AddressFailure].
  /// El refresh y el retry de 401 los maneja AuthenticatedHttpClient; un 401 que
  /// llegue acá significa que la sesión expiró (el logout global lo dispara el
  /// cliente vía SessionExpiredNotifier).
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AddressUnauthorizedException {
      throw const AddressFailure(AddressFailureCode.sessionExpired);
    } on AddressNotFoundException {
      throw const AddressFailure(AddressFailureCode.notFound);
    } on AddressServerException {
      throw const AddressFailure(AddressFailureCode.serverError);
    } on SocketException {
      throw const AddressFailure(AddressFailureCode.networkError);
    } catch (_) {
      throw const AddressFailure(AddressFailureCode.unknown);
    }
  }
}
