import 'package:feyam/features/auth/presentation/widgets/login_gradient_background.dart';
import 'package:flutter/material.dart';

/// Solid navy hero behind the login panel — see [LoginGradientBackground].
class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginGradientBackground();
  }
}
