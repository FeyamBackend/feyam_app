import 'dart:async';

import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/push/local_notifications_service.dart';
import 'package:feyam/core/utils/product_url_detector.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/features/auth/presentation/screens/login_screen.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_event.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_state.dart';
import 'package:feyam/features/cart/presentation/screens/add_to_cart.dart';
import 'package:feyam/features/cart/presentation/screens/cart_screen.dart';
import 'package:feyam/features/home/presentation/screens/home_screen.dart';
import 'package:feyam/features/notifications/presentation/bloc/unread_count_bloc.dart';
import 'package:feyam/features/notifications/presentation/bloc/unread_count_event.dart';
import 'package:feyam/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:feyam/features/payments/presentation/screens/order_payment_screen.dart';
import 'package:feyam/features/payments/presentation/screens/price_adjustment_payment_screen.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_result_entity.dart';
import 'package:feyam/features/product_search/domain/failures/product_search_failure.dart';
import 'package:feyam/features/product_search/domain/usecases/lookup_product_by_url.dart';
import 'package:feyam/features/profile/presentation/screens/profile_screen.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:feyam/features/stores/presentation/screens/stores_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A product link received from the native share-intent handler, with the
/// title (if any) already separated from the URL. [priceAmount]/[imageUrl]
/// are only ever set after a successful lookup resolution — see
/// [mergeSharedLinkWithLookup].
class SharedProductLink {
  const SharedProductLink({
    required this.url,
    this.title,
    this.priceAmount,
    this.imageUrl,
  });

  final String url;
  final String? title;
  final double? priceAmount;
  final String? imageUrl;
}

/// Combines a native share payload with the outcome of resolving its URL
/// against the backend's product-lookup endpoint (same one the search box
/// uses for a pasted URL — see LookupProductByUrlUseCase). Resolved
/// title/price/image win when present; the shared URL is always kept as-is.
/// A null/empty [lookupResult] — the retailer isn't supported, the lookup
/// failed, or it was never attempted — falls back to [link] unchanged, i.e.
/// today's manual-entry behavior.
SharedProductLink mergeSharedLinkWithLookup(
  SharedProductLink link,
  ProductSearchResultEntity? lookupResult,
) {
  final items = lookupResult?.items;
  if (items == null || items.isEmpty) return link;

  final resolved = items.first;
  return SharedProductLink(
    url: link.url,
    title: resolved.title,
    priceAmount: resolved.price,
    imageUrl: resolved.imageUrl,
  );
}

/// Parses the payload emitted by the native `.../share` EventChannel.
///
/// The native side (see `MainActivity.extractSharedContent`) sends a
/// `{"url": ..., "title": ...}` map with the URL already separated from any
/// surrounding text (e.g. "Product name https://a.co/xyz"). A bare `String`
/// is accepted as a legacy fallback and is treated as the URL verbatim.
SharedProductLink? parseSharedProductEvent(dynamic share) {
  if (share is Map) {
    final url = share['url'] as String?;
    if (url == null || url.isEmpty) return null;
    final title = share['title'] as String?;
    return SharedProductLink(
      url: url,
      title: (title != null && title.isNotEmpty) ? title : null,
    );
  }
  if (share is String && share.isNotEmpty) {
    return SharedProductLink(url: share);
  }
  return null;
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _shareChannel = EventChannel('com.feyamuniversellc.feyam/share');

  var _currentIndex = 0;
  late final StreamSubscription<dynamic> _sharingSubscription;
  late final UnreadCountBloc _unreadCountBloc;
  late final CartBloc _cartBloc;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _openedAppMessageSubscription;

  @override
  void initState() {
    super.initState();
    _sharingSubscription = _shareChannel.receiveBroadcastStream().listen(
      _onSharedUrl,
    );

    _unreadCountBloc = sl<UnreadCountBloc>()
      ..add(const UnreadCountRefreshRequested());
    _cartBloc = sl<CartBloc>()..add(const CartLoadRequested());
    _setUpPushListeners();
  }

  void _setUpPushListeners() {
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((
      message,
    ) {
      unawaited(
        sl<LocalNotificationsService>().showForegroundNotification(message),
      );
      _unreadCountBloc.add(const UnreadCountIncremented());
    });

    _openedAppMessageSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _openFromPush,
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _openFromPush(message);
    });
  }

  /// Opens the notification history, unless the push carries a "PriceAdjustment" or
  /// "OrderPriceConfirmed" deep link (see PushDispatcherBackgroundService's data payload on the
  /// backend), in which case it opens the relevant payment screen directly with the id it needs.
  void _openFromPush(RemoteMessage message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final relatedEntityType = message.data['relatedEntityType'] as String?;
      final relatedEntityId = message.data['relatedEntityId'] as String?;

      if (relatedEntityType == 'PriceAdjustment' && relatedEntityId != null) {
        Navigator.of(context).push(
          AdaptivePlatform.pageRoute<void>(
            context: context,
            builder: (_) =>
                PriceAdjustmentPaymentScreen(purchaseId: relatedEntityId),
          ),
        );
        return;
      }

      if (relatedEntityType == 'OrderPriceConfirmed' &&
          relatedEntityId != null) {
        Navigator.of(context).push(
          AdaptivePlatform.pageRoute<void>(
            context: context,
            builder: (_) => OrderPaymentScreen(orderId: relatedEntityId),
          ),
        );
        return;
      }

      Navigator.of(context).push(
        AdaptivePlatform.pageRoute<void>(
          context: context,
          builder: (_) => const NotificationsScreen(),
        ),
      );
    });
  }

  void _onSharedUrl(dynamic share) {
    final link = parseSharedProductEvent(share);
    if (link != null) {
      unawaited(
        _resolveAndOpenSharedLink(
          SharedProductLink(
            url: stripUrlQueryParams(link.url),
            title: link.title,
          ),
        ),
      );
    }
  }

  /// Resolves the shared URL against the same backend lookup the search box
  /// uses for a pasted URL, then opens Add to Cart prefilled with whatever
  /// it found. A brief blocking spinner covers the network round-trip, since
  /// there's no results list to show progress in here (unlike the search
  /// screen) — any failure/unsupported-retailer outcome degrades to today's
  /// unresolved manual-entry flow rather than surfacing an error.
  Future<void> _resolveAndOpenSharedLink(SharedProductLink link) async {
    if (!looksLikeProductUrl(link.url)) {
      _openAddToCart(link);
      return;
    }

    if (!mounted) return;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _ResolvingSharedLinkDialog(),
      ),
    );

    ProductSearchResultEntity? lookupResult;
    try {
      lookupResult = await sl<LookupProductByUrlUseCase>()(url: link.url);
    } on ProductSearchFailure {
      lookupResult = null;
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    final lookupSucceeded = lookupResult?.items.isNotEmpty ?? false;
    _openAddToCart(
      mergeSharedLinkWithLookup(link, lookupResult),
      showLookupFailedNotice: !lookupSucceeded,
    );
  }

  void _openAddToCart(
    SharedProductLink link, {
    bool showLookupFailedNotice = false,
  }) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        AdaptivePlatform.pageRoute<void>(
          context: context,
          builder: (_) => AddToCartScreen(
            initialUrl: link.url,
            initialProductName: link.title,
            initialPriceAmount: link.priceAmount,
            initialImageUrl: link.imageUrl,
            showLookupFailedNotice: showLookupFailedNotice,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _sharingSubscription.cancel();
    _foregroundMessageSubscription?.cancel();
    _openedAppMessageSubscription?.cancel();
    _unreadCountBloc.close();
    _cartBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final useCupertino = AdaptivePlatform.isCupertino(context);

    return BlocProvider<CartBloc>.value(
      value: _cartBloc,
      child: BlocProvider<UnreadCountBloc>.value(
        value: _unreadCountBloc,
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == AuthStatus.initial,
          listener: (context, state) {
            Navigator.of(context).pushAndRemoveUntil(
              AdaptivePlatform.pageRoute<void>(
                context: context,
                builder: (_) => const LoginScreen(),
              ),
              (_) => false,
            );
          },
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              final items = _bottomNavigationItems(
                useCupertino: useCupertino,
                l10n: l10n,
                cartItemCount: cartState.cart?.items.length ?? 0,
              );
              final currentLabel = items[_currentIndex].label;
              final bottomNavigationBar = AdaptiveAppBottomNavigationBar(
                currentIndex: _currentIndex,
                items: items,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              );

              return AdaptiveAppScaffold(
                title:
                    _currentIndex == 0 ||
                        _currentIndex == 1 ||
                        _currentIndex == 2 ||
                        _currentIndex == 3
                    ? null
                    : currentLabel,
                body: _MainTabContent(currentIndex: _currentIndex),
                bottomNavigationBar: bottomNavigationBar,
              );
            },
          ),
        ),
      ),
    );
  }

  List<AdaptiveAppBottomNavigationItem> _bottomNavigationItems({
    required bool useCupertino,
    required AppLocalizations l10n,
    required int cartItemCount,
  }) {
    if (useCupertino) {
      return <AdaptiveAppBottomNavigationItem>[
        AdaptiveAppBottomNavigationItem(
          icon: const Icon(CupertinoIcons.house),
          activeIcon: const Icon(CupertinoIcons.house_fill),
          label: l10n.navHome,
        ),
        AdaptiveAppBottomNavigationItem(
          icon: const Icon(CupertinoIcons.bag),
          activeIcon: const Icon(CupertinoIcons.bag_fill),
          label: l10n.navStores,
        ),
        AdaptiveAppBottomNavigationItem(
          icon: _CartNavIcon(
            count: cartItemCount,
            icon: const Icon(CupertinoIcons.cart),
          ),
          activeIcon: _CartNavIcon(
            count: cartItemCount,
            icon: const Icon(CupertinoIcons.cart_fill),
          ),
          label: l10n.navCart,
        ),
        AdaptiveAppBottomNavigationItem(
          icon: const Icon(CupertinoIcons.person),
          activeIcon: const Icon(CupertinoIcons.person_fill),
          label: l10n.navProfile,
        ),
      ];
    }

    return <AdaptiveAppBottomNavigationItem>[
      AdaptiveAppBottomNavigationItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: l10n.navHome,
      ),
      AdaptiveAppBottomNavigationItem(
        icon: Icon(Icons.storefront_outlined),
        activeIcon: Icon(Icons.storefront),
        label: l10n.navStores,
      ),
      AdaptiveAppBottomNavigationItem(
        icon: _CartNavIcon(
          count: cartItemCount,
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
        activeIcon: _CartNavIcon(
          count: cartItemCount,
          icon: const Icon(Icons.shopping_cart),
        ),
        label: l10n.navCart,
      ),
      AdaptiveAppBottomNavigationItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: l10n.navProfile,
      ),
    ];
  }
}

class _CartNavIcon extends StatelessWidget {
  const _CartNavIcon({required this.count, required this.icon});

  final int count;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Badge.count(
      count: count,
      isLabelVisible: count > 0,
      backgroundColor: const Color(0xFF4CAF50),
      child: icon,
    );
  }
}

class _ResolvingSharedLinkDialog extends StatelessWidget {
  const _ResolvingSharedLinkDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
        const SizedBox(width: 16),
        Flexible(child: Text(l10n.sharedLinkResolving)),
      ],
    );

    return PopScope(
      canPop: false,
      child: AdaptivePlatform.isCupertino(context)
          ? CupertinoAlertDialog(
              content: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: content,
              ),
            )
          : Dialog(
              child: Padding(padding: const EdgeInsets.all(24), child: content),
            ),
    );
  }
}

class _MainTabContent extends StatelessWidget {
  const _MainTabContent({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      BlocProvider<StoresBloc>(
        create: (_) => sl<StoresBloc>(),
        child: const StoresScreen(),
      ),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return pages[currentIndex];
  }
}
