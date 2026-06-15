import 'package:equatable/equatable.dart';

abstract class AddToCartEvent extends Equatable {
  const AddToCartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCartSubmitted extends AddToCartEvent {
  const AddToCartSubmitted({
    required this.productName,
    required this.productUrl,
    required this.quantity,
    required this.unitPriceAmount,
    this.notes,
  });

  final String productName;
  final String productUrl;
  final int quantity;
  final double unitPriceAmount;
  final String? notes;

  @override
  List<Object?> get props => [
        productName,
        productUrl,
        quantity,
        unitPriceAmount,
        notes,
      ];
}
