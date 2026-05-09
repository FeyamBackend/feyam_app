import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptivePlatform {
  const AdaptivePlatform._();

  static bool isCupertino(BuildContext context) {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  static PageRoute<T> pageRoute<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    if (isCupertino(context)) {
      return CupertinoPageRoute<T>(builder: builder);
    }

    return MaterialPageRoute<T>(builder: builder);
  }
}
