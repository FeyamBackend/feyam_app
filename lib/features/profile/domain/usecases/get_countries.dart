import 'package:feyam/features/profile/domain/entities/country_entity.dart';
import 'package:feyam/features/profile/domain/repositories/address_repository.dart';

class GetCountriesUseCase {
  const GetCountriesUseCase(this.repository);

  final AddressRepository repository;

  Future<List<CountryEntity>> call(String languageCode) =>
      repository.getCountries(languageCode);
}
