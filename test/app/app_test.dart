import 'package:feyam_app/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders login screen', (tester) async {
    await tester.pumpWidget(const FeyamApp());

    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(
      find.text(
        'Serás redirigido a una pagina segura para iniciar sesión. Al finalizar, volverás automáticamente a la aplicación.',
      ),
      findsOneWidget,
    );
  });
}
