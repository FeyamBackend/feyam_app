import 'package:equatable/equatable.dart';
import 'package:feyam/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:feyam/features/cart/domain/repositories/cart_repository.dart';

class AddToCartParams extends Equatable {
  const AddToCartParams({
    required this.productName,
    required this.productUrl,
    required this.quantity,
    required this.unitPriceAmount,
    required this.currencyCode,
    this.productImageUrl,
    this.notes,
    this.variantAttributes,
  });

  final String productName;
  final String productUrl;
  final int quantity;
  final double unitPriceAmount;
  final String currencyCode;
  final String? productImageUrl;
  final String? notes;
  final Map<String, String>? variantAttributes;

  @override
  List<Object?> get props => [
        productName,
        productUrl,
        quantity,
        unitPriceAmount,
        currencyCode,
        productImageUrl,
        notes,
        variantAttributes,
      ];
}

class AddToCartUseCase {
  const AddToCartUseCase(this.repository);

  final CartRepository repository;

  Future<CartSummaryEntity> call(AddToCartParams params) =>
      repository.addToCart(params);
}
