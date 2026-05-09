import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a CupertinoPageScaffold with navigation bar on iOS', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: const AdaptiveAppScaffold(
          title: 'Orders',
          body: Text('Body'),
        ),
      ),
    );

    expect(find.byType(CupertinoPageScaffold), findsOneWidget);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.byType(Scaffold), findsNothing);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('renders a Material Scaffold with app bar off iOS', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: const AdaptiveAppScaffold(
          title: 'Orders',
          body: Text('Body'),
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(CupertinoPageScaffold), findsNothing);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('preserves bottom navigation bar on iOS and off iOS', (
    tester,
  ) async {
    for (final platform in <TargetPlatform>[
      TargetPlatform.iOS,
      TargetPlatform.android,
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: const AdaptiveAppScaffold(
            title: 'Orders',
            body: Text('Body'),
            bottomNavigationBar: Text('Bottom bar'),
          ),
        ),
      );

      expect(find.text('Bottom bar'), findsOneWidget);
    }
  });

  testWidgets('uses a CupertinoSliverNavigationBar for large titles on iOS', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: const AdaptiveAppScaffold(
          largeTitle: 'Add to cart',
          body: Text('Body'),
        ),
      ),
    );

    expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
    expect(find.text('Add to cart'), findsOneWidget);
  });
}
