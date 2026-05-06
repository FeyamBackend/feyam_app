import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/features/cart/presentation/screens/add_to_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                child: _HomeTabContent(currentIndex: _currentIndex),
              ),
            ),
            bottomNavigationBar,
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(currentLabel)),
      body: _HomeTabContent(currentIndex: _currentIndex),
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

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (currentIndex != 0) {
      const labels = <String>['Home', 'Cart', 'Profile'];

      return Center(child: Text(labels[currentIndex]));
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return Center(
        child: CupertinoButton.filled(
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute<void>(builder: (_) => const AddToCartScreen()),
            );
          },
          child: const Text('Ver solicitar pedido'),
        ),
      );
    }

    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AddToCartScreen()),
          );
        },
        child: const Text('Ver solicitar pedido'),
      ),
    );
  }
}
