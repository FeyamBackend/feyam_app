import 'package:equatable/equatable.dart';
import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';

enum FinalPackageStatus { initial, loading, loaded, failure }

class FinalPackageState extends Equatable {
  const FinalPackageState({
    this.status = FinalPackageStatus.initial,
    this.package,
    this.failure,
  });

  final FinalPackageStatus status;

  /// The fetched final package once `status` is [FinalPackageStatus.loaded].
  /// `null` while loaded means "no final package exists yet for this order"
  /// — the normal case for most orders, until Venezuela warehouse staff have
  /// physically received its items — and is distinct from
  /// [FinalPackageStatus.failure], which is a real error.
  final FinalPackageEntity? package;
  final OrdersFailure? failure;

  FinalPackageState copyWith({
    FinalPackageStatus? status,
    FinalPackageEntity? package,
    OrdersFailure? failure,
  }) {
    return FinalPackageState(
      status: status ?? this.status,
      package: package ?? this.package,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, package, failure];
}
