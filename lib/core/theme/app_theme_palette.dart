import 'package:flutter/material.dart';

/// Feyam MD3 tonal palette — derived from the Feyam logo:
///   • Primary  (blue,  trust/security)  seed ≈ #003f76
///   • Secondary(green, freshness/go)    seed ≈ #5fa121
///   • Tertiary (gold,  package box)     seed ≈ #c9a227
class ConciergeProPalette {
  const ConciergeProPalette._();

  // Surface / neutral tones (n-*)
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

  // Primary — blue
  static const Color surfaceTint = Color(0xFF005997);        // p-40
  static const Color primary = Color(0xFF005997);            // p-40
  static const Color onPrimary = Color(0xFFFFFFFF);          // p-100
  static const Color primaryContainer = Color(0xFFCEE6FD);   // p-90
  static const Color onPrimaryContainer = Color(0xFF000917); // p-10
  static const Color inversePrimary = Color(0xFFA3CBF1);     // p-80
  static const Color primaryFixed = Color(0xFFCEE6FD);       // p-90
  static const Color primaryFixedDim = Color(0xFFA3CBF1);    // p-80
  static const Color onPrimaryFixed = Color(0xFF000917);     // p-10
  static const Color onPrimaryFixedVariant = Color(0xFF003E6B); // p-30

  // Secondary — green
  static const Color secondary = Color(0xFF31642C);          // s-40
  static const Color onSecondary = Color(0xFFFFFFFF);        // s-100
  static const Color secondaryContainer = Color(0xFFD6E8D4); // s-90
  static const Color onSecondaryContainer = Color(0xFF000D00); // s-10
  static const Color secondaryFixed = Color(0xFFD6E8D4);     // s-90
  static const Color secondaryFixedDim = Color(0xFFB2D0AE);  // s-80
  static const Color onSecondaryFixed = Color(0xFF000D00);   // s-10
  static const Color onSecondaryFixedVariant = Color(0xFF1B4717); // s-30

  // Tertiary — gold
  static const Color tertiary = Color(0xFF675500);           // t-40
  static const Color onTertiary = Color(0xFFFFFFFE);         // t-100
  static const Color tertiaryContainer = Color(0xFFEAE3C8);  // t-90
  static const Color onTertiaryContainer = Color(0xFF0C0800); // t-10
  static const Color tertiaryFixed = Color(0xFFEAE3C8);      // t-90
  static const Color tertiaryFixedDim = Color(0xFFD2C699);   // t-80
  static const Color onTertiaryFixed = Color(0xFF0C0800);    // t-10
  static const Color onTertiaryFixedVariant = Color(0xFF483B00); // t-30

  // Error
  static const Color error = Color(0xFFA30F15);              // e-40
  static const Color onError = Color(0xFFFFFFFF);            // e-100
  static const Color errorContainer = Color(0xFFFFD8D2);     // e-90
  static const Color onErrorContainer = Color(0xFF1B0000);   // e-10

  // Background
  static const Color background = Color(0xFFFCFCFD);         // n-99
  static const Color onBackground = Color(0xFF08090A);       // n-10
}

class CupertinoGlassVisionPalette {
  const CupertinoGlassVisionPalette._();

  static const Color surface = Color(0xFFFAF9FE);
  static const Color surfaceDim = Color(0xFFDAD9DF);
  static const Color surfaceBright = Color(0xFFFAF9FE);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F8);
  static const Color surfaceContainer = Color(0xFFEEEDF3);
  static const Color surfaceContainerHigh = Color(0xFFE9E7ED);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E7);
  static const Color onSurface = Color(0xFF1A1B1F);
  static const Color onSurfaceVariant = Color(0xFF414755);
  static const Color inverseSurface = Color(0xFF2F3034);
  static const Color inverseOnSurface = Color(0xFFF1F0F5);
  static const Color outline = Color(0xFF717786);
  static const Color outlineVariant = Color(0xFFC1C6D7);
  static const Color surfaceTint = Color(0xFF005BC1);
  static const Color primary = Color(0xFF0058BC);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0070EB);
  static const Color onPrimaryContainer = Color(0xFFFEFCFF);
  static const Color inversePrimary = Color(0xFFADC6FF);
  static const Color secondary = Color(0xFF006E28);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF6FFB85);
  static const Color onSecondaryContainer = Color(0xFF00732A);
  static const Color tertiary = Color(0xFF4C4ACA);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF6664E4);
  static const Color onTertiaryContainer = Color(0xFFFFFBFF);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color primaryFixed = Color(0xFFD8E2FF);
  static const Color primaryFixedDim = Color(0xFFADC6FF);
  static const Color onPrimaryFixed = Color(0xFF001A41);
  static const Color onPrimaryFixedVariant = Color(0xFF004493);
  static const Color secondaryFixed = Color(0xFF72FE88);
  static const Color secondaryFixedDim = Color(0xFF53E16F);
  static const Color onSecondaryFixed = Color(0xFF002107);
  static const Color onSecondaryFixedVariant = Color(0xFF00531C);
  static const Color tertiaryFixed = Color(0xFFE2DFFF);
  static const Color tertiaryFixedDim = Color(0xFFC2C1FF);
  static const Color onTertiaryFixed = Color(0xFF0C006A);
  static const Color onTertiaryFixedVariant = Color(0xFF3631B4);
  static const Color background = Color(0xFFFAF9FE);
  static const Color onBackground = Color(0xFF1A1B1F);
  static const Color surfaceVariant = Color(0xFFE3E2E7);
}
