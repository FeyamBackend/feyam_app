import 'dart:async';

import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/push/local_notifications_service.dart';
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
import 'package:feyam/features/payments/presentation/screens/price_adjustment_payment_screen.dart';
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
/// title (if any) already separated from the URL.
class SharedProductLink {
  const SharedProductLink({required this.url, this.title});

  final String url;
  final String? title;
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

  /// Opens the notification history, unless the push carries a "PriceAdjustment" deep link
  /// (see PushDispatcherBackgroundService's data payload on the backend), in which case it
  /// opens the payment screen directly with the PurchaseId it needs.
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
      _openAddToCart(link.url, title: link.title);
    }
  }

  void _openAddToCart(String url, {String? title}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        AdaptivePlatform.pageRoute<void>(
          context: context,
          builder: (_) =>
              AddToCartScreen(initialUrl: url, initialProductName: title),
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
