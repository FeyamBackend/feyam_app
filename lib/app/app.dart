import 'package:feyam/core/theme/cupertino_theme.dart';
import 'package:feyam/core/theme/material_theme.dart';
import 'package:feyam/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FeyamApp extends StatelessWidget {
  const FeyamApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (_useCupertino) {
      return CupertinoApp(
        title: 'Feyam',
        theme: buildCupertinoTheme(),
        home: LoginScreen(),
      );
    }

    return MaterialApp(
      title: 'Feyam',
      theme: buildMaterialTheme(),
      home: LoginScreen(),
    );
  }

  bool get _useCupertino {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.iOS;
  }
}
