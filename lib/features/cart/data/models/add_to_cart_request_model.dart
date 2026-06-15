class AddToCartRequestModel {
  const AddToCartRequestModel({
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

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'productUrl': productUrl,
        'quantity': quantity,
        'unitPriceAmount': unitPriceAmount,
        'currencyCode': currencyCode,
        if (productImageUrl != null) 'productImageUrl': productImageUrl,
        if (notes != null) 'notes': notes,
        if (variantAttributes != null) 'variantAttributes': variantAttributes,
      };
}
