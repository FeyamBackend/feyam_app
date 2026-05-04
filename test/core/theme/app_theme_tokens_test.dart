import 'package:feyam/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme palettes', () {
    test('maps critical Material colors', () {
      expect(ConciergeProPalette.primary, const Color(0xFF0058BC));
      expect(ConciergeProPalette.secondary, const Color(0xFF006E28));
      expect(ConciergeProPalette.surface, const Color(0xFFF9F9FE));
      expect(ConciergeProPalette.error, const Color(0xFFBA1A1A));
    });

    test('maps critical Cupertino colors', () {
      expect(CupertinoGlassVisionPalette.primary, const Color(0xFF0058BC));
      expect(CupertinoGlassVisionPalette.secondary, const Color(0xFF006E28));
      expect(CupertinoGlassVisionPalette.surface, const Color(0xFFFAF9FE));
      expect(CupertinoGlassVisionPalette.error, const Color(0xFFBA1A1A));
    });
  });

  group('AppThemeTokens scales', () {
    test('contains expected Material spacing and radius values', () {
      expect(materialThemeTokens.radiusSm, 4);
      expect(materialThemeTokens.radiusDefault, 8);
      expect(materialThemeTokens.radiusMd, 12);
      expect(materialThemeTokens.radiusLg, 16);
      expect(materialThemeTokens.radiusXl, 24);
      expect(materialThemeTokens.radiusFull, 9999);

      expect(materialThemeTokens.spaceXs, 4);
      expect(materialThemeTokens.spaceSm, 8);
      expect(materialThemeTokens.spaceMd, 16);
      expect(materialThemeTokens.spaceLg, 24);
      expect(materialThemeTokens.spaceXl, 32);
      expect(materialThemeTokens.marginMobile, 16);
      expect(materialThemeTokens.gutter, 12);
    });

    test('contains expected Cupertino spacing and radius values', () {
      expect(cupertinoThemeTokens.radiusSm, 4);
      expect(cupertinoThemeTokens.radiusDefault, 8);
      expect(cupertinoThemeTokens.radiusMd, 12);
      expect(cupertinoThemeTokens.radiusLg, 16);
      expect(cupertinoThemeTokens.radiusXl, 24);
      expect(cupertinoThemeTokens.radiusFull, 9999);

      expect(cupertinoThemeTokens.spaceXs, 4);
      expect(cupertinoThemeTokens.spaceSm, 8);
      expect(cupertinoThemeTokens.spaceMd, 16);
      expect(cupertinoThemeTokens.spaceLg, 24);
      expect(cupertinoThemeTokens.spaceXl, 32);
      expect(cupertinoThemeTokens.marginMobile, 20);
      expect(cupertinoThemeTokens.gutter, 16);
    });
  });
}
