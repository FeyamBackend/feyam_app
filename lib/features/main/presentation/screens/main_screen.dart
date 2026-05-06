import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
    final useCupertino = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final items = _bottomNavigationItems(useCupertino: useCupertino);
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

    if (useCupertino) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text(currentLabel)),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SafeArea(
                bottom: false,
                child: _MainTabContent(currentIndex: _currentIndex),
              ),
            ),
            bottomNavigationBar,
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(currentLabel)),
      body: _MainTabContent(currentIndex: _currentIndex),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  List<AdaptiveAppBottomNavigationItem> _bottomNavigationItems({
    required bool useCupertino,
  }) {
    if (useCupertino) {
      return const <AdaptiveAppBottomNavigationItem>[
        AdaptiveAppBottomNavigationItem(
          icon: Icon(CupertinoIcons.house),
          activeIcon: Icon(CupertinoIcons.house_fill),
          label: 'Home',
        ),
        AdaptiveAppBottomNavigationItem(
          icon: Icon(CupertinoIcons.cart),
          activeIcon: Icon(CupertinoIcons.cart_fill),
          label: 'Cart',
        ),
        AdaptiveAppBottomNavigationItem(
          icon: Icon(CupertinoIcons.person),
          activeIcon: Icon(CupertinoIcons.person_fill),
          label: 'Profile',
        ),
      ];
    }

    return const <AdaptiveAppBottomNavigationItem>[
      AdaptiveAppBottomNavigationItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      AdaptiveAppBottomNavigationItem(
        icon: Icon(Icons.shopping_bag_outlined),
        activeIcon: Icon(Icons.shopping_bag),
        label: 'Cart',
      ),
      AdaptiveAppBottomNavigationItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }
}

class _MainTabContent extends StatelessWidget {
  const _MainTabContent({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    const pages = <Widget>[
      HomeScreen(),
      Center(child: Text('Cart')),
      Center(child: Text('Profile')),
    ];

    return pages[currentIndex];
  }
}
