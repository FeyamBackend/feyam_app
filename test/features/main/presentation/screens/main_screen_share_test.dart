import 'package:feyam/features/main/presentation/screens/main_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
