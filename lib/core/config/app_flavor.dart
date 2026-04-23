enum AppFlavor { dev, stg, prod }

extension AppFlavorX on AppFlavor {
  String get name {
    switch (this) {
      case AppFlavor.dev:
        return 'dev';
      case AppFlavor.stg:
        return 'stg';
      case AppFlavor.prod:
        return 'prod';
    }
  }

  bool get isProduction => this == AppFlavor.prod;
}
