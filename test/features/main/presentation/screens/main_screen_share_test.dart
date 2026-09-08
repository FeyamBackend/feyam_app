import 'package:feyam/features/main/presentation/screens/main_screen.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_item_entity.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_result_entity.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_source_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mergeSharedLinkWithLookup', () {
    const link = SharedProductLink(
      url: 'https://www.amazon.com/dp/B0D1XD1ZV3',
      title: 'From the share sheet',
    );

    test('resolved item wins over the shared title, url stays as shared', () {
      final result = ProductSearchResultEntity(
        query: link.url,
        items: const [
          ProductSearchItemEntity(
            title: 'Echo Dot (5th Gen)',
            url: 'https://www.amazon.com/dp/B0D1XD1ZV3?ref=abc',
            retailer: 'amazon',
            currencyCode: 'USD',
            price: 49.99,
            imageUrl: 'https://m.media-amazon.com/images/echo.jpg',
          ),
        ],
        sources: const [ProductSearchSourceEntity(status: 'ok')],
        isPartial: false,
      );

      final merged = mergeSharedLinkWithLookup(link, result);

      expect(merged.url, link.url);
      expect(merged.title, 'Echo Dot (5th Gen)');
      expect(merged.priceAmount, 49.99);
      expect(merged.imageUrl, 'https://m.media-amazon.com/images/echo.jpg');
    });

    test('null lookup result falls back to the shared link unchanged', () {
      final merged = mergeSharedLinkWithLookup(link, null);

      expect(merged.url, link.url);
      expect(merged.title, link.title);
      expect(merged.priceAmount, isNull);
      expect(merged.imageUrl, isNull);
    });

    test('a success with zero items (unsupported retailer) falls back to the '
        'shared link unchanged', () {
      const empty = ProductSearchResultEntity(
        query: 'https://us.shein.com/some-dress.html',
        items: [],
        sources: [ProductSearchSourceEntity(status: 'unsupported')],
        isPartial: false,
      );

      final merged = mergeSharedLinkWithLookup(link, empty);

      expect(merged.url, link.url);
      expect(merged.title, link.title);
    });
  });

  group('parseSharedProductEvent', () {
    test('splits a title + URL map into url and title', () {
      final link = parseSharedProductEvent(<String, String>{
        'url': 'https://a.co/d/0cHTXkqu',
        'title':
            'Amazon Essentials - Pantalón chino casual elástico de corte '
            'recto para hombre',
      });

      expect(link, isNotNull);
      expect(link!.url, 'https://a.co/d/0cHTXkqu');
      expect(
        link.title,
        'Amazon Essentials - Pantalón chino casual elástico de corte '
        'recto para hombre',
      );
    });

    test('treats an empty title as absent', () {
      final link = parseSharedProductEvent(<String, String>{
        'url': 'https://a.co/d/0cHTXkqu',
        'title': '',
      });

      expect(link, isNotNull);
      expect(link!.url, 'https://a.co/d/0cHTXkqu');
      expect(link.title, isNull);
    });

    test('accepts a map with no title key at all', () {
      final link = parseSharedProductEvent(<String, String>{
        'url': 'https://a.co/d/0cHTXkqu',
      });

      expect(link, isNotNull);
      expect(link!.url, 'https://a.co/d/0cHTXkqu');
      expect(link.title, isNull);
    });

    test('returns null when the map has no url', () {
      final link = parseSharedProductEvent(<String, String>{
        'title': 'Some product',
      });

      expect(link, isNull);
    });

    test('returns null when the url is empty', () {
      final link = parseSharedProductEvent(<String, String>{'url': ''});

      expect(link, isNull);
    });

    test('falls back to treating a bare string as the url', () {
      final link = parseSharedProductEvent('https://a.co/d/0cHTXkqu');

      expect(link, isNotNull);
      expect(link!.url, 'https://a.co/d/0cHTXkqu');
      expect(link.title, isNull);
    });

    test('returns null for an empty string', () {
      final link = parseSharedProductEvent('');

      expect(link, isNull);
    });

    test('returns null for null input', () {
      final link = parseSharedProductEvent(null);

      expect(link, isNull);
    });

    test('returns null for unsupported types', () {
      final link = parseSharedProductEvent(42);

      expect(link, isNull);
    });
  });
}
