import 'package:feyam/features/profile/domain/repositories/address_repository.dart';

/// Returns the ISO 3166-1 alpha-2 country code from the user's first address,
/// or null if the user has no saved addresses.
class GetUserCountryCodeUseCase {
  const GetUserCountryCodeUseCase(this.repository);

  final AddressRepository repository;

  Future<String?> call() async {
    final addresses = await repository.getAddresses();
    return addresses.isNotEmpty ? addresses.first.countryCode : null;
  }
}
