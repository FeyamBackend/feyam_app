import 'package:feyam/features/cart/data/models/cart_item_model.dart';
import 'package:feyam/features/cart/domain/entities/cart_entity.dart';

class CartModel extends CartEntity {
  const CartModel({
    required super.cartId,
    required super.total,
    required super.currencyCode,
    required super.itemCount,
    required super.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>;
    return CartModel(
      cartId: json['cartId'] as String,
      total: (json['total'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      itemCount: json['itemCount'] as int,
      items: rawItems
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
