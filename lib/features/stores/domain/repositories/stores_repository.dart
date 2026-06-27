import 'package:feyam/features/stores/domain/entities/store_entity.dart';

abstract class StoresRepository {
  Future<List<StoreEntity>> getStores(String? countryCode);
}
