import 'package:equatable/equatable.dart';

class ProductSearchItemEntity extends Equatable {
  const ProductSearchItemEntity({
    required this.title,
    required this.url,
    required this.retailer,
    required this.currencyCode,
    this.imageUrl,
    this.price,
    this.productId,
    this.brand,
    this.stars,
    this.numReviews,
    this.available,
    this.prime,
  });

  final String title;
  final String url;
  final String? imageUrl;

  /// In major units (e.g. 24.97). Null means Zinc didn't return a price for
  /// this item — the add-to-cart form should leave the price empty and
  /// editable, same as the manual paste-link flow does today.
  final double? price;
  final String currencyCode;
  final String retailer;
  final String? productId;
  final String? brand;
  final double? stars;
  final int? numReviews;
  final bool? available;
  final bool? prime;

  @override
  List<Object?> get props => [
        title,
        url,
        imageUrl,
        price,
        currencyCode,
        retailer,
        productId,
        brand,
        stars,
        numReviews,
        available,
        prime,
      ];
}
