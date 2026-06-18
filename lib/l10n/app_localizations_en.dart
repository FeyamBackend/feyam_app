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

  @override
  String get navHome => 'Home';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navHelp => 'Help';

  @override
  String get navProfile => 'Profile';

  @override
  String get addToCartTitle => 'Add to cart';

  @override
  String get addToCartPlaceholder => 'Coming soon';

  @override
  String get addToCartSectionLabel => 'PRODUCT DETAILS';

  @override
  String get addToCartProductLinkLabel => 'Product Link';

  @override
  String get addToCartPriceLabel => 'Price (USD)';

  @override
  String get addToCartQuantityLabel => 'Quantity';

  @override
  String get addToCartVariantsLabel => 'Variants (Color/Size)';

  @override
  String get addToCartVariantsPlaceholder => 'e.g. Silver, Large';

  @override
  String get addToCartProductNameLabel => 'Product name';

  @override
  String get addToCartProductNamePlaceholder => 'As shown in the store';

  @override
  String get addToCartErrorNetwork =>
      'No internet connection. Check your connection and try again.';

  @override
  String get addToCartErrorUnauthorized =>
      'Session expired. Please sign in again.';

  @override
  String get addToCartErrorServer => 'Server error. Please try again later.';

  @override
  String get addToCartErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get addToCartButton => 'Add to cart';

  @override
  String get homeImportOrderTitle => 'Import Order';

  @override
  String get homePasteProductLink => 'Paste product link';

  @override
  String get homeImportButton => 'Import';

  @override
  String get homeImportProductTitle => 'Import Product';

  @override
  String get homePasteProductExample => 'https://example.com/product/123';

  @override
  String get homeAddToCartButton => 'Add to cart';

  @override
  String get homePopularStoresTitle => 'Popular stores';

  @override
  String get homePopularStoresTitleMaterial => 'Popular Stores';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeRecentOrdersTitle => 'Recent orders';

  @override
  String get homeRecentOrdersTitleMaterial => 'Recent Orders';

  @override
  String get homeStatusInTransit => 'In Transit';

  @override
  String get homeStatusDelivered => 'Delivered';

  @override
  String get homeGreetingPrefix => 'Hi,';

  @override
  String get homePasteLinkHint => 'Paste the product link…';

  @override
  String get homeMisOrders => 'My orders';

  @override
  String get homeEstimatedPrice => 'Estimated price to pay';

  @override
  String get homeSupportedStores => 'Supported stores';

  @override
  String get homeStoresSubtitle => 'Amazon, eBay, Walmart and more';

  @override
  String get homeCupertinoOrder1Product => 'Premium Sneakers Red Edition';

  @override
  String get homeCupertinoOrder1Origin => 'Imported from Amazon USA';

  @override
  String get homeCupertinoOrder2Product => 'Minimalist Analog Watch';

  @override
  String get homeCupertinoOrder2Origin => 'Imported from eBay';

  @override
  String get homeCupertinoOrder3Product => 'Wireless Noise Cancelling Headset';

  @override
  String get homeCupertinoOrder3Origin => 'Imported from BestBuy';

  @override
  String get profileName => 'Anais Fourati';

  @override
  String get profileMembershipLevel => 'Gold Member';

  @override
  String get profileAccountSection => 'Account';

  @override
  String get profileMyAddresses => 'My Addresses';

  @override
  String get profileMyOrders => 'My Orders';

  @override
  String get profilePersonalDetailsSection => 'Personal Details';

  @override
  String get profilePersonalInformation => 'Personal information';

  @override
  String get profilePaymentMethods => 'Payment methods';

  @override
  String get profileGeneralSection => 'General';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileLogOut => 'Log out';

  @override
  String get profileMenuSemanticLabel => 'Open menu';

  @override
  String get profileSettingsSemanticLabel => 'Open settings';

  @override
  String get cartItemChronographName => 'Premium Chronograph';

  @override
  String get cartItemAeroName => 'Aero Performance Pro';

  @override
  String get cartItemSonicName => 'Sonic Bliss Wireless';

  @override
  String get cartSummaryTitle => 'Summary';

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get cartShipping => 'Shipping';

  @override
  String get cartTaxes => 'Taxes (10%)';

  @override
  String get cartTotal => 'Total';

  @override
  String get cartCheckoutButton => 'Continue to Checkout';

  @override
  String get cartSecurePayment => '100% Secure Payment';

  @override
  String get cartSearchSemanticLabel => 'Search cart';

  @override
  String get cartRemoveItemSemanticLabel => 'Remove item';

  @override
  String get cartTitle => 'Your Cart';

  @override
  String get cartEstimatedShipping => 'Estimated Shipping';

  @override
  String get cartCheckoutMaterialButton => 'Continue to Checkout';

  @override
  String get cartMaterialFootnote =>
      'Tax calculated at checkout. Secure SSL encrypted payment processing.';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptySubtitle =>
      'Paste a product link to start building your order.';

  @override
  String get cartEmptyAction => 'Paste a link';

  @override
  String get cartErrorTitle => 'Error loading cart';

  @override
  String get cartErrorSubtitle => 'Check your connection and try again.';

  @override
  String get cartErrorRetry => 'Retry';

  @override
  String get ordersHistoryTitle => 'Orders';

  @override
  String get ordersFilterSemanticLabel => 'Filter orders';

  @override
  String get ordersTabAll => 'All';

  @override
  String get ordersTabActive => 'Active';

  @override
  String get ordersTabDelivered => 'Delivered';

  @override
  String get ordersStatusEnRevision => 'Under review';

  @override
  String get ordersStatusPorPagar => 'To pay';

  @override
  String get ordersStatusEnCamino => 'On the way';

  @override
  String get ordersStatusEntregado => 'Delivered';

  @override
  String get ordersStatusAwaitingApproval => 'AWAITING_APPROVAL';

  @override
  String get ordersStatusPendingVerification => 'PENDING_VERIFICATION';

  @override
  String get ordersStatusCompleted => 'COMPLETED';

  @override
  String get ordersOrder1Date => 'Oct 24, 2023 •';

  @override
  String get ordersOrder1Time => '10:45 AM';

  @override
  String get ordersOrder1Items => '3 Items';

  @override
  String get ordersOrder2Date => 'Oct 22, 2023 •';

  @override
  String get ordersOrder2Time => '02:15 PM';

  @override
  String get ordersOrder2Items => '1 Item';

  @override
  String get ordersOrder3Date => 'Oct 18, 2023 • 09:30 AM';

  @override
  String get ordersOrder3Items => '5 Items';

  @override
  String get ordersOrder4Date => 'Oct 10, 2023 • 11:20 AM';

  @override
  String get ordersOrder4Items => '2 Items';

  @override
  String get ordersSearchPlaceholder => 'Search orders';

  @override
  String get ordersStatusEstimated => 'ESTIMATED';

  @override
  String get ordersStatusConfirmed => 'CONFIRMED';

  @override
  String get ordersStatusNeedsAdjustment => 'NEEDS_ADJUSTMENT';

  @override
  String get ordersStatusAwaitingCustomerApproval =>
      'AWAITING_CUSTOMER_APPROVAL';

  @override
  String get ordersCupertinoOrder1DateTime => 'Oct 24, 2023 • 14:30';

  @override
  String get ordersCupertinoOrder1Items => '3 Items';

  @override
  String get ordersCupertinoOrder2DateTime => 'Oct 22, 2023 • 09:15';

  @override
  String get ordersCupertinoOrder2Items => '1 Item';

  @override
  String get ordersCupertinoOrder3DateTime => 'Oct 20, 2023 • 18:45';

  @override
  String get ordersCupertinoOrder3Items => '5 Items';

  @override
  String get ordersCupertinoOrder4DateTime => 'Oct 19, 2023 • 11:05';

  @override
  String get ordersCupertinoOrder4Items => '2 Items';

  @override
  String get ordersCupertinoOrder5DateTime => 'Oct 15, 2023 • 16:20';

  @override
  String get ordersCupertinoOrder5Items => '4 Items';

  @override
  String get helpSupportTitle => 'Need help?';

  @override
  String get helpSupportSubtitle => 'Message us — a real person will respond.';

  @override
  String get helpChat => 'Chat';

  @override
  String get helpFaqsTitle => 'Frequently asked questions';

  @override
  String get helpFaq1Question => 'How do I add a product?';

  @override
  String get helpFaq1Answer =>
      'Paste the link from any store or use the \"Share\" button in your browser.';

  @override
  String get helpFaq2Question => 'When do I pay for my order?';

  @override
  String get helpFaq2Answer =>
      'When it moves to \"To pay\" status, we\'ll notify you with the final price.';

  @override
  String get helpFaq3Question => 'How long does shipping take?';

  @override
  String get helpFaq3Answer =>
      'Time depends on the store and customs; you can see it on each order.';

  @override
  String get helpFaq4Question => 'Which stores can I use?';

  @override
  String get helpFaq4Answer =>
      'Amazon, eBay, Walmart, Best Buy and more. Check \"Supported stores\".';

  @override
  String get profileEmail => 'maria@feyam.com';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeViewAllStores => 'View all stores';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifEmpty => 'No notifications';

  @override
  String get notifEmptyBody =>
      'When there are updates on your orders, you\'ll see them here.';

  @override
  String get ordDetailId => 'Order number';

  @override
  String get ordDetailDate => 'Order date';

  @override
  String get ordDetailEstDelivery => 'Estimated delivery';

  @override
  String get ordDetailTracking => 'Tracking';

  @override
  String get ordDetailCurrentStatus => 'Current status of your order';

  @override
  String get storesTitle => 'Supported stores';

  @override
  String get storesHint =>
      'Tap a store to open it in your browser. Copy the product link and paste it in Feyam.';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutAddress => 'Shipping address';

  @override
  String get checkoutSummary => 'Order summary';

  @override
  String get checkoutPayMethod => 'Payment';

  @override
  String get checkoutPayInfo =>
      'We\'ll contact you to coordinate payment once we review your order.';

  @override
  String get checkoutEstPrice => 'Estimated price';

  @override
  String get checkoutSubtotal => 'Product subtotal';

  @override
  String get checkoutService => 'Feyam service (12%)';

  @override
  String get checkoutShipping => 'International shipping';

  @override
  String get checkoutTotal => 'Estimated total';

  @override
  String get checkoutChange => 'Change';

  @override
  String get checkoutDelivery => 'Estimated delivery';

  @override
  String get checkoutDeliveryTime => '10–18 business days';

  @override
  String get checkoutDisclaimer =>
      'Final price may vary based on customs duties and exchange rates.';

  @override
  String get checkoutConfirm => 'Confirm order';

  @override
  String get successTitle => 'Order confirmed!';

  @override
  String get successBody =>
      'We\'re reviewing your order. We\'ll notify you when it\'s ready to pay.';

  @override
  String get successViewOrders => 'View my orders';

  @override
  String get addressesTitle => 'My addresses';

  @override
  String get addressAdd => 'Add address';

  @override
  String get addressEdit => 'Edit address';

  @override
  String get addressLabelField => 'Label (Home, Office…)';

  @override
  String get addressStreet => 'Address';

  @override
  String get addressCity => 'City';

  @override
  String get addressSave => 'Save';

  @override
  String get addressCancel => 'Cancel';

  @override
  String get addressDelete => 'Delete';

  @override
  String get addressRequired => 'Required';

  @override
  String get addressNoneTitle => 'No saved addresses';

  @override
  String get addressNoneBody => 'Add an address to speed up your orders.';

  @override
  String get addressDefault => 'Default';

  @override
  String get paymentTitle => 'Payment methods';

  @override
  String get paymentInfo =>
      'We\'ll contact you to coordinate payment once we review your order.';

  @override
  String get paymentAdd => 'Add method';

  @override
  String get paymentEdit => 'Edit method';

  @override
  String get paymentLabelField => 'Name (Bancolombia, Nequi…)';

  @override
  String get paymentDetailField => 'Number or alias';

  @override
  String get paymentRequired => 'Required';

  @override
  String get paymentNoneTitle => 'No saved methods';

  @override
  String get paymentNoneBody =>
      'Save a payment method to speed up your orders.';

  @override
  String get paymentDefault => 'Primary';

  @override
  String get paymentTypeNequi => 'Nequi';

  @override
  String get paymentTypeBank => 'Bank transfer';

  @override
  String get paymentTypeEfecty => 'Efecty';

  @override
  String get paymentTypeCard => 'Card';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get termsUpdated =>
      'Last updated: May 3, 2026 · Effective: May 20, 2026';

  @override
  String get termsIntro =>
      'These Terms and Conditions govern access to and use of Feyam, an assisted purchasing and international logistics platform operated by FEYAM UNIVERSE LLC (Florida, USA). By using the Platform, you agree to be legally bound by these Terms.';

  @override
  String get termsAccept =>
      'I have read and accept Feyam\'s Terms and Conditions';

  @override
  String get termsContinue => 'Accept and continue';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get logoutTitle => 'Sign out?';

  @override
  String get logoutBody =>
      'You will be signed out of your Feyam account on this device.';
}
