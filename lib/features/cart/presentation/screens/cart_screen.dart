import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
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
        onPressed: () {},
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

class _CupertinoCartContent extends StatelessWidget {
  const _CupertinoCartContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <_CartItem>[
      _CartItem(
        name: l10n.cartItemChronographName,
        price: r'$299.00',
        quantity: 1,
      ),
      _CartItem(
        name: l10n.cartItemAeroName,
        price: r'$120.00',
        quantity: 2,
      ),
      _CartItem(
        name: l10n.cartItemSonicName,
        price: r'$450.00',
        quantity: 1,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 532).clamp(0.58, 1.0);

        return ColoredBox(
          color: const Color(0xFFFAF9FE),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              22 * scale,
              28 * scale,
              22 * scale,
              46 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _CupertinoCartHeader(scale: scale),
                SizedBox(height: 52 * scale),
                for (final item in items) ...[
                  _CupertinoCartItemCard(scale: scale, item: item),
                  SizedBox(height: 22 * scale),
                ],
                SizedBox(height: 12 * scale),
                _CupertinoCartSummary(scale: scale),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CupertinoCartHeader extends StatelessWidget {
  const _CupertinoCartHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CupertinoTheme.of(context);

    return Text(
      l10n.navCart,
      style: theme.textTheme.textStyle.copyWith(
        color: const Color(0xFF002B45),
        fontSize: 31 * scale,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}


class _CupertinoCartItemCard extends StatelessWidget {
  const _CupertinoCartItemCard({required this.scale, required this.item});

  final double scale;
  final _CartItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CupertinoTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8FD),
        border: Border.all(color: const Color(0xFFDCDDE5), width: scale),
        borderRadius: BorderRadius.circular(34 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22 * scale,
          24 * scale,
          22 * scale,
          22 * scale,
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
                    style: theme.textTheme.textStyle.copyWith(
                      color: CupertinoColors.black,
                      fontSize: 23 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                CupertinoButton(
                  minimumSize: Size.square(34 * scale),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: Semantics(
                    label: l10n.cartRemoveItemSemanticLabel,
                    child: Icon(
                      CupertinoIcons.trash,
                      color: const Color(0xFF263238),
                      size: 25 * scale,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30 * scale),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.price,
                    style: theme.textTheme.textStyle.copyWith(
                      color: const Color(0xFF002B45),
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                _CupertinoQuantityStepper(
                  scale: scale,
                  quantity: item.quantity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoQuantityStepper extends StatelessWidget {
  const _CupertinoQuantityStepper({
    required this.scale,
    required this.quantity,
  });

  final double scale;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55 * scale,
      width: 164 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E8),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _CupertinoQuantityButton(scale: scale, icon: CupertinoIcons.minus),
          Text(
            '$quantity',
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              color: CupertinoColors.black,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w400,
            ),
          ),
          _CupertinoQuantityButton(scale: scale, icon: CupertinoIcons.plus),
        ],
      ),
    );
  }
}

class _CupertinoQuantityButton extends StatelessWidget {
  const _CupertinoQuantityButton({required this.scale, required this.icon});

  final double scale;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: Size.square(44 * scale),
      padding: EdgeInsets.zero,
      onPressed: () {},
      child: Icon(icon, color: CupertinoColors.black, size: 18 * scale),
    );
  }
}

class _CupertinoCartSummary extends StatelessWidget {
  const _CupertinoCartSummary({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CupertinoTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEDECF2),
        borderRadius: BorderRadius.circular(34 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          32 * scale,
          34 * scale,
          32 * scale,
          34 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.cartSummaryTitle,
              style: theme.textTheme.textStyle.copyWith(
                color: CupertinoColors.black,
                fontSize: 30 * scale,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 32 * scale),
            _CupertinoSummaryRow(
              scale: scale,
              label: l10n.cartSubtotal,
              value: r'$869.00',
            ),
            SizedBox(height: 26 * scale),
            _CupertinoSummaryRow(
              scale: scale,
              label: l10n.cartShipping,
              value: r'$15.00',
            ),
            SizedBox(height: 26 * scale),
            _CupertinoSummaryRow(
              scale: scale,
              label: l10n.cartTaxes,
              value: r'$86.90',
            ),
            SizedBox(height: 36 * scale),
            Divider(
              height: 1,
              thickness: scale,
              color: const Color(0xFFC5C8D0),
            ),
            SizedBox(height: 36 * scale),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.cartTotal,
                    style: theme.textTheme.textStyle.copyWith(
                      color: CupertinoColors.black,
                      fontSize: 30 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  r'$970.90',
                  style: theme.textTheme.textStyle.copyWith(
                    color: const Color(0xFF002B45),
                    fontSize: 30 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 34 * scale),
            SizedBox(
              height: 70 * scale,
              child: CupertinoButton(
                color: const Color(0xFF004053),
                borderRadius: BorderRadius.circular(34 * scale),
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: Text(
                  l10n.cartCheckoutButton,
                  style: theme.textTheme.textStyle.copyWith(
                    color: CupertinoColors.white,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 34 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  CupertinoIcons.lock,
                  color: const Color(0xFF6F747C),
                  size: 16 * scale,
                ),
                SizedBox(width: 12 * scale),
                Text(
                  l10n.cartSecurePayment,
                  style: theme.textTheme.textStyle.copyWith(
                    color: const Color(0xFF6F747C),
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoSummaryRow extends StatelessWidget {
  const _CupertinoSummaryRow({
    required this.scale,
    required this.label,
    required this.value,
  });

  final double scale;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.textStyle.copyWith(
              color: const Color(0xFF2E343B),
              fontSize: 22 * scale,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.textStyle.copyWith(
            color: CupertinoColors.black,
            fontSize: 22 * scale,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _CartItem {
  const _CartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String name;
  final String price;
  final int quantity;
}
