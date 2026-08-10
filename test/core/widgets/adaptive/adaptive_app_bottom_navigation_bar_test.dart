import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a CupertinoTabBar on iOS', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Scaffold(
          bottomNavigationBar: AdaptiveAppBottomNavigationBar(
            currentIndex: 1,
            items: _cupertinoItems,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoTabBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    final tabBar = tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar));
    expect(tabBar.currentIndex, 1);
  });

  testWidgets('renders a flat Material bar with a green selected item off iOS', (
    tester,
  ) async {
    const selectedColor = Color(0xFF0058BC);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Scaffold(
          bottomNavigationBar: AdaptiveAppBottomNavigationBar(
            currentIndex: 2,
            items: _materialItems,
            selectedItemColor: selectedColor,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(CupertinoTabBar), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    final selectedLabel = tester.widget<Text>(find.text('Profile'));
    expect(selectedLabel.style?.color, selectedColor);

    final unselectedLabel = tester.widget<Text>(find.text('Home'));
    expect(unselectedLabel.style?.color, isNot(selectedColor));
  });

  testWidgets('emits the tapped destination index on Material', (tester) async {
    var selectedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Scaffold(
          bottomNavigationBar: AdaptiveAppBottomNavigationBar(
            currentIndex: 0,
            items: _materialItems,
            onDestinationSelected: (index) {
              selectedIndex = index;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Profile'));

    expect(selectedIndex, 2);
  });

  testWidgets('emits the tapped destination index on Cupertino', (
    tester,
  ) async {
    var selectedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Scaffold(
          bottomNavigationBar: AdaptiveAppBottomNavigationBar(
            currentIndex: 0,
            items: _cupertinoItems,
            onDestinationSelected: (index) {
              selectedIndex = index;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Cart'));

    expect(selectedIndex, 1);
  });
}

const _cupertinoItems = <AdaptiveAppBottomNavigationItem>[
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

const _materialItems = <AdaptiveAppBottomNavigationItem>[
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
