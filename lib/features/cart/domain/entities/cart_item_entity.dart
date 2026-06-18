import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  const CartItemEntity({
    required this.itemId,
    required this.productName,
    required this.productUrl,
    this.productImageUrl,
    this.variantAttributes,
    required this.quantity,
    required this.unitPriceAmount,
    required this.currencyCode,
    this.notes,
  });

  final String itemId;
  final String productName;
  final String productUrl;
  final String? productImageUrl;
  final Map<String, String>? variantAttributes;
  final int quantity;
  final double unitPriceAmount;
  final String currencyCode;
  final String? notes;

  double get totalPrice => unitPriceAmount * quantity;

  @override
  List<Object?> get props => [
        itemId,
        productName,
        productUrl,
        productImageUrl,
        variantAttributes,
        quantity,
        unitPriceAmount,
        currencyCode,
        notes,
      ];
}
