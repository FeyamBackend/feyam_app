import 'package:equatable/equatable.dart';

abstract class ProductSearchEvent extends Equatable {
  const ProductSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched by the screen after its own debounce timer fires — the bloc
/// itself stays debounce-agnostic and only guards against out-of-order
/// responses (see ProductSearchBloc._requestId).
class ProductSearchQueryChanged extends ProductSearchEvent {
  const ProductSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// null retailer means "Todas" (search everywhere).
class ProductSearchRetailerChanged extends ProductSearchEvent {
  const ProductSearchRetailerChanged(this.retailer);

  final String? retailer;

  @override
  List<Object?> get props => [retailer];
}

class ProductSearchRetried extends ProductSearchEvent {
  const ProductSearchRetried();
}

class ProductSearchNextPageRequested extends ProductSearchEvent {
  const ProductSearchNextPageRequested();
}

class ProductSearchCleared extends ProductSearchEvent {
  const ProductSearchCleared();
}
