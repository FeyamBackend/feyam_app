import 'package:feyam_app/core/theme/cupertino_theme.dart';
import 'package:feyam_app/core/theme/material_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FeyamApp extends StatelessWidget {
  const FeyamApp({super.key});

  @override
  Widget build(BuildContext context) {

    if(_useCupertino) {
      return CupertinoApp(
        title: 'Feyam App',
        theme: buildCupertinoTheme(),
        home: const CupertinoPageScaffold(
          child: Center(
            child: Text('Hello, Feyam App!'),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Feyam App',
      theme: buildMaterialTheme(),
      home: const Scaffold(
        body: Center(
          child: Text('Hello, Feyam App!'),
        ),
      ),
    );
  }

  bool get _useCupertino {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.iOS;
  }
}