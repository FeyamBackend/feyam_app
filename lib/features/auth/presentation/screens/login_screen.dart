import 'package:feyam_app/core/widgets/adaptive/adaptive_app_button.dart';
import 'package:feyam_app/core/widgets/adaptive/adaptive_app_card.dart';
import 'package:feyam_app/core/widgets/adaptive/adaptive_app_disclaimer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String _iosLoginBackgroundAsset =
    'assets/images/ios_login_background.png';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return const _IosLoginPage();
    }

    return const _MaterialLoginPage();
  }
}

class _IosLoginPage extends StatelessWidget {
  const _IosLoginPage();

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CupertinoPageScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final logoWidth = (constraints.maxWidth * 0.42)
              .clamp(180.0, 240.0)
              .toDouble();
          final panelHeight = (constraints.maxHeight * 0.40)
              .clamp(360.0, 420.0)
              .toDouble();

          return Stack(
            children: <Widget>[
              const Positioned.fill(child: _IosLoginBackground()),
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: const Alignment(0, -0.48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        'assets/branding/logo.png',
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                    ],
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
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(56),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.10),
                        blurRadius: 34,
                        offset: const Offset(0, -16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AdaptiveAppButton(
                        text: 'Iniciar Sesión',
                        onPressed: () {
                          // Handle login logic here.
                        },
                        height: 72,
                        borderRadius: BorderRadius.circular(28),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      const SizedBox(height: 32),
                      AdaptiveAppDisclaimer(
                        message:
                            'Serás redirigido a una pagina segura para iniciar sesión. Al finalizar, volverás automáticamente a la aplicación.',
                        icon: const Icon(CupertinoIcons.lock_fill),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 22,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IosLoginBackground extends StatelessWidget {
  const _IosLoginBackground();

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                theme.primaryColor.withValues(alpha: 0.20),
                theme.scaffoldBackgroundColor,
                theme.primaryContrastingColor.withValues(alpha: 0.28),
              ],
              stops: const <double>[0, 0.50, 1],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.36,
            child: Image.asset(
              _iosLoginBackgroundAsset,
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
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.30),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                theme.scaffoldBackgroundColor.withValues(alpha: 0.18),
                theme.scaffoldBackgroundColor.withValues(alpha: 0.42),
                theme.scaffoldBackgroundColor.withValues(alpha: 0.10),
              ],
              stops: const <double>[0, 0.42, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _MaterialLoginPage extends StatelessWidget {
  const _MaterialLoginPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: AdaptiveAppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'assets/branding/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AdaptiveAppButton(
                  text: 'Iniciar Sesión',
                  onPressed: () {
                    // Handle login logic here.
                  },
                ),
                const SizedBox(height: 16),
                const AdaptiveAppDisclaimer(
                  message:
                      'Serás redirigido a una pagina segura para iniciar sesión. Al finalizar, volverás automáticamente a la aplicación.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
