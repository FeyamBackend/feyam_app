import 'package:feyam_app/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders welcome text', (tester) async {
    await tester.pumpWidget(const FeyamApp());

    expect(find.text('Hello, Feyam App!'), findsOneWidget);
  });
}
