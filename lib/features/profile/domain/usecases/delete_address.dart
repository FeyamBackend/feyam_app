import 'package:feyam/features/profile/domain/repositories/address_repository.dart';

class DeleteAddressUseCase {
  const DeleteAddressUseCase(this.repository);

  final AddressRepository repository;

  Future<void> call(String id) => repository.deleteAddress(id);
}
