import 'package:feyam/features/stores/domain/entities/store_entity.dart';
import 'package:feyam/features/stores/domain/repositories/stores_repository.dart';

class GetStoresUseCase {
  const GetStoresUseCase(this.repository);

  final StoresRepository repository;

  Future<List<StoreEntity>> call(String? countryCode) =>
      repository.getStores(countryCode);
}
