import 'package:flutter/material.dart';

class LoginGradientBackground extends StatelessWidget {
  const LoginGradientBackground({super.key});

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
