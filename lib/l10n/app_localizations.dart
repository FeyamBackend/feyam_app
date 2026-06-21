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

  /// No description provided for @navHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get navHelp;

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

  /// No description provided for @addToCartSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT DETAILS'**
  String get addToCartSectionLabel;

  /// No description provided for @addToCartProductLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Link'**
  String get addToCartProductLinkLabel;

  /// No description provided for @addToCartPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (USD)'**
  String get addToCartPriceLabel;

  /// No description provided for @addToCartQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get addToCartQuantityLabel;

  /// No description provided for @addToCartVariantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Variants (Color/Size)'**
  String get addToCartVariantsLabel;

  /// No description provided for @addToCartVariantsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Silver, Large'**
  String get addToCartVariantsPlaceholder;

  /// No description provided for @addToCartProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get addToCartProductNameLabel;

  /// No description provided for @addToCartProductNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'As shown in the store'**
  String get addToCartProductNamePlaceholder;

  /// No description provided for @addToCartErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get addToCartErrorNetwork;

  /// No description provided for @addToCartErrorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get addToCartErrorUnauthorized;

  /// No description provided for @addToCartErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get addToCartErrorServer;

  /// No description provided for @addToCartErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get addToCartErrorUnknown;

  /// No description provided for @addToCartButton.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCartButton;

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

  /// No description provided for @homeGreetingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Hi,'**
  String get homeGreetingPrefix;

  /// No description provided for @homePasteLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the product link…'**
  String get homePasteLinkHint;

  /// No description provided for @homeMisOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get homeMisOrders;

  /// No description provided for @homeEstimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated price to pay'**
  String get homeEstimatedPrice;

  /// No description provided for @homeSupportedStores.
  ///
  /// In en, this message translates to:
  /// **'Supported stores'**
  String get homeSupportedStores;

  /// No description provided for @homeStoresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Amazon, eBay, Walmart and more'**
  String get homeStoresSubtitle;

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

  /// No description provided for @cartItemChronographName.
  ///
  /// In en, this message translates to:
  /// **'Premium Chronograph'**
  String get cartItemChronographName;

  /// No description provided for @cartItemAeroName.
  ///
  /// In en, this message translates to:
  /// **'Aero Performance Pro'**
  String get cartItemAeroName;

  /// No description provided for @cartItemSonicName.
  ///
  /// In en, this message translates to:
  /// **'Sonic Bliss Wireless'**
  String get cartItemSonicName;

  /// No description provided for @cartSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get cartSummaryTitle;

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get cartShipping;

  /// No description provided for @cartTaxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes (10%)'**
  String get cartTaxes;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @cartCheckoutButton.
  ///
  /// In en, this message translates to:
  /// **'Continue to Checkout'**
  String get cartCheckoutButton;

  /// No description provided for @cartSecurePayment.
  ///
  /// In en, this message translates to:
  /// **'100% Secure Payment'**
  String get cartSecurePayment;

  /// No description provided for @cartSearchSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Search cart'**
  String get cartSearchSemanticLabel;

  /// No description provided for @cartRemoveItemSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get cartRemoveItemSemanticLabel;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Cart'**
  String get cartTitle;

  /// No description provided for @cartEstimatedShipping.
  ///
  /// In en, this message translates to:
  /// **'Estimated Shipping'**
  String get cartEstimatedShipping;

  /// No description provided for @cartCheckoutMaterialButton.
  ///
  /// In en, this message translates to:
  /// **'Continue to Checkout'**
  String get cartCheckoutMaterialButton;

  /// No description provided for @cartMaterialFootnote.
  ///
  /// In en, this message translates to:
  /// **'Tax calculated at checkout. Secure SSL encrypted payment processing.'**
  String get cartMaterialFootnote;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste a product link to start building your order.'**
  String get cartEmptySubtitle;

  /// No description provided for @cartEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Paste a link'**
  String get cartEmptyAction;

  /// No description provided for @cartErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error loading cart'**
  String get cartErrorTitle;

  /// No description provided for @cartErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get cartErrorSubtitle;

  /// No description provided for @cartErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get cartErrorRetry;

  /// No description provided for @ordersHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersHistoryTitle;

  /// No description provided for @ordersFilterSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter orders'**
  String get ordersFilterSemanticLabel;

  /// No description provided for @ordersTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ordersTabAll;

  /// No description provided for @ordersTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ordersTabActive;

  /// No description provided for @ordersTabDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ordersTabDelivered;

  /// No description provided for @ordersLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your orders.'**
  String get ordersLoadError;

  /// No description provided for @ordersRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get ordersRetry;

  /// No description provided for @ordersOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get ordersOrderLabel;

  /// No description provided for @ordersStatusEnRevision.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get ordersStatusEnRevision;

  /// No description provided for @ordersStatusPorPagar.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get ordersStatusPorPagar;

  /// No description provided for @ordersStatusEnCamino.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get ordersStatusEnCamino;

  /// No description provided for @ordersStatusEntregado.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ordersStatusEntregado;

  /// No description provided for @ordersStatusAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'AWAITING_APPROVAL'**
  String get ordersStatusAwaitingApproval;

  /// No description provided for @ordersStatusPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'PENDING_VERIFICATION'**
  String get ordersStatusPendingVerification;

  /// No description provided for @ordersStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get ordersStatusCompleted;

  /// No description provided for @ordersOrder1Date.
  ///
  /// In en, this message translates to:
  /// **'Oct 24, 2023 •'**
  String get ordersOrder1Date;

  /// No description provided for @ordersOrder1Time.
  ///
  /// In en, this message translates to:
  /// **'10:45 AM'**
  String get ordersOrder1Time;

  /// No description provided for @ordersOrder1Items.
  ///
  /// In en, this message translates to:
  /// **'3 Items'**
  String get ordersOrder1Items;

  /// No description provided for @ordersOrder2Date.
  ///
  /// In en, this message translates to:
  /// **'Oct 22, 2023 •'**
  String get ordersOrder2Date;

  /// No description provided for @ordersOrder2Time.
  ///
  /// In en, this message translates to:
  /// **'02:15 PM'**
  String get ordersOrder2Time;

  /// No description provided for @ordersOrder2Items.
  ///
  /// In en, this message translates to:
  /// **'1 Item'**
  String get ordersOrder2Items;

  /// No description provided for @ordersOrder3Date.
  ///
  /// In en, this message translates to:
  /// **'Oct 18, 2023 • 09:30 AM'**
  String get ordersOrder3Date;

  /// No description provided for @ordersOrder3Items.
  ///
  /// In en, this message translates to:
  /// **'5 Items'**
  String get ordersOrder3Items;

  /// No description provided for @ordersOrder4Date.
  ///
  /// In en, this message translates to:
  /// **'Oct 10, 2023 • 11:20 AM'**
  String get ordersOrder4Date;

  /// No description provided for @ordersOrder4Items.
  ///
  /// In en, this message translates to:
  /// **'2 Items'**
  String get ordersOrder4Items;

  /// No description provided for @ordersSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get ordersSearchPlaceholder;

  /// No description provided for @ordersStatusEstimated.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED'**
  String get ordersStatusEstimated;

  /// No description provided for @ordersStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED'**
  String get ordersStatusConfirmed;

  /// No description provided for @ordersStatusNeedsAdjustment.
  ///
  /// In en, this message translates to:
  /// **'NEEDS_ADJUSTMENT'**
  String get ordersStatusNeedsAdjustment;

  /// No description provided for @ordersStatusAwaitingCustomerApproval.
  ///
  /// In en, this message translates to:
  /// **'AWAITING_CUSTOMER_APPROVAL'**
  String get ordersStatusAwaitingCustomerApproval;

  /// No description provided for @ordersCupertinoOrder1DateTime.
  ///
  /// In en, this message translates to:
  /// **'Oct 24, 2023 • 14:30'**
  String get ordersCupertinoOrder1DateTime;

  /// No description provided for @ordersCupertinoOrder1Items.
  ///
  /// In en, this message translates to:
  /// **'3 Items'**
  String get ordersCupertinoOrder1Items;

  /// No description provided for @ordersCupertinoOrder2DateTime.
  ///
  /// In en, this message translates to:
  /// **'Oct 22, 2023 • 09:15'**
  String get ordersCupertinoOrder2DateTime;

  /// No description provided for @ordersCupertinoOrder2Items.
  ///
  /// In en, this message translates to:
  /// **'1 Item'**
  String get ordersCupertinoOrder2Items;

  /// No description provided for @ordersCupertinoOrder3DateTime.
  ///
  /// In en, this message translates to:
  /// **'Oct 20, 2023 • 18:45'**
  String get ordersCupertinoOrder3DateTime;

  /// No description provided for @ordersCupertinoOrder3Items.
  ///
  /// In en, this message translates to:
  /// **'5 Items'**
  String get ordersCupertinoOrder3Items;

  /// No description provided for @ordersCupertinoOrder4DateTime.
  ///
  /// In en, this message translates to:
  /// **'Oct 19, 2023 • 11:05'**
  String get ordersCupertinoOrder4DateTime;

  /// No description provided for @ordersCupertinoOrder4Items.
  ///
  /// In en, this message translates to:
  /// **'2 Items'**
  String get ordersCupertinoOrder4Items;

  /// No description provided for @ordersCupertinoOrder5DateTime.
  ///
  /// In en, this message translates to:
  /// **'Oct 15, 2023 • 16:20'**
  String get ordersCupertinoOrder5DateTime;

  /// No description provided for @ordersCupertinoOrder5Items.
  ///
  /// In en, this message translates to:
  /// **'4 Items'**
  String get ordersCupertinoOrder5Items;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Message us — a real person will respond.'**
  String get helpSupportSubtitle;

  /// No description provided for @helpChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get helpChat;

  /// No description provided for @helpFaqsTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpFaqsTitle;

  /// No description provided for @helpFaq1Question.
  ///
  /// In en, this message translates to:
  /// **'How do I add a product?'**
  String get helpFaq1Question;

  /// No description provided for @helpFaq1Answer.
  ///
  /// In en, this message translates to:
  /// **'Paste the link from any store or use the \"Share\" button in your browser.'**
  String get helpFaq1Answer;

  /// No description provided for @helpFaq2Question.
  ///
  /// In en, this message translates to:
  /// **'When do I pay for my order?'**
  String get helpFaq2Question;

  /// No description provided for @helpFaq2Answer.
  ///
  /// In en, this message translates to:
  /// **'When it moves to \"To pay\" status, we\'ll notify you with the final price.'**
  String get helpFaq2Answer;

  /// No description provided for @helpFaq3Question.
  ///
  /// In en, this message translates to:
  /// **'How long does shipping take?'**
  String get helpFaq3Question;

  /// No description provided for @helpFaq3Answer.
  ///
  /// In en, this message translates to:
  /// **'Time depends on the store and customs; you can see it on each order.'**
  String get helpFaq3Answer;

  /// No description provided for @helpFaq4Question.
  ///
  /// In en, this message translates to:
  /// **'Which stores can I use?'**
  String get helpFaq4Question;

  /// No description provided for @helpFaq4Answer.
  ///
  /// In en, this message translates to:
  /// **'Amazon, eBay, Walmart, Best Buy and more. Check \"Supported stores\".'**
  String get helpFaq4Answer;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'maria@feyam.com'**
  String get profileEmail;

  /// No description provided for @homeNoOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any orders yet.'**
  String get homeNoOrdersYet;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'When you make your first purchase, it\'ll show up here.'**
  String get ordersEmptySubtitle;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @homeViewAllStores.
  ///
  /// In en, this message translates to:
  /// **'View all stores'**
  String get homeViewAllStores;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notifEmpty;

  /// No description provided for @notifEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When there are updates on your orders, you\'ll see them here.'**
  String get notifEmptyBody;

  /// No description provided for @ordDetailId.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get ordDetailId;

  /// No description provided for @ordDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get ordDetailDate;

  /// No description provided for @ordDetailEstDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery'**
  String get ordDetailEstDelivery;

  /// No description provided for @ordDetailTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get ordDetailTracking;

  /// No description provided for @ordDetailCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current status of your order'**
  String get ordDetailCurrentStatus;

  /// No description provided for @storesTitle.
  ///
  /// In en, this message translates to:
  /// **'Supported stores'**
  String get storesTitle;

  /// No description provided for @storesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a store to open it in your browser. Copy the product link and paste it in Feyam.'**
  String get storesHint;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping address'**
  String get checkoutAddress;

  /// No description provided for @checkoutSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get checkoutSummary;

  /// No description provided for @checkoutPayMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get checkoutPayMethod;

  /// No description provided for @checkoutPayInfo.
  ///
  /// In en, this message translates to:
  /// **'We\'ll contact you to coordinate payment once we review your order.'**
  String get checkoutPayInfo;

  /// No description provided for @checkoutEstPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated price'**
  String get checkoutEstPrice;

  /// No description provided for @checkoutSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Product subtotal'**
  String get checkoutSubtotal;

  /// No description provided for @checkoutService.
  ///
  /// In en, this message translates to:
  /// **'Feyam service (12%)'**
  String get checkoutService;

  /// No description provided for @checkoutShipping.
  ///
  /// In en, this message translates to:
  /// **'International shipping'**
  String get checkoutShipping;

  /// No description provided for @checkoutTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get checkoutTotal;

  /// No description provided for @checkoutChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get checkoutChange;

  /// No description provided for @checkoutDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery'**
  String get checkoutDelivery;

  /// No description provided for @checkoutDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'10–18 business days'**
  String get checkoutDeliveryTime;

  /// No description provided for @checkoutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Final price may vary based on customs duties and exchange rates.'**
  String get checkoutDisclaimer;

  /// No description provided for @checkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get checkoutConfirm;

  /// No description provided for @checkoutPayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get checkoutPayButton;

  /// No description provided for @checkoutProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment…'**
  String get checkoutProcessing;

  /// No description provided for @checkoutVerifying.
  ///
  /// In en, this message translates to:
  /// **'Confirming your payment…'**
  String get checkoutVerifying;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'We received your payment. An operator is verifying your order and we\'ll notify you as soon as it moves forward.'**
  String get paymentSuccessBody;

  /// No description provided for @paymentPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment received!'**
  String get paymentPendingTitle;

  /// No description provided for @paymentPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your payment went through. Confirmation may take a few minutes; we\'ll notify you as soon as it clears and an operator reviews your order.'**
  String get paymentPendingBody;

  /// No description provided for @paymentErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t process your payment. Please try again.'**
  String get paymentErrorGeneric;

  /// No description provided for @paymentErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get paymentErrorNetwork;

  /// No description provided for @paymentErrorSession.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get paymentErrorSession;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled.'**
  String get paymentCancelled;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed!'**
  String get successTitle;

  /// No description provided for @successBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re reviewing your order. We\'ll notify you when it\'s ready to pay.'**
  String get successBody;

  /// No description provided for @successViewOrders.
  ///
  /// In en, this message translates to:
  /// **'View my orders'**
  String get successViewOrders;

  /// No description provided for @addressesTitle.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get addressesTitle;

  /// No description provided for @addressAdd.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addressAdd;

  /// No description provided for @addressEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get addressEdit;

  /// No description provided for @addressLabelField.
  ///
  /// In en, this message translates to:
  /// **'Label (Home, Office…)'**
  String get addressLabelField;

  /// No description provided for @addressStreet.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressStreet;

  /// No description provided for @addressCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get addressCity;

  /// No description provided for @addressSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addressSave;

  /// No description provided for @addressCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addressCancel;

  /// No description provided for @addressDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get addressDelete;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get addressRequired;

  /// No description provided for @addressNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses'**
  String get addressNoneTitle;

  /// No description provided for @addressNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Add an address to speed up your orders.'**
  String get addressNoneBody;

  /// No description provided for @addressDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get addressDefault;

  /// No description provided for @addressType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get addressType;

  /// No description provided for @addressTypeShipment.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get addressTypeShipment;

  /// No description provided for @addressTypeBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get addressTypeBilling;

  /// No description provided for @addressCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get addressCountry;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'Address line'**
  String get addressLine;

  /// No description provided for @addressLineAdd.
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get addressLineAdd;

  /// No description provided for @addressZip.
  ///
  /// In en, this message translates to:
  /// **'ZIP / postal code'**
  String get addressZip;

  /// No description provided for @addressRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get addressRecipient;

  /// No description provided for @addressInstructions.
  ///
  /// In en, this message translates to:
  /// **'Delivery instructions'**
  String get addressInstructions;

  /// No description provided for @addressSubdivision.
  ///
  /// In en, this message translates to:
  /// **'City / State'**
  String get addressSubdivision;

  /// No description provided for @addressCountryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Select a country'**
  String get addressCountryInvalid;

  /// No description provided for @addressLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your addresses.'**
  String get addressLoadError;

  /// No description provided for @addressSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save the address.'**
  String get addressSaveError;

  /// No description provided for @addressDeleteError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t delete the address.'**
  String get addressDeleteError;

  /// No description provided for @addressRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get addressRetry;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentTitle;

  /// No description provided for @paymentInfo.
  ///
  /// In en, this message translates to:
  /// **'We\'ll contact you to coordinate payment once we review your order.'**
  String get paymentInfo;

  /// No description provided for @paymentAdd.
  ///
  /// In en, this message translates to:
  /// **'Add method'**
  String get paymentAdd;

  /// No description provided for @paymentEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit method'**
  String get paymentEdit;

  /// No description provided for @paymentLabelField.
  ///
  /// In en, this message translates to:
  /// **'Name (Bancolombia, Nequi…)'**
  String get paymentLabelField;

  /// No description provided for @paymentDetailField.
  ///
  /// In en, this message translates to:
  /// **'Number or alias'**
  String get paymentDetailField;

  /// No description provided for @paymentRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get paymentRequired;

  /// No description provided for @paymentNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved methods'**
  String get paymentNoneTitle;

  /// No description provided for @paymentNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Save a payment method to speed up your orders.'**
  String get paymentNoneBody;

  /// No description provided for @paymentDefault.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get paymentDefault;

  /// No description provided for @paymentTypeNequi.
  ///
  /// In en, this message translates to:
  /// **'Nequi'**
  String get paymentTypeNequi;

  /// No description provided for @paymentTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentTypeBank;

  /// No description provided for @paymentTypeEfecty.
  ///
  /// In en, this message translates to:
  /// **'Efecty'**
  String get paymentTypeEfecty;

  /// No description provided for @paymentTypeCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentTypeCard;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsTitle;

  /// No description provided for @termsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: May 3, 2026 · Effective: May 20, 2026'**
  String get termsUpdated;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'These Terms and Conditions govern access to and use of Feyam, an assisted purchasing and international logistics platform operated by FEYAM UNIVERSE LLC (Florida, USA). By using the Platform, you agree to be legally bound by these Terms.'**
  String get termsIntro;

  /// No description provided for @termsAccept.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept Feyam\'s Terms and Conditions'**
  String get termsAccept;

  /// No description provided for @termsContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept and continue'**
  String get termsContinue;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out of your Feyam account on this device.'**
  String get logoutBody;
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
