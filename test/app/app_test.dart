import 'package:feyam/app/app.dart';
import 'package:feyam/core/di/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders login screen', (tester) async {
    configureDependencies();

    await tester.pumpWidget(const FeyamApp());

    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(
      find.text(
        'Serás redirigido a una página segura para iniciar sesión. Al finalizar, volverás automáticamente a la aplicación.',
      ),
      findsOneWidget,
    );
  });
}
