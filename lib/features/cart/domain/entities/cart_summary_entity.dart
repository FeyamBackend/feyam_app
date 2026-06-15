import 'package:equatable/equatable.dart';

class CartSummaryEntity extends Equatable {
  const CartSummaryEntity({
    required this.cartId,
    required this.total,
    required this.itemCount,
  });

  final String cartId;
  final double total;
  final int itemCount;

  @override
  List<Object> get props => [cartId, total, itemCount];
}
