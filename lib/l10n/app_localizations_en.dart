// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Sign In';

  @override
  String get loginDisclaimer =>
      'You will be redirected to a secure page to sign in. Once completed, you will automatically return to the application.';
}
