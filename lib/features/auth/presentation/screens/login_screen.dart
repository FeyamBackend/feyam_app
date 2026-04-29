import 'package:feyam_app/core/widgets/adaptive/adaptive_app_button.dart';
import 'package:feyam_app/core/widgets/adaptive/adaptive_app_disclaimer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String _loginBackgroundAsset = 'assets/images/ios_login_background.png';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Theme(
      data: Theme.of(context).copyWith(platform: defaultTargetPlatform),
      child: const _SharedLoginPage(),
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(child: content);
    }

    return Scaffold(body: content);
  }
}

class _SharedLoginPage extends StatelessWidget {
  const _SharedLoginPage();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCupertino = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final panelColor = isCupertino
        ? CupertinoTheme.of(context).scaffoldBackgroundColor
        : colorScheme.surface;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const _LoginBackground(),
        LayoutBuilder(
          builder: (context, constraints) {
            final logoWidth = (constraints.maxWidth * 0.42)
                .clamp(180.0, 240.0)
                .toDouble();
            final panelHeight = (constraints.maxHeight * 0.40)
                .clamp(360.0, 420.0)
                .toDouble();

            return Stack(
              children: <Widget>[
                SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: const Alignment(0, -0.48),
                    child: Image.asset(
                      'assets/branding/logo.png',
                      width: logoWidth,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: panelHeight + bottomInset,
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(32, 50, 32, 22 + bottomInset),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(56),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.10),
                          blurRadius: 34,
                          offset: const Offset(0, -16),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AdaptiveAppButton(
                              text: 'Iniciar Sesión',
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                // Handle login logic here.
                              },
                              height: 72,
                              borderRadius: BorderRadius.circular(28),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                            ),
                            const SizedBox(height: 32),
                            AdaptiveAppDisclaimer(
                              message:
                                  'Serás redirigido a una pagina segura para iniciar sesión. Al finalizar, volverás automáticamente a la aplicación.',
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 22,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              backgroundColor: colorScheme.surface.withValues(
                                alpha: 0.72,
                              ),
                              foregroundColor: colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const _MeshGradientBackground(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.36,
            child: Image.asset(
              _loginBackgroundAsset,
              alignment: Alignment.topCenter,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.30),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                colorScheme.surface.withValues(alpha: 0.18),
                colorScheme.surface.withValues(alpha: 0.42),
                colorScheme.surface.withValues(alpha: 0.10),
              ],
              stops: const <double>[0, 0.42, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _MeshGradientBackground extends StatelessWidget {
  const _MeshGradientBackground();

  static const Color _base = Color(0xFFF8FAFC);
  static const Color _softBlue = Color(0xB3D1E4FF);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _softLime = Color(0xFFD9FAD9);

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: _base,
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.22,
          colors: <Color>[_softBlue, Color(0x00D1E4FF)],
          stops: <double>[0, 0.56],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _GradientBlob(
            alignment: Alignment.topRight,
            color: _mint,
            opacity: 0.62,
            sizeFactor: 1.16,
          ),
          _GradientBlob(
            alignment: Alignment.bottomLeft,
            color: _softLime,
            opacity: 0.64,
            sizeFactor: 1.18,
          ),
        ],
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  const _GradientBlob({
    required this.alignment,
    required this.color,
    required this.opacity,
    required this.sizeFactor,
  });

  final Alignment alignment;
  final Color color;
  final double opacity;
  final double sizeFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: sizeFactor,
        heightFactor: sizeFactor,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
              stops: const <double>[0, 0.56],
            ),
          ),
        ),
      ),
    );
  }
}
