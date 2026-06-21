import 'package:feyam/features/profile/domain/entities/address_entity.dart';
import 'package:feyam/features/profile/domain/entities/address_params.dart';
import 'package:feyam/features/profile/domain/entities/country_entity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> getAddresses();

  /// Países disponibles para direcciones, con nombres localizados según [languageCode].
  Future<List<CountryEntity>> getCountries(String languageCode);
  Future<AddressEntity> createAddress(AddressParams params);
  Future<AddressEntity> updateAddress(String id, AddressParams params);
  Future<void> deleteAddress(String id);
}
