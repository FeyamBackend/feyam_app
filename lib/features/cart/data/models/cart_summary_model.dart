import 'package:feyam/features/cart/domain/entities/cart_summary_entity.dart';

class CartSummaryModel extends CartSummaryEntity {
  const CartSummaryModel({
    required super.cartId,
    required super.total,
    required super.itemCount,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      cartId: json['cartId'] as String,
      total: (json['total'] as num).toDouble(),
      itemCount: json['itemCount'] as int,
    );
  }
}
