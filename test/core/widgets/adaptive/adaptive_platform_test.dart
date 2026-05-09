import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pageRoute returns a CupertinoPageRoute on iOS', (tester) async {
    PageRoute<void>? route;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Builder(
          builder: (context) {
            route = AdaptivePlatform.pageRoute<void>(
              context: context,
              builder: (_) => const SizedBox.shrink(),
            );

            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(route, isA<CupertinoPageRoute<void>>());
  });

  testWidgets('pageRoute returns a MaterialPageRoute off iOS', (tester) async {
    PageRoute<void>? route;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Builder(
          builder: (context) {
            route = AdaptivePlatform.pageRoute<void>(
              context: context,
              builder: (_) => const SizedBox.shrink(),
            );

            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(route, isA<MaterialPageRoute<void>>());
  });
}
