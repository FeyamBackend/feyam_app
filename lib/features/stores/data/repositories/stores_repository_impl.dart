import 'package:feyam/features/stores/data/datasources/stores_remote_datasource.dart';
import 'package:feyam/features/stores/domain/entities/store_entity.dart';
import 'package:feyam/features/stores/domain/repositories/stores_repository.dart';

class StoresRepositoryImpl implements StoresRepository {
  const StoresRepositoryImpl({required this.remoteDataSource});

  final StoresRemoteDataSource remoteDataSource;

  @override
  Future<List<StoreEntity>> getStores(String? countryCode) =>
      remoteDataSource.getStores(countryCode);
}
