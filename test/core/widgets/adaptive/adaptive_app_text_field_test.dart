import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a CupertinoTextField on iOS', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: const Scaffold(
          body: AdaptiveAppTextField(
            label: 'Name',
            placeholder: 'Enter your name',
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Enter your name'), findsOneWidget);
  });

  testWidgets('renders a TextFormField off iOS', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: const Scaffold(
          body: AdaptiveAppTextField(
            label: 'Name',
            placeholder: 'Enter your name',
          ),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsNothing);
    expect(find.text('Name'), findsOneWidget);
  });

  testWidgets('emits changes on Material', (tester) async {
    var value = '';

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Scaffold(
          body: AdaptiveAppTextField(
            onChanged: (newValue) {
              value = newValue;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Feyam');

    expect(value, 'Feyam');
  });

  testWidgets('emits changes on Cupertino', (tester) async {
    var value = '';

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Scaffold(
          body: AdaptiveAppTextField(
            onChanged: (newValue) {
              value = newValue;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(CupertinoTextField), 'Feyam');

    expect(value, 'Feyam');
  });

  testWidgets('shows validation errors on Material and Cupertino', (
    tester,
  ) async {
    for (final platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
    ]) {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AdaptiveAppTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }

                  return null;
                },
              ),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    }
  });

  testWidgets('propagates core field properties', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: const Scaffold(
          body: AdaptiveAppTextField(
            obscureText: true,
            enabled: false,
            readOnly: true,
            maxLines: 4,
          ),
        ),
      ),
    );

    final cupertinoField = tester.widget<CupertinoTextField>(
      find.byType(CupertinoTextField),
    );
    expect(cupertinoField.obscureText, isTrue);
    expect(cupertinoField.enabled, isFalse);
    expect(cupertinoField.readOnly, isTrue);
    expect(cupertinoField.maxLines, 1);

    await tester.pumpWidget(const SizedBox.shrink());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: const Scaffold(
          body: AdaptiveAppTextField(
            obscureText: true,
            readOnly: true,
            maxLines: 4,
          ),
        ),
      ),
    );

    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.obscureText, isTrue);
    expect(editableText.readOnly, isTrue);
    expect(editableText.maxLines, 1);

    await tester.pumpWidget(const SizedBox.shrink());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: const Scaffold(
          body: AdaptiveAppTextField(enabled: false),
        ),
      ),
    );

    final disabledTextFormField = tester.widget<TextFormField>(
      find.byType(TextFormField),
    );
    expect(disabledTextFormField.enabled, isFalse);
  });
}
