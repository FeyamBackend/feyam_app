import 'package:feyam/features/product_search/domain/entities/product_search_item_entity.dart';

class ProductSearchItemModel extends ProductSearchItemEntity {
  const ProductSearchItemModel({
    required super.title,
    required super.url,
    required super.retailer,
    required super.currencyCode,
    super.imageUrl,
    super.price,
    super.productId,
    super.brand,
    super.stars,
    super.numReviews,
    super.available,
    super.prime,
  });

  factory ProductSearchItemModel.fromJson(Map<String, dynamic> json) {
    return ProductSearchItemModel(
      title: json['title'] as String,
      url: json['url'] as String,
      retailer: json['retailer'] as String,
      currencyCode: json['currencyCode'] as String,
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      productId: json['productId'] as String?,
      brand: json['brand'] as String?,
      stars: (json['stars'] as num?)?.toDouble(),
      numReviews: json['numReviews'] as int?,
      available: json['available'] as bool?,
      prime: json['prime'] as bool?,
    );
  }
}
