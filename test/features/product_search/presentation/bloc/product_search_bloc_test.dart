import 'package:feyam/features/product_search/domain/entities/product_search_item_entity.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_result_entity.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_source_entity.dart';
import 'package:feyam/features/product_search/domain/failures/product_search_failure.dart';
import 'package:feyam/features/product_search/domain/repositories/product_search_repository.dart';
import 'package:feyam/features/product_search/domain/usecases/lookup_product_by_url.dart';
import 'package:feyam/features/product_search/domain/usecases/search_products.dart';
import 'package:feyam/features/product_search/presentation/bloc/product_search_bloc.dart';
import 'package:feyam/features/product_search/presentation/bloc/product_search_event.dart';
import 'package:feyam/features/product_search/presentation/bloc/product_search_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _amazonUrl = 'https://www.amazon.com/dp/B0D1XD1ZV3';

void main() {
  late _FakeProductSearchRepository repository;

  ProductSearchBloc buildBloc() => ProductSearchBloc(
    searchProductsUseCase: SearchProductsUseCase(repository),
    lookupProductByUrlUseCase: LookupProductByUrlUseCase(repository),
  );

  setUp(() {
    repository = _FakeProductSearchRepository();
  });

  test('a plain text query calls search, not lookup', () async {
    repository.searchResult = _resultWithItems('mouse', ['Wireless Mouse']);

    final bloc = buildBloc();
    bloc.add(const ProductSearchQueryChanged('mouse'));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == ProductSearchStatus.loaded,
    );
    await bloc.close();

    expect(state.items.single.title, 'Wireless Mouse');
    expect(repository.searchCalls, ['mouse']);
    expect(repository.lookupCalls, isEmpty);
  });

  test('pasting an Amazon URL calls lookup, not search', () async {
    repository.lookupResult = _resultWithItems(_amazonUrl, ['Echo Dot']);

    final bloc = buildBloc();
    bloc.add(const ProductSearchQueryChanged(_amazonUrl));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == ProductSearchStatus.loaded,
    );
    await bloc.close();

    expect(state.items.single.title, 'Echo Dot');
    expect(repository.lookupCalls, [_amazonUrl]);
    expect(repository.searchCalls, isEmpty);
  });

  test(
    'pasting a URL with tracking query params strips them before lookup',
    () async {
      repository.lookupResult = _resultWithItems(_amazonUrl, ['Echo Dot']);

      final bloc = buildBloc();
      bloc.add(
        const ProductSearchQueryChanged(
          '$_amazonUrl?ref=dlx_labor_dg_dcl&pf_rd_r=5YWW9GYYAN3KCD89EC5R',
        ),
      );
      await bloc.stream.firstWhere(
        (s) => s.status == ProductSearchStatus.loaded,
      );
      await bloc.close();

      expect(repository.lookupCalls, [_amazonUrl]);
    },
  );

  test(
    'a URL the backend cannot resolve lands on the empty state, not failure',
    () async {
      repository.lookupResult = const ProductSearchResultEntity(
        query: 'https://us.shein.com/some-dress.html',
        items: [],
        sources: [ProductSearchSourceEntity(status: 'unsupported')],
        isPartial: false,
      );

      final bloc = buildBloc();
      bloc.add(
        const ProductSearchQueryChanged('https://us.shein.com/some-dress.html'),
      );
      final state = await bloc.stream.firstWhere(
        (s) => s.status != ProductSearchStatus.loading,
      );
      await bloc.close();

      expect(state.status, ProductSearchStatus.empty);
    },
  );

  test('a genuine backend failure on a URL lookup emits failure', () async {
    repository.lookupFailure = const ProductSearchFailure(
      ProductSearchFailureCode.serverError,
    );

    final bloc = buildBloc();
    bloc.add(const ProductSearchQueryChanged(_amazonUrl));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == ProductSearchStatus.failure,
    );
    await bloc.close();

    expect(state.failure?.code, ProductSearchFailureCode.serverError);
  });

  test(
    'retrying after a failed URL lookup re-invokes lookup, not search',
    () async {
      repository.lookupFailure = const ProductSearchFailure(
        ProductSearchFailureCode.networkError,
      );

      final bloc = buildBloc();
      bloc.add(const ProductSearchQueryChanged(_amazonUrl));
      await bloc.stream.firstWhere(
        (s) => s.status == ProductSearchStatus.failure,
      );

      repository.lookupFailure = null;
      repository.lookupResult = _resultWithItems(_amazonUrl, ['Echo Dot']);

      bloc.add(const ProductSearchRetried());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == ProductSearchStatus.loaded,
      );
      await bloc.close();

      expect(state.items.single.title, 'Echo Dot');
      expect(repository.lookupCalls, [_amazonUrl, _amazonUrl]);
      expect(repository.searchCalls, isEmpty);
    },
  );
}

ProductSearchResultEntity _resultWithItems(String query, List<String> titles) {
  return ProductSearchResultEntity(
    query: query,
    items: titles
        .map(
          (title) => ProductSearchItemEntity(
            title: title,
            url: 'https://www.amazon.com/dp/B0D1XD1ZV3',
            retailer: 'amazon',
            currencyCode: 'USD',
          ),
        )
        .toList(),
    sources: const [ProductSearchSourceEntity(status: 'ok')],
    isPartial: false,
  );
}

class _FakeProductSearchRepository implements ProductSearchRepository {
  ProductSearchResultEntity? searchResult;
  ProductSearchFailure? searchFailure;
  final List<String> searchCalls = <String>[];

  ProductSearchResultEntity? lookupResult;
  ProductSearchFailure? lookupFailure;
  final List<String> lookupCalls = <String>[];

  @override
  Future<ProductSearchResultEntity> search({
    required String query,
    String? retailer,
    int page = 1,
  }) async {
    searchCalls.add(query);
    final failure = searchFailure;
    if (failure != null) throw failure;
    return searchResult!;
  }

  @override
  Future<ProductSearchResultEntity> lookupByUrl({required String url}) async {
    lookupCalls.add(url);
    final failure = lookupFailure;
    if (failure != null) throw failure;
    return lookupResult!;
  }
}
