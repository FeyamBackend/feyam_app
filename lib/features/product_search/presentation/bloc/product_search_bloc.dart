import 'package:feyam/features/product_search/domain/failures/product_search_failure.dart';
import 'package:feyam/features/product_search/domain/usecases/search_products.dart';
import 'package:feyam/features/product_search/presentation/bloc/product_search_event.dart';
import 'package:feyam/features/product_search/presentation/bloc/product_search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Minimum characters before a query is sent to the backend — matches the
/// server-side floor (see Module.Products' SearchProductsQueryHandler) so a
/// stray keystroke never triggers a paid Zinc call in either direction.
const int kMinProductSearchQueryLength = 3;

class ProductSearchBloc extends Bloc<ProductSearchEvent, ProductSearchState> {
  ProductSearchBloc({required SearchProductsUseCase searchProductsUseCase})
      : _searchProducts = searchProductsUseCase,
        super(const ProductSearchState()) {
    on<ProductSearchQueryChanged>(_onQueryChanged);
    on<ProductSearchRetailerChanged>(_onRetailerChanged);
    on<ProductSearchRetried>(_onRetried);
    on<ProductSearchNextPageRequested>(_onNextPageRequested);
    on<ProductSearchCleared>(_onCleared);
  }

  final SearchProductsUseCase _searchProducts;

  // The screen already debounces keystrokes with a Timer before dispatching
  // ProductSearchQueryChanged; this counter additionally guards against a
  // slow earlier response overwriting a faster later one.
  int _requestId = 0;

  Future<void> _onQueryChanged(
    ProductSearchQueryChanged event,
    Emitter<ProductSearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query == state.query && state.status != ProductSearchStatus.failure) {
      return;
    }

    if (query.length < kMinProductSearchQueryLength) {
      emit(state.copyWith(
        status: ProductSearchStatus.initial,
        query: query,
        items: const [],
        sources: const [],
        isPartial: false,
        clearNextPage: true,
      ));
      return;
    }

    await _runSearch(query: query, retailer: state.retailer, emit: emit);
  }

  Future<void> _onRetailerChanged(
    ProductSearchRetailerChanged event,
    Emitter<ProductSearchState> emit,
  ) async {
    if (event.retailer == state.retailer) return;

    if (state.query.length < kMinProductSearchQueryLength) {
      emit(state.copyWith(retailer: event.retailer, clearRetailer: event.retailer == null));
      return;
    }

    await _runSearch(query: state.query, retailer: event.retailer, emit: emit);
  }

  Future<void> _onRetried(
    ProductSearchRetried event,
    Emitter<ProductSearchState> emit,
  ) async {
    if (state.query.length < kMinProductSearchQueryLength) return;
    await _runSearch(query: state.query, retailer: state.retailer, emit: emit);
  }

  Future<void> _onNextPageRequested(
    ProductSearchNextPageRequested event,
    Emitter<ProductSearchState> emit,
  ) async {
    final nextPage = state.nextPage;
    if (nextPage == null || state.isLoadingMore) return;

    final requestId = ++_requestId;
    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _searchProducts(
        query: state.query,
        retailer: state.retailer,
        page: nextPage,
      );
      if (requestId != _requestId) return;

      emit(state.copyWith(
        status: ProductSearchStatus.loaded,
        items: [...state.items, ...result.items],
        sources: result.sources,
        isPartial: result.isPartial,
        isLoadingMore: false,
        nextPage: result.nextPage,
        clearNextPage: result.nextPage == null,
      ));
    } on ProductSearchFailure {
      if (requestId != _requestId) return;
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void _onCleared(ProductSearchCleared event, Emitter<ProductSearchState> emit) {
    _requestId++;
    emit(const ProductSearchState());
  }

  Future<void> _runSearch({
    required String query,
    required String? retailer,
    required Emitter<ProductSearchState> emit,
  }) async {
    final requestId = ++_requestId;
    emit(state.copyWith(
      status: ProductSearchStatus.loading,
      query: query,
      retailer: retailer,
      clearRetailer: retailer == null,
      failure: null,
    ));

    try {
      final result = await _searchProducts(query: query, retailer: retailer);
      if (requestId != _requestId) return;

      emit(state.copyWith(
        status: result.items.isEmpty
            ? ProductSearchStatus.empty
            : ProductSearchStatus.loaded,
        items: result.items,
        sources: result.sources,
        isPartial: result.isPartial,
        nextPage: result.nextPage,
        clearNextPage: result.nextPage == null,
      ));
    } on ProductSearchFailure catch (failure) {
      if (requestId != _requestId) return;
      emit(state.copyWith(
        status: ProductSearchStatus.failure,
        items: const [],
        failure: failure,
        clearNextPage: true,
      ));
    }
  }
}
