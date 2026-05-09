import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders title, footer, and children', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: const Scaffold(
          body: AdaptiveAppFormSection(
            title: 'Order details',
            footer: 'Footer text',
            children: <Widget>[
              Text('First child'),
              Text('Second child'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Order details'), findsOneWidget);
    expect(find.text('Footer text'), findsOneWidget);
    expect(find.text('First child'), findsOneWidget);
    expect(find.text('Second child'), findsOneWidget);
  });

  testWidgets('renders without Material-only dependencies on iOS', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: const CupertinoPageScaffold(
          child: AdaptiveAppFormSection(
            title: 'Order details',
            footer: 'Footer text',
            children: <Widget>[
              AdaptiveAppTextField(label: 'Name'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.text('Order details'), findsOneWidget);
    expect(find.text('Footer text'), findsOneWidget);
  });
}
