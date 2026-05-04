import 'package:feyam/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildMaterialTheme', () {
    test('returns Material 3 theme with configured primary color', () {
      final theme = buildMaterialTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, const Color(0xFF0058BC));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF9F9FE));
    });

    test('applies Inter text theme', () {
      final theme = buildMaterialTheme();

      expect(theme.textTheme.bodyLarge?.fontFamily, isNotNull);
      expect(theme.textTheme.bodyLarge!.fontFamily!, contains('Inter'));
    });

    test('exposes AppThemeTokens extension', () {
      final theme = buildMaterialTheme();
      final tokens = theme.extension<AppThemeTokens>();

      expect(tokens, isNotNull);
      expect(tokens!.glassBlur, 30);
    });
  });

  group('buildCupertinoTheme', () {
    test('returns Cupertino theme with configured base colors', () {
      final theme = buildCupertinoTheme();

      expect(theme.primaryColor, const Color(0xFF0058BC));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFAF9FE));
    });

    test('does not force Inter for Cupertino text', () {
      final theme = buildCupertinoTheme();
      final fontFamily = theme.textTheme.textStyle.fontFamily;

      expect(fontFamily, isNull);
    });

    test('keeps Apple fallback stack for Cupertino text', () {
      final theme = buildCupertinoTheme();
      final fallbacks = theme.textTheme.textStyle.fontFamilyFallback;

      expect(fallbacks, isNotNull);
      expect(fallbacks!, contains('SF Pro Text'));
      expect(fallbacks, contains('SF Pro Display'));
    });
  });
}
