import 'package:flutter/material.dart';

/// Feyam MD3 tonal palette — brand-exact, from the Feyam MD3 Design System:
///   • Primary  (navy,  trust/security)  seed = #0D3B66
///   • Secondary(green, the "go" action) seed = #4CAF50
///   • Tertiary (lime,  small accents)   seed = #C8E600
class ConciergeProPalette {
  const ConciergeProPalette._();

  // Surface / neutral tones (n-*) — unchanged across brand revisions
  static const Color surface = Color(0xFFF9F9FA);            // n-98
  static const Color surfaceDim = Color(0xFFD8DADB);         // n-87
  static const Color surfaceBright = Color(0xFFF9F9FA);      // n-98
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // n-100
  static const Color surfaceContainerLow = Color(0xFFF3F4F4); // n-96
  static const Color surfaceContainer = Color(0xFFEDEEEF);   // n-94
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9); // n-92
  static const Color surfaceContainerHighest = Color(0xFFE1E2E4); // n-90
  static const Color onSurface = Color(0xFF08090A);          // n-10
  static const Color onSurfaceVariant = Color(0xFF363D43);   // nv-30
  static const Color inverseSurface = Color(0xFF202224);     // n-20
  static const Color inverseOnSurface = Color(0xFFF0F1F2);   // n-95
  static const Color outline = Color(0xFF6B737B);            // nv-50
  static const Color outlineVariant = Color(0xFFC2C6CB);     // nv-80
  static const Color surfaceVariant = Color(0xFFE0E3E6);     // nv-90

  // Primary — navy
  static const Color surfaceTint = Color(0xFF0D3B66);        // p-30
  static const Color primary = Color(0xFF0D3B66);            // p-30
  static const Color onPrimary = Color(0xFFFFFFFF);          // p-100
  static const Color primaryContainer = Color(0xFFCEE5FF);   // p-90
  static const Color onPrimaryContainer = Color(0xFF000919); // p-10
  static const Color inversePrimary = Color(0xFFA4CAF4);     // p-80
  static const Color primaryFixed = Color(0xFFCEE5FF);       // p-90
  static const Color primaryFixedDim = Color(0xFFA4CAF4);    // p-80
  static const Color onPrimaryFixed = Color(0xFF000919);     // p-10
  static const Color onPrimaryFixedVariant = Color(0xFF0D3B66); // p-30

  // Secondary — green
  // Note: white text on this exact green is below WCAG AA for normal text;
  // kept as-is to match the brand reference mockups pixel-for-pixel.
  static const Color secondary = Color(0xFF4CAF50);          // s-60
  static const Color onSecondary = Color(0xFFFFFFFF);        // s-100
  static const Color secondaryContainer = Color(0xFFD2EAD1); // s-90
  static const Color onSecondaryContainer = Color(0xFF000D00); // s-10
  static const Color secondaryFixed = Color(0xFFD2EAD1);     // s-90
  static const Color secondaryFixedDim = Color(0xFFAAD3A9);  // s-80
  static const Color onSecondaryFixed = Color(0xFF000D00);   // s-10
  static const Color onSecondaryFixedVariant = Color(0xFF004A09); // s-30

  // Tertiary — lime (used as a dark accessible-on-white accent, not the raw lime)
  static const Color tertiary = Color(0xFF515E00);           // t-40
  static const Color onTertiary = Color(0xFFFFFFFE);         // t-100
  static const Color tertiaryContainer = Color(0xFFDEE8C3);  // t-90
  static const Color onTertiaryContainer = Color(0xFF070A00); // t-10
  static const Color tertiaryFixed = Color(0xFFDEE8C3);      // t-90
  static const Color tertiaryFixedDim = Color(0xFFC0CE91);   // t-80
  static const Color onTertiaryFixed = Color(0xFF070A00);    // t-10
  static const Color onTertiaryFixedVariant = Color(0xFF374100); // t-30

  // Error — unchanged across brand revisions
  static const Color error = Color(0xFFA30F15);              // e-40
  static const Color onError = Color(0xFFFFFFFF);            // e-100
  static const Color errorContainer = Color(0xFFFFD8D2);     // e-90
  static const Color onErrorContainer = Color(0xFF1B0000);   // e-10

  // Background
  static const Color background = Color(0xFFFCFCFD);         // n-99
  static const Color onBackground = Color(0xFF08090A);       // n-10

  /// Raw brand accent — the exact lime hex (`--t-87` in colors_and_type.css)
  /// used for small sparing highlights (tagline emphasis, promo accents).
  /// Not accessible as a foreground color on white; use [tertiary] for text.
  static const Color limeAccent = Color(0xFFC8E600);         // t-87
}

/// Cupertino-path palette — unified with [ConciergeProPalette] so the iOS
/// chrome (nav bars, action sheets, switches) matches the same navy/green/
/// lime brand instead of drifting to an unrelated blue.
class CupertinoGlassVisionPalette {
  const CupertinoGlassVisionPalette._();

  static const Color surface = ConciergeProPalette.surface;
  static const Color surfaceDim = ConciergeProPalette.surfaceDim;
  static const Color surfaceBright = ConciergeProPalette.surfaceBright;
  static const Color surfaceContainerLowest =
      ConciergeProPalette.surfaceContainerLowest;
  static const Color surfaceContainerLow =
      ConciergeProPalette.surfaceContainerLow;
  static const Color surfaceContainer = ConciergeProPalette.surfaceContainer;
  static const Color surfaceContainerHigh =
      ConciergeProPalette.surfaceContainerHigh;
  static const Color surfaceContainerHighest =
      ConciergeProPalette.surfaceContainerHighest;
  static const Color onSurface = ConciergeProPalette.onSurface;
  static const Color onSurfaceVariant = ConciergeProPalette.onSurfaceVariant;
  static const Color inverseSurface = ConciergeProPalette.inverseSurface;
  static const Color inverseOnSurface = ConciergeProPalette.inverseOnSurface;
  static const Color outline = ConciergeProPalette.outline;
  static const Color outlineVariant = ConciergeProPalette.outlineVariant;
  static const Color surfaceTint = ConciergeProPalette.surfaceTint;
  static const Color primary = ConciergeProPalette.primary;
  static const Color onPrimary = ConciergeProPalette.onPrimary;
  static const Color primaryContainer = ConciergeProPalette.primaryContainer;
  static const Color onPrimaryContainer =
      ConciergeProPalette.onPrimaryContainer;
  static const Color inversePrimary = ConciergeProPalette.inversePrimary;
  static const Color secondary = ConciergeProPalette.secondary;
  static const Color onSecondary = ConciergeProPalette.onSecondary;
  static const Color secondaryContainer =
      ConciergeProPalette.secondaryContainer;
  static const Color onSecondaryContainer =
      ConciergeProPalette.onSecondaryContainer;
  static const Color tertiary = ConciergeProPalette.tertiary;
  static const Color onTertiary = ConciergeProPalette.onTertiary;
  static const Color tertiaryContainer =
      ConciergeProPalette.tertiaryContainer;
  static const Color onTertiaryContainer =
      ConciergeProPalette.onTertiaryContainer;
  static const Color error = ConciergeProPalette.error;
  static const Color onError = ConciergeProPalette.onError;
  static const Color errorContainer = ConciergeProPalette.errorContainer;
  static const Color onErrorContainer = ConciergeProPalette.onErrorContainer;
  static const Color primaryFixed = ConciergeProPalette.primaryFixed;
  static const Color primaryFixedDim = ConciergeProPalette.primaryFixedDim;
  static const Color onPrimaryFixed = ConciergeProPalette.onPrimaryFixed;
  static const Color onPrimaryFixedVariant =
      ConciergeProPalette.onPrimaryFixedVariant;
  static const Color secondaryFixed = ConciergeProPalette.secondaryFixed;
  static const Color secondaryFixedDim =
      ConciergeProPalette.secondaryFixedDim;
  static const Color onSecondaryFixed = ConciergeProPalette.onSecondaryFixed;
  static const Color onSecondaryFixedVariant =
      ConciergeProPalette.onSecondaryFixedVariant;
  static const Color tertiaryFixed = ConciergeProPalette.tertiaryFixed;
  static const Color tertiaryFixedDim = ConciergeProPalette.tertiaryFixedDim;
  static const Color onTertiaryFixed = ConciergeProPalette.onTertiaryFixed;
  static const Color onTertiaryFixedVariant =
      ConciergeProPalette.onTertiaryFixedVariant;
  static const Color background = ConciergeProPalette.background;
  static const Color onBackground = ConciergeProPalette.onBackground;
  static const Color surfaceVariant = ConciergeProPalette.surfaceVariant;
}
