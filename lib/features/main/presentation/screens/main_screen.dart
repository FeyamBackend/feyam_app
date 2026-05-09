import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/features/home/presentation/screens/home_screen.dart';
import 'package:feyam/features/orders/presentation/screens/order_screen.dart';
import 'package:feyam/features/profile/presentation/screens/profile_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final useCupertino = AdaptivePlatform.isCupertino(context);
    final items = _bottomNavigationItems(useCupertino: useCupertino, l10n: l10n);
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
      title: useCupertino && _currentIndex == 0 ? null : currentLabel,
      body: _MainTabContent(currentIndex: _currentIndex),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  List<AdaptiveAppBottomNavigationItem> _bottomNavigationItems({
    required bool useCupertino,
    required AppLocalizations l10n,
  }) {
    if (useCupertino) {
      return <AdaptiveAppBottomNavigationItem>[
        AdaptiveAppBottomNavigationItem(
          icon: Icon(CupertinoIcons.house),
          activeIcon: Icon(CupertinoIcons.house_fill),
          label: l10n.navHome,
        ),
        AdaptiveAppBottomNavigationItem(
          icon: Icon(CupertinoIcons.cart),
          activeIcon: Icon(CupertinoIcons.cart_fill),
          label: l10n.navCart,
        ),
        AdaptiveAppBottomNavigationItem(
          icon: Icon(CupertinoIcons.square_list),
          activeIcon: Icon(CupertinoIcons.square_list_fill),
          label: l10n.navOrders,
        ),
        AdaptiveAppBottomNavigationItem(
          icon: Icon(CupertinoIcons.person),
          activeIcon: Icon(CupertinoIcons.person_fill),
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
        icon: Icon(Icons.shopping_bag_outlined),
        activeIcon: Icon(Icons.shopping_bag),
        label: l10n.navCart,
      ),
      AdaptiveAppBottomNavigationItem(
        icon: Icon(Icons.list_alt_outlined),
        activeIcon: Icon(Icons.list_outlined),
        label: l10n.navOrders,
      ),
      AdaptiveAppBottomNavigationItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: l10n.navProfile,
      ),
    ];
  }
}

class _MainTabContent extends StatelessWidget {
  const _MainTabContent({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = <Widget>[
      const HomeScreen(),
      Center(child: Text(l10n.navCart)),
      const OrderScreen(),
      const ProfileScreen(),
    ];

    return pages[currentIndex];
  }
}
