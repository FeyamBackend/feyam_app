import 'dart:async';

/// Único punto que señala "la sesión expiró de verdad" (el refresh token ya no
/// sirve). El [AuthenticatedHttpClient] emite por acá tras un refresh definitivo
/// fallido y el `AuthBloc` lo escucha para deslogear una sola vez,
/// independientemente de la pantalla activa.
class SessionExpiredNotifier {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  void dispose() {
    _controller.close();
  }
}
