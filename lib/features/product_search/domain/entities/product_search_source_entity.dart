import 'package:equatable/equatable.dart';

/// Reports which underlying Zinc call(s) backed a search (structured per-retailer vs.
/// the beta cross-retailer search), so the UI can show a "couldn't search other
/// stores" banner instead of silently returning partial results.
class ProductSearchSourceEntity extends Equatable {
  const ProductSearchSourceEntity({
    required this.status,
    this.source,
    this.retailer,
  });

  final String? source;
  final String? retailer;

  /// ok | failed | timeout | disabled | skipped | unsupported
  final String status;

  @override
  List<Object?> get props => [source, retailer, status];
}
