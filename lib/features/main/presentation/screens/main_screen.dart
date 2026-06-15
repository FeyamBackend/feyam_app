import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/features/auth/presentation/screens/login_screen.dart';
import 'package:feyam/features/help/presentation/screens/help_screen.dart';
import 'package:feyam/features/home/presentation/screens/home_screen.dart';
import 'package:feyam/features/orders/presentation/screens/order_screen.dart';
import 'package:feyam/features/profile/presentation/screens/profile_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final items = _bottomNavigationItems(
      useCupertino: useCupertino,
      l10n: l10n,
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

    return BlocListener<AuthBloc, AuthState>(
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
      child: AdaptiveAppScaffold(
        title:
            _currentIndex == 0 ||
                _currentIndex == 1 ||
                _currentIndex == 2 ||
                _currentIndex == 3
            ? null
            : currentLabel,
        body: _MainTabContent(currentIndex: _currentIndex),
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }

  List<AdaptiveAppBottomNavigationItem> _bottomNavigationItems({
    required bool useCupertino,
    required AppLocalizations l10n,
  }) {
    if (useCupertino) {
      return <AdaptiveAppBottomNavigationItem>[
        AdaptiveAppBottomNavigationItem(
          icon: const Icon(CupertinoIcons.house),
          activeIcon: const Icon(CupertinoIcons.house_fill),
          label: l10n.navHome,
        ),
        AdaptiveAppBottomNavigationItem(
          icon: const Icon(CupertinoIcons.cube_box),
          activeIcon: const Icon(CupertinoIcons.cube_box_fill),
          label: l10n.navOrders,
        ),
        AdaptiveAppBottomNavigationItem(
          icon: const Icon(CupertinoIcons.question_circle),
          activeIcon: const Icon(CupertinoIcons.question_circle_fill),
          label: l10n.navHelp,
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
        icon: Icon(Icons.list_alt_outlined),
        activeIcon: Icon(Icons.list_alt),
        label: l10n.navOrders,
      ),
      AdaptiveAppBottomNavigationItem(
        icon: Icon(Icons.help_outline_rounded),
        activeIcon: Icon(Icons.help_rounded),
        label: l10n.navHelp,
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
    final pages = <Widget>[
      const HomeScreen(),
      const OrderScreen(),
      const HelpScreen(),
      const ProfileScreen(),
    ];

    return pages[currentIndex];
  }
}
