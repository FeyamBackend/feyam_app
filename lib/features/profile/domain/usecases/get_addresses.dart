import 'package:feyam/features/profile/domain/entities/address_entity.dart';
import 'package:feyam/features/profile/domain/repositories/address_repository.dart';

class GetAddressesUseCase {
  const GetAddressesUseCase(this.repository);

  final AddressRepository repository;

  Future<List<AddressEntity>> call() => repository.getAddresses();
}
