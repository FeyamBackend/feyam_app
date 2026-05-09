import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Label for the button that initiates the sign-in process.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login;

  /// Disclaimer shown to users before they are redirected to the sign-in page.
  ///
  /// In en, this message translates to:
  /// **'You will be redirected to a secure page to sign in. Once completed, you will automatically return to the application.'**
  String get loginDisclaimer;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @addToCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCartTitle;

  /// No description provided for @addToCartPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get addToCartPlaceholder;

  /// No description provided for @homeImportOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Order'**
  String get homeImportOrderTitle;

  /// No description provided for @homePasteProductLink.
  ///
  /// In en, this message translates to:
  /// **'Paste product link'**
  String get homePasteProductLink;

  /// No description provided for @homeImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get homeImportButton;

  /// No description provided for @homeImportProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Product'**
  String get homeImportProductTitle;

  /// No description provided for @homePasteProductExample.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/product/123'**
  String get homePasteProductExample;

  /// No description provided for @homeAddToCartButton.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get homeAddToCartButton;

  /// No description provided for @homePopularStoresTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular stores'**
  String get homePopularStoresTitle;

  /// No description provided for @homePopularStoresTitleMaterial.
  ///
  /// In en, this message translates to:
  /// **'Popular Stores'**
  String get homePopularStoresTitleMaterial;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeRecentOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get homeRecentOrdersTitle;

  /// No description provided for @homeRecentOrdersTitleMaterial.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get homeRecentOrdersTitleMaterial;

  /// No description provided for @homeStatusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get homeStatusInTransit;

  /// No description provided for @homeStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get homeStatusDelivered;

  /// No description provided for @homeCupertinoOrder1Product.
  ///
  /// In en, this message translates to:
  /// **'Premium Sneakers Red Edition'**
  String get homeCupertinoOrder1Product;

  /// No description provided for @homeCupertinoOrder1Origin.
  ///
  /// In en, this message translates to:
  /// **'Imported from Amazon USA'**
  String get homeCupertinoOrder1Origin;

  /// No description provided for @homeCupertinoOrder2Product.
  ///
  /// In en, this message translates to:
  /// **'Minimalist Analog Watch'**
  String get homeCupertinoOrder2Product;

  /// No description provided for @homeCupertinoOrder2Origin.
  ///
  /// In en, this message translates to:
  /// **'Imported from eBay'**
  String get homeCupertinoOrder2Origin;

  /// No description provided for @homeCupertinoOrder3Product.
  ///
  /// In en, this message translates to:
  /// **'Wireless Noise Cancelling Headset'**
  String get homeCupertinoOrder3Product;

  /// No description provided for @homeCupertinoOrder3Origin.
  ///
  /// In en, this message translates to:
  /// **'Imported from BestBuy'**
  String get homeCupertinoOrder3Origin;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Anais Fourati'**
  String get profileName;

  /// No description provided for @profileMembershipLevel.
  ///
  /// In en, this message translates to:
  /// **'Gold Member'**
  String get profileMembershipLevel;

  /// No description provided for @profileAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountSection;

  /// No description provided for @profileMyAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get profileMyAddresses;

  /// No description provided for @profileMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get profileMyOrders;

  /// No description provided for @profilePersonalDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get profilePersonalDetailsSection;

  /// No description provided for @profilePersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get profilePersonalInformation;

  /// No description provided for @profilePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get profilePaymentMethods;

  /// No description provided for @profileGeneralSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get profileGeneralSection;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogOut;

  /// No description provided for @profileMenuSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get profileMenuSemanticLabel;

  /// No description provided for @profileSettingsSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get profileSettingsSemanticLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
