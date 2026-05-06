import 'package:feyam/features/auth/presentation/widgets/login_gradient_background.dart';
import 'package:flutter/material.dart';

const String _loginBackgroundAsset = 'assets/images/ios_login_background.png';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const LoginGradientBackground(),
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
