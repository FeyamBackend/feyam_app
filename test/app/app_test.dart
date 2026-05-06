import 'package:feyam/app/app.dart';
import 'package:feyam/core/di/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders login screen', (tester) async {
    configureDependencies();

    await tester.pumpWidget(const FeyamApp());

    expect(find.text('Sign In'), findsOneWidget);
    expect(
      find.text(
        'You will be redirected to a secure page to sign in. Once completed, you will automatically return to the application.',
      ),
      findsOneWidget,
    );
  });
}
