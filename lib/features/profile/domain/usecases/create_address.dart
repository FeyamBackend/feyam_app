import 'package:feyam/features/profile/domain/entities/address_entity.dart';
import 'package:feyam/features/profile/domain/entities/address_params.dart';
import 'package:feyam/features/profile/domain/repositories/address_repository.dart';

class CreateAddressUseCase {
  const CreateAddressUseCase(this.repository);

  final AddressRepository repository;

  Future<AddressEntity> call(AddressParams params) =>
      repository.createAddress(params);
}
