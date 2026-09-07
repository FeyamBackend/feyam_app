import 'package:feyam/core/utils/product_url_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('looksLikeProductUrl', () {
    test('returns true for an absolute https product URL', () {
      expect(
        looksLikeProductUrl('https://www.amazon.com/dp/B0D1XD1ZV3'),
        isTrue,
      );
    });

    test('returns true for an absolute http URL', () {
      expect(looksLikeProductUrl('http://example.com/item'), isTrue);
    });

    test('returns false for plain text search terms', () {
      expect(looksLikeProductUrl('wireless mouse'), isFalse);
    });

    test('returns false for a schemeless URL-looking string', () {
      // A known gap: text copied without its scheme (e.g. "amazon.com/dp/X")
      // falls through to the existing plain-text search path, same as today.
      expect(looksLikeProductUrl('amazon.com/dp/B0D1XD1ZV3'), isFalse);
    });

    test('returns false for an empty string', () {
      expect(looksLikeProductUrl(''), isFalse);
    });

    test('returns false for whitespace only', () {
      expect(looksLikeProductUrl('   '), isFalse);
    });

    test('returns false for a non-http(s) scheme', () {
      expect(looksLikeProductUrl('ftp://example.com/item'), isFalse);
    });

    test('trims surrounding whitespace before checking', () {
      expect(
        looksLikeProductUrl('  https://www.amazon.com/dp/B0D1XD1ZV3  '),
        isTrue,
      );
    });
  });

  group('stripUrlQueryParams', () {
    test('drops Amazon-style tracking query params', () {
      expect(
        stripUrlQueryParams(
          'https://www.amazon.com/Ninja-tostador/dp/B0D1CXL52G'
          '?ref=dlx_labor_dg_dcl_B0D1CXL52G_mw_sl14_27_pi'
          '&pf_rd_r=5YWW9GYYAN3KCD89EC5R'
          '&sbo=RZvfv%2F%2FHxDF%2BO5021pAnSA%3D%3D',
        ),
        'https://www.amazon.com/Ninja-tostador/dp/B0D1CXL52G',
      );
    });

    test('returns the url unchanged when there is no query string', () {
      expect(
        stripUrlQueryParams('https://www.amazon.com/dp/B0D1CXL52G'),
        'https://www.amazon.com/dp/B0D1CXL52G',
      );
    });

    test('drops a bare trailing question mark with nothing after it', () {
      expect(
        stripUrlQueryParams('https://www.amazon.com/dp/B0D1CXL52G?'),
        'https://www.amazon.com/dp/B0D1CXL52G',
      );
    });
  });
}
