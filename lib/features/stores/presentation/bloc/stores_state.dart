import 'package:equatable/equatable.dart';
import 'package:feyam/features/stores/domain/entities/store_entity.dart';

enum StoresStatus { initial, loading, loaded, failure }

class StoresState extends Equatable {
  const StoresState({
    this.status = StoresStatus.initial,
    this.stores = const [],
  });

  final StoresStatus status;
  final List<StoreEntity> stores;

  StoresState copyWith({
    StoresStatus? status,
    List<StoreEntity>? stores,
  }) {
    return StoresState(
      status: status ?? this.status,
      stores: stores ?? this.stores,
    );
  }

  @override
  List<Object> get props => [status, stores];
}
