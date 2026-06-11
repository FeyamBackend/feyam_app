import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  static const _stores = <_StoreItem>[
    _StoreItem(name: 'Amazon', host: 'amazon.com', icon: Icons.shopping_bag_rounded, color: Color(0xFFFF9900)),
    _StoreItem(name: 'eBay', host: 'ebay.com', icon: Icons.gavel_rounded, color: Color(0xFFE53238)),
    _StoreItem(name: 'Walmart', host: 'walmart.com', icon: Icons.storefront_rounded, color: Color(0xFF0071DC)),
    _StoreItem(name: 'Best Buy', host: 'bestbuy.com', icon: Icons.devices_rounded, color: Color(0xFF0A4ABF)),
    _StoreItem(name: 'SHEIN', host: 'shein.com', icon: Icons.checkroom_rounded, color: Color(0xFF222222)),
    _StoreItem(name: 'AliExpress', host: 'aliexpress.com', icon: Icons.local_mall_rounded, color: Color(0xFFE62E04)),
  ];

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoStoresContent();
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            backgroundColor: colors.surfaceContainer,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_rounded, size: 24 * scale),
            ),
            title: Text(
              l10n.storesTitle,
              style: textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 4 * scale),
                child: Text(
                  l10n.storesHint,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 14 * scale,
                    height: 1.4,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8 * scale),
                  itemCount: _stores.length,
                  itemBuilder: (context, index) {
                    final store = _stores[index];
                    return _StoreListTile(scale: scale, store: store);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoreListTile extends StatelessWidget {
  const _StoreListTile({required this.scale, required this.store});

  final double scale;
  final _StoreItem store;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8 * scale),
              child: Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: store.color,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(store.icon, color: Colors.white, size: 22 * scale),
              ),
            ),
            SizedBox(width: 4 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    store.name,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 16 * scale,
                    ),
                  ),
                  Text(
                    store.host,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 13 * scale,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12 * scale),
              child: Icon(
                Icons.open_in_new_rounded,
                size: 20 * scale,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreItem {
  const _StoreItem({
    required this.name,
    required this.host,
    required this.icon,
    required this.color,
  });

  final String name;
  final String host;
  final IconData icon;
  final Color color;
}

// ── Cupertino Stores ──────────────────────────────────────────────────────────

class _CupertinoStoresContent extends StatelessWidget {
  const _CupertinoStoresContent();

  static const _stores = <_CupertinoStoreItem>[
    _CupertinoStoreItem(name: 'Amazon',     host: 'amazon.com',     icon: CupertinoIcons.bag_fill,        color: Color(0xFFFF9900)),
    _CupertinoStoreItem(name: 'eBay',       host: 'ebay.com',       icon: CupertinoIcons.hammer_fill,     color: Color(0xFFE53238)),
    _CupertinoStoreItem(name: 'Walmart',    host: 'walmart.com',    icon: CupertinoIcons.building_2_fill, color: Color(0xFF0071DC)),
    _CupertinoStoreItem(name: 'Best Buy',   host: 'bestbuy.com',    icon: CupertinoIcons.desktopcomputer, color: Color(0xFF0A4ABF)),
    _CupertinoStoreItem(name: 'SHEIN',      host: 'shein.com',      icon: CupertinoIcons.tag_fill,        color: Color(0xFF222222)),
    _CupertinoStoreItem(name: 'AliExpress', host: 'aliexpress.com', icon: CupertinoIcons.bag_fill,        color: Color(0xFFE62E04)),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kFeyamBg,
      child: Column(
        children: <Widget>[
          CupertinoNavigationBar(
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(CupertinoIcons.chevron_back, size: 18),
                  SizedBox(width: 2),
                  Text('Inicio', style: TextStyle(fontSize: 17)),
                ],
              ),
            ),
            middle: const Text('Tiendas soportadas'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(32, 12, 32, 4),
                    child: Text(
                      'Tocá una tienda para abrirla en tu navegador. Copiá el link del producto y pegalo en Feyam.',
                      style: TextStyle(fontSize: 15, color: kFeyamLabelSec, height: 1.4, fontFamily: '.SF Pro Text'),
                    ),
                  ),
                  FeyamListSection(
                    children: <Widget>[
                      for (var i = 0; i < _stores.length; i++)
                        FeyamListTile(
                          title: Text(_stores[i].name),
                          detail: Text(_stores[i].host),
                          leading: FeyamIconTile(icon: _stores[i].icon, color: _stores[i].color),
                          trailing: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(CupertinoIcons.arrow_up_right_square, size: 18, color: kFeyamTint),
                          ),
                          chevron: false,
                          isLast: i == _stores.length - 1,
                          onTap: () {},
                        ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '¿No encontrás tu tienda? Contactanos por Ayuda',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: kFeyamLabelTer, fontFamily: '.SF Pro Text'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoStoreItem {
  const _CupertinoStoreItem({
    required this.name,
    required this.host,
    required this.icon,
    required this.color,
  });

  final String name;
  final String host;
  final IconData icon;
  final Color color;
}
