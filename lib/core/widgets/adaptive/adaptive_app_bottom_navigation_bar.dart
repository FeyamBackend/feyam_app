import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveAppBottomNavigationItem {
  const AdaptiveAppBottomNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final Widget icon;
  final Widget activeIcon;
  final String label;
}

class AdaptiveAppBottomNavigationBar extends StatelessWidget {
  const AdaptiveAppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onDestinationSelected,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  final int currentIndex;
  final List<AdaptiveAppBottomNavigationItem> items;
  final ValueChanged<int> onDestinationSelected;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (!kIsWeb && platform == TargetPlatform.iOS) {
      return _CupertinoAdaptiveBottomNavigationBar(
        currentIndex: currentIndex,
        items: items,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
      );
    }

    return _MaterialAdaptiveBottomNavigationBar(
      currentIndex: currentIndex,
      items: items,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
    );
  }
}

class _CupertinoAdaptiveBottomNavigationBar extends StatelessWidget {
  const _CupertinoAdaptiveBottomNavigationBar({
    required this.currentIndex,
    required this.items,
    required this.onDestinationSelected,
    required this.backgroundColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
  });

  final int currentIndex;
  final List<AdaptiveAppBottomNavigationItem> items;
  final ValueChanged<int> onDestinationSelected;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  static const _iconTopSpacing = 4.0;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onDestinationSelected,
      backgroundColor: backgroundColor ?? theme.barBackgroundColor,
      activeColor: selectedItemColor ?? theme.primaryColor,
      inactiveColor:
          unselectedItemColor ??
          CupertinoColors.inactiveGray.resolveFrom(context),
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: _iconTopSpacing),
                child: item.icon,
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(top: _iconTopSpacing),
                child: item.activeIcon,
              ),
              label: item.label,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MaterialAdaptiveBottomNavigationBar extends StatelessWidget {
  const _MaterialAdaptiveBottomNavigationBar({
    required this.currentIndex,
    required this.items,
    required this.onDestinationSelected,
    required this.backgroundColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
  });

  final int currentIndex;
  final List<AdaptiveAppBottomNavigationItem> items;
  final ValueChanged<int> onDestinationSelected;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resolvedUnselectedColor =
        unselectedItemColor ?? colors.onSurfaceVariant;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: colors.secondaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.onSecondaryContainer
                : resolvedUnselectedColor,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.onSurface
                : resolvedUnselectedColor,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: backgroundColor ?? colors.surfaceContainer,
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: item.icon,
                selectedIcon: item.activeIcon,
                label: item.label,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
