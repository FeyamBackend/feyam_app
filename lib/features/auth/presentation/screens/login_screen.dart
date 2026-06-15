import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/features/auth/presentation/widgets/login_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveAppScaffold(
      body: Theme(
        data: Theme.of(context).copyWith(platform: defaultTargetPlatform),
        child: const LoginContent(),
      ),
    );
  }
}
