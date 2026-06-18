import 'package:feyam/features/cart/domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.itemId,
    required super.productName,
    required super.productUrl,
    super.productImageUrl,
    super.variantAttributes,
    required super.quantity,
    required super.unitPriceAmount,
    required super.currencyCode,
    super.notes,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variantAttributes'] as Map<String, dynamic>?;
    return CartItemModel(
      itemId: json['itemId'] as String,
      productName: json['productName'] as String,
      productUrl: json['productUrl'] as String,
      productImageUrl: json['productImageUrl'] as String?,
      variantAttributes: rawVariants?.map((k, v) => MapEntry(k, v as String)),
      quantity: json['quantity'] as int,
      unitPriceAmount: (json['unitPriceAmount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      notes: json['notes'] as String?,
    );
  }
}
