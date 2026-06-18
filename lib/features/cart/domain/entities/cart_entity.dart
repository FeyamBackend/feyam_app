import 'package:equatable/equatable.dart';
import 'package:feyam/features/cart/domain/entities/cart_item_entity.dart';

class CartEntity extends Equatable {
  const CartEntity({
    required this.cartId,
    required this.total,
    required this.currencyCode,
    required this.itemCount,
    required this.items,
  });

  final String cartId;
  final double total;
  final String currencyCode;
  final int itemCount;
  final List<CartItemEntity> items;

  @override
  List<Object> get props => [cartId, total, currencyCode, itemCount, items];
}
