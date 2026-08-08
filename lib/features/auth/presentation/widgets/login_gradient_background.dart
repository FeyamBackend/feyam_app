import 'package:feyam/core/theme/app_theme_palette.dart';
import 'package:flutter/material.dart';

/// Flat solid navy hero background, matching the Feyam brand's welcome
/// screen: no gradients, textures, or photography behind the primary color.
class LoginGradientBackground extends StatelessWidget {
  const LoginGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: ConciergeProPalette.primary);
  }
}
