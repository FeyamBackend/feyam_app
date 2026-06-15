import 'package:equatable/equatable.dart';
import 'package:feyam/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:feyam/features/cart/domain/failures/cart_failure.dart';

enum AddToCartStatus { initial, loading, success, failure }

class AddToCartState extends Equatable {
  const AddToCartState({
    this.status = AddToCartStatus.initial,
    this.summary,
    this.failure,
  });

  final AddToCartStatus status;
  final CartSummaryEntity? summary;
  final CartFailure? failure;

  AddToCartState copyWith({
    AddToCartStatus? status,
    CartSummaryEntity? summary,
    CartFailure? failure,
  }) =>
      AddToCartState(
        status: status ?? this.status,
        summary: summary ?? this.summary,
        failure: failure ?? this.failure,
      );

  @override
  List<Object?> get props => [status, summary, failure];
}
