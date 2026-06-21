import 'package:feyam/features/profile/domain/entities/address_entity.dart';
import 'package:feyam/features/profile/domain/entities/address_params.dart';
import 'package:feyam/features/profile/domain/repositories/address_repository.dart';

class UpdateAddressUseCase {
  const UpdateAddressUseCase(this.repository);

  final AddressRepository repository;

  Future<AddressEntity> call(String id, AddressParams params) =>
      repository.updateAddress(id, params);
}
