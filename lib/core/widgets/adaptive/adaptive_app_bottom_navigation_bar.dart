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
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onDestinationSelected,
      backgroundColor: backgroundColor ?? CupertinoColors.white,
      activeColor: selectedItemColor ?? const Color(0xFF4CAF50),
      inactiveColor: unselectedItemColor ?? const Color(0xFF6B737B),
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

/// Flat white bar with a green underline beneath the selected item, matching
/// the Feyam brand nav-bar mockup (no Material 3 pill indicator).
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

  static const _barHeight = 60.0;
  static const _underlineWidth = 28.0;
  static const _underlineHeight = 3.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedColor = selectedItemColor ?? colors.secondary;
    final unselectedColor = unselectedItemColor ?? colors.outline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: Border(top: BorderSide(color: colors.outlineVariant, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Row(
            children: List<Widget>.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;
              final itemColor = selected ? selectedColor : unselectedColor;

              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: item.label,
                  child: InkWell(
                    onTap: () => onDestinationSelected(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconTheme.merge(
                          data: IconThemeData(color: itemColor, size: 24),
                          child: selected ? item.activeIcon : item.icon,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: itemColor,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: _underlineWidth,
                          height: _underlineHeight,
                          decoration: BoxDecoration(
                            color: selected ? selectedColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              _underlineHeight / 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, growable: false),
          ),
        ),
      ),
    );
  }
}
