import 'package:equatable/equatable.dart';

sealed class FinalPackageEvent extends Equatable {
  const FinalPackageEvent();

  @override
  List<Object?> get props => [];
}

final class FinalPackageRequested extends FinalPackageEvent {
  const FinalPackageRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
