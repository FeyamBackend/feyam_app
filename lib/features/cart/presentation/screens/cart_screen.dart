import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/cart/presentation/screens/checkout_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoCartContent();
    }

    return const _MaterialCartContent();
  }
}

class _MaterialCartContent extends StatelessWidget {
  const _MaterialCartContent();

  @override
  Widget build(BuildContext context) {
    const items = <_MaterialCartItem>[
      _MaterialCartItem(
        name: 'Velocita Pro Runner',
        variant: 'Size: 42 • Red',
        price: r'$149.00',
        quantity: 1,
      ),
      _MaterialCartItem(
        name: 'Aura Minimalist Timepiece',
        variant: 'Silver • 40mm',
        price: r'$210.00',
        quantity: 1,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 706).clamp(0.54, 1.0);

        return ColoredBox(
          color: const Color(0xFFFAF9FE),
          child: Column(
            children: <Widget>[
              _MaterialCartHeader(scale: scale),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    29 * scale,
                    78 * scale,
                    29 * scale,
                    40 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _MaterialCartItemsCard(scale: scale, items: items),
                      SizedBox(height: 48 * scale),
                      _MaterialCartTotals(scale: scale),
                      SizedBox(height: 44 * scale),
                      _MaterialCheckoutButton(scale: scale),
                      SizedBox(height: 30 * scale),
                      _MaterialCartFootnote(scale: scale),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MaterialCartHeader extends StatelessWidget {
  const _MaterialCartHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9FE),
        border: Border(bottom: BorderSide(color: Color(0xFFD8DBE3))),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 100 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 29 * scale),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.cartTitle,
                style: textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF111315),
                  fontSize: 31 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialCartItemsCard extends StatelessWidget {
  const _MaterialCartItemsCard({required this.scale, required this.items});

  final double scale;
  final List<_MaterialCartItem> items;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18 * scale),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9FE),
          border: Border.all(color: const Color(0xFFDADDE7), width: scale),
          borderRadius: BorderRadius.circular(18 * scale),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            for (var index = 0; index < items.length; index++) ...[
              _MaterialCartItemRow(scale: scale, item: items[index]),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: scale,
                  color: const Color(0xFFDADDE7),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MaterialCartItemRow extends StatelessWidget {
  const _MaterialCartItemRow({required this.scale, required this.item});

  final double scale;
  final _MaterialCartItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        30 * scale,
        52 * scale,
        30 * scale,
        48 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF111315),
                    fontSize: 30 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ),
              SizedBox(width: 16 * scale),
              Text(
                item.price,
                style: textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF5D6067),
                  fontSize: 31 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1.05,
                ),
              ),
            ],
          ),
          SizedBox(height: 30 * scale),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF778090),
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              _MaterialQuantityStepper(scale: scale, quantity: item.quantity),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaterialQuantityStepper extends StatelessWidget {
  const _MaterialQuantityStepper({required this.scale, required this.quantity});

  final double scale;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 186 * scale,
      height: 58 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFE3E4EA),
        borderRadius: BorderRadius.circular(32 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _MaterialQuantityButton(scale: scale, icon: Icons.remove),
          Text(
            '$quantity',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: CupertinoColors.black,
              fontSize: 29 * scale,
              fontWeight: FontWeight.w400,
            ),
          ),
          _MaterialQuantityButton(scale: scale, icon: Icons.add),
        ],
      ),
    );
  }
}

class _MaterialQuantityButton extends StatelessWidget {
  const _MaterialQuantityButton({required this.scale, required this.icon});

  final double scale;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 46 * scale,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(23 * scale),
        child: Icon(icon, size: 27 * scale, color: const Color(0xFF005FC8)),
      ),
    );
  }
}

class _MaterialCartTotals extends StatelessWidget {
  const _MaterialCartTotals({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        _MaterialTotalRow(
          scale: scale,
          label: l10n.cartSubtotal,
          value: r'$359.00',
        ),
        SizedBox(height: 26 * scale),
        _MaterialTotalRow(
          scale: scale,
          label: l10n.cartEstimatedShipping,
          value: r'$12.50',
        ),
        SizedBox(height: 22 * scale),
        Divider(height: 1, thickness: scale, color: const Color(0xFFDADDE7)),
        SizedBox(height: 24 * scale),
        _MaterialTotalRow(
          scale: scale,
          label: l10n.cartTotal,
          value: r'$371.50',
          isTotal: true,
        ),
      ],
    );
  }
}

class _MaterialTotalRow extends StatelessWidget {
  const _MaterialTotalRow({
    required this.scale,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final double scale;
  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: textTheme.headlineSmall?.copyWith(
              color: isTotal
                  ? const Color(0xFF111315)
                  : const Color(0xFF2D3340),
              fontSize: isTotal ? 29 * scale : 27 * scale,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            color: isTotal ? const Color(0xFF005FC8) : CupertinoColors.black,
            fontSize: isTotal ? 30 * scale : 29 * scale,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _MaterialCheckoutButton extends StatelessWidget {
  const _MaterialCheckoutButton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 98 * scale,
      child: FilledButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const CheckoutScreen()),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0A63C7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          elevation: 10,
          shadowColor: const Color(0xFF0A63C7).withValues(alpha: 0.25),
          textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 30 * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Text(l10n.cartCheckoutMaterialButton),
      ),
    );
  }
}

class _MaterialCartFootnote extends StatelessWidget {
  const _MaterialCartFootnote({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 58 * scale),
      child: Text(
        l10n.cartMaterialFootnote,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: const Color(0xFF2D3340),
          fontSize: 22 * scale,
          fontWeight: FontWeight.w400,
          height: 1.25,
        ),
      ),
    );
  }
}

class _MaterialCartItem {
  const _MaterialCartItem({
    required this.name,
    required this.variant,
    required this.price,
    required this.quantity,
  });

  final String name;
  final String variant;
  final String price;
  final int quantity;
}

class _CupertinoCartContent extends StatefulWidget {
  const _CupertinoCartContent();

  @override
  State<_CupertinoCartContent> createState() => _CupertinoCartContentState();
}

class _CupertinoCartContentState extends State<_CupertinoCartContent> {
  final List<_CupertinoCartItem> _items = <_CupertinoCartItem>[
    _CupertinoCartItem(
      icon: CupertinoIcons.headphones,
      title: 'Auriculares Sony WH-1000XM5',
      variants: 'Color negro',
      price: 278.00,
      qty: 1,
    ),
    _CupertinoCartItem(
      icon: CupertinoIcons.device_phone_portrait,
      title: 'Apple Watch SE 2nd Gen',
      price: 249.00,
      qty: 1,
    ),
  ];

  void _changeQty(int index, int delta) {
    setState(() {
      _items[index] = _items[index].copyWith(
        qty: (_items[index].qty + delta).clamp(1, 99),
      );
    });
  }

  void _remove(int index) {
    setState(() => _items.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_items.isEmpty) {
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
              middle: const Text('Carrito'),
            ),
            Expanded(
              child: FeyamEmptyState(
                icon: CupertinoIcons.cart_fill,
                title: 'Tu carrito está vacío',
                subtitle: 'Pegá el link de un producto para empezar a armar tu pedido.',
                action: FeyamButton(
                  label: 'Pegar un link',
                  icon: CupertinoIcons.link,
                  variant: FeyamButtonVariant.tinted,
                  small: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final totalQty = _items.fold(0, (s, i) => s + i.qty);
    final subtotal = _items.fold(0.0, (s, i) => s + i.price * i.qty);

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

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
                middle: Text('${l10n.navCart} ($totalQty)'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 8 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 16 * scale),
                      // Items
                      FeyamListSection(
                        header: '${_items.length} producto${_items.length > 1 ? 's' : ''}',
                        children: <Widget>[
                          for (var i = 0; i < _items.length; i++)
                            _CupertinoCartRow(
                              item: _items[i],
                              isLast: i == _items.length - 1,
                              onRemove: () => _remove(i),
                              onDecrement: () => _changeQty(i, -1),
                              onIncrement: () => _changeQty(i, 1),
                            ),
                        ],
                      ),
                      // Summary
                      FeyamListSection(
                        header: 'Resumen',
                        children: <Widget>[
                          FeyamListTile(
                            title: Text('Subtotal ($totalQty items)'),
                            detail: Text('\$ ${subtotal.toStringAsFixed(2)}'),
                            chevron: false,
                          ),
                          FeyamListTile(
                            title: const Text(
                              'Total estimado',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            detail: Text(
                              '\$ ${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: kFeyamLabel),
                            ),
                            chevron: false,
                            isLast: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 28 * scale),
                decoration: const BoxDecoration(
                  color: kFeyamCard,
                  border: Border(top: BorderSide(color: kFeyamSepLight, width: 0.5)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FeyamButton(
                    label: 'Proceder al checkout',
                    onPressed: () => Navigator.of(context).push(
                      CupertinoPageRoute<void>(builder: (_) => const CheckoutScreen()),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CupertinoCartRow extends StatelessWidget {
  const _CupertinoCartRow({
    required this.item,
    required this.isLast,
    required this.onRemove,
    required this.onDecrement,
    required this.onIncrement,
  });

  final _CupertinoCartItem item;
  final bool isLast;
  final VoidCallback onRemove;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kFeyamCard,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: kFeyamBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 26, color: kFeyamLabelSec),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kFeyamLabel, letterSpacing: -0.24),
                      ),
                      if (item.variants != null) ...[
                        const SizedBox(height: 3),
                        Text(item.variants!, style: const TextStyle(fontSize: 12, color: kFeyamLabelSec)),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        '\$ ${(item.price * item.qty).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kFeyamTint, letterSpacing: -0.41),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(CupertinoIcons.trash, size: 18, color: kFeyamRed),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: kFeyamFillTer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GestureDetector(
                            onTap: onDecrement,
                            child: Icon(CupertinoIcons.minus_circled, size: 22, color: item.qty <= 1 ? kFeyamLabelTer : kFeyamTint),
                          ),
                          const SizedBox(width: 6),
                          Text('${item.qty}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kFeyamLabel)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: onIncrement,
                            child: const Icon(CupertinoIcons.plus_circled, size: 22, color: kFeyamTint),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            Container(height: 0.5, color: kFeyamSepLight, margin: const EdgeInsets.only(left: 16)),
        ],
      ),
    );
  }
}

class _CupertinoCartItem {
  const _CupertinoCartItem({
    required this.icon,
    required this.title,
    this.variants,
    required this.price,
    required this.qty,
  });

  final IconData icon;
  final String title;
  final String? variants;
  final double price;
  final int qty;

  _CupertinoCartItem copyWith({int? qty}) => _CupertinoCartItem(
        icon: icon,
        title: title,
        variants: variants,
        price: price,
        qty: qty ?? this.qty,
      );
}
