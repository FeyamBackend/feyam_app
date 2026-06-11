import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/cart/presentation/screens/checkout_success_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _loading = false;

  static const _address = _AddressData(
    label: 'Casa',
    line: 'Cra. 43A #1-50, Apto 1204',
    city: 'Medellín, Antioquia',
  );

  static const _items = <_CartItem>[
    _CartItem(title: 'Sony WH-1000XM5', notes: 'Color negro', qty: 1, price: 278.00),
    _CartItem(title: 'Apple Watch SE 2nd Gen', notes: null, qty: 1, price: 249.00),
  ];

  static const _serviceRate = 0.12;
  static const _shippingCost = 18.50;

  double get _subtotal => _items.fold(0, (s, it) => s + it.price * it.qty);
  double get _service => _subtotal * _serviceRate;
  double get _total => _subtotal + _service + _shippingCost;

  void _confirm() {
    setState(() => _loading = true);
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacement(
        context,
        AdaptivePlatform.pageRoute<void>(context: context, builder: (_) => const CheckoutSuccessScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return _CupertinoCheckoutContent(
        loading: _loading,
        onConfirm: _confirm,
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return Scaffold(
          backgroundColor: colors.surfaceContainerLowest,
          appBar: AppBar(
            backgroundColor: colors.surfaceContainer,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_rounded, size: 24 * scale),
            ),
            title: Text(
              l10n.checkoutTitle,
              style: textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    14 * scale,
                    16 * scale,
                    24 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CoSection(
                        scale: scale,
                        label: l10n.checkoutAddress,
                        child: _AddressCard(scale: scale, address: _address),
                      ),
                      SizedBox(height: 20 * scale),
                      _CoSection(
                        scale: scale,
                        label: l10n.checkoutSummary,
                        child: Column(
                          children: _items
                              .map((it) => Padding(
                                    padding: EdgeInsets.only(bottom: 8 * scale),
                                    child: _ItemRow(scale: scale, item: it),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      _CoSection(
                        scale: scale,
                        label: l10n.checkoutPayMethod,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14 * scale),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.payments_rounded,
                                  size: 20 * scale,
                                  color: colors.onTertiaryContainer,
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: Text(
                                    l10n.checkoutPayInfo,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colors.onTertiaryContainer,
                                      fontSize: 13 * scale,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      _CoSection(
                        scale: scale,
                        label: l10n.checkoutEstPrice,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14 * scale),
                            child: Column(
                              children: <Widget>[
                                _PriceRow(scale: scale, k: l10n.checkoutSubtotal, v: _fmt(_subtotal)),
                                _PriceRow(scale: scale, k: l10n.checkoutService, v: _fmt(_service)),
                                _PriceRow(scale: scale, k: l10n.checkoutShipping, v: _fmt(_shippingCost)),
                                Divider(height: 1 + 16 * scale, color: colors.outlineVariant),
                                _PriceRow(
                                  scale: scale,
                                  k: l10n.checkoutTotal,
                                  v: _fmt(_total),
                                  strong: true,
                                  accent: true,
                                ),
                                SizedBox(height: 10 * scale),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 13 * scale,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    SizedBox(width: 5 * scale),
                                    Expanded(
                                      child: Text(
                                        l10n.checkoutDisclaimer,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 11 * scale,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.outlineVariant)),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            l10n.checkoutTotal,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 13 * scale,
                            ),
                          ),
                          Text(
                            _fmt(_total),
                            style: textTheme.titleLarge?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18 * scale,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * scale),
                      SizedBox(
                        height: 52 * scale,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _confirm,
                          icon: _loading
                              ? SizedBox(
                                  width: 18 * scale,
                                  height: 18 * scale,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : Icon(Icons.check_rounded, size: 20 * scale),
                          label: _loading
                              ? const SizedBox.shrink()
                              : Text(l10n.checkoutConfirm),
                          style: FilledButton.styleFrom(
                            textStyle: textTheme.labelLarge?.copyWith(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                          ),
                        ),
                      ),
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

  String _fmt(double v) =>
      '\$ ${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
}

class _CoSection extends StatelessWidget {
  const _CoSection({required this.scale, required this.label, required this.child});

  final double scale;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 2 * scale, bottom: 8 * scale),
          child: Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 11 * scale,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.scale, required this.address});

  final double scale;
  final _AddressData address;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(14 * scale, 14 * scale, 14 * scale, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 40 * scale,
                  height: 40 * scale,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 20 * scale,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        address.label,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14 * scale,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        '${address.line}\n${address.city}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 13 * scale,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.checkoutChange,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14 * scale, 10 * scale, 14 * scale, 14 * scale),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(6 * scale),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 7 * scale),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.schedule_rounded, size: 14 * scale, color: colors.onSurfaceVariant),
                    SizedBox(width: 6 * scale),
                    Text(
                      '${l10n.checkoutDelivery}: ',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 12 * scale,
                      ),
                    ),
                    Text(
                      l10n.checkoutDeliveryTime,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.scale, required this.item});

  final double scale;
  final _CartItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(14 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44 * scale,
              height: 44 * scale,
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Icon(Icons.inventory_2_rounded, size: 24 * scale, color: colors.onSurfaceVariant),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 14 * scale,
                      height: 1.35,
                    ),
                  ),
                  if (item.notes != null) ...[
                    SizedBox(height: 2 * scale),
                    Text(
                      item.notes!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ],
                  SizedBox(height: 4 * scale),
                  Text(
                    '${l10n.addToCartQuantityLabel}: ${item.qty}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12 * scale,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$ ${(item.price * item.qty).toStringAsFixed(2)}',
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 15 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.scale,
    required this.k,
    required this.v,
    this.strong = false,
    this.accent = false,
  });

  final double scale;
  final String k;
  final String v;
  final bool strong;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            k,
            style: textTheme.bodyMedium?.copyWith(
              color: strong ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
              fontSize: strong ? 15 * scale : 13 * scale,
            ),
          ),
          Text(
            v,
            style: textTheme.bodyLarge?.copyWith(
              color: accent ? colors.primary : colors.onSurface,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
              fontSize: strong ? 17 * scale : 13 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressData {
  const _AddressData({required this.label, required this.line, required this.city});

  final String label;
  final String line;
  final String city;
}

class _CartItem {
  const _CartItem({
    required this.title,
    required this.notes,
    required this.qty,
    required this.price,
  });

  final String title;
  final String? notes;
  final int qty;
  final double price;
}

// ── Cupertino Checkout ────────────────────────────────────────────────────────

class _CupertinoCheckoutContent extends StatelessWidget {
  const _CupertinoCheckoutContent({
    required this.loading,
    required this.onConfirm,
  });

  final bool loading;
  final VoidCallback onConfirm;

  static const _items = <_CartItem>[
    _CartItem(title: 'Sony WH-1000XM5', notes: 'Color negro', qty: 1, price: 278.00),
    _CartItem(title: 'Apple Watch SE 2nd Gen', notes: null, qty: 1, price: 249.00),
  ];

  static const _serviceRate = 0.12;
  static const _shippingCOP = 38000.0;

  double get _subtotal => _items.fold(0, (s, it) => s + it.price * it.qty);
  double get _service => _subtotal * _serviceRate;
  double get _total => _subtotal + _service + _shippingCOP / 4100;

  @override
  Widget build(BuildContext context) {
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
                      Text('Carrito', style: TextStyle(fontSize: 17)),
                    ],
                  ),
                ),
                middle: const Text('Checkout'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 8 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 16 * scale),
                      // Dirección
                      FeyamListSection(
                        header: 'Dirección de envío',
                        children: <Widget>[
                          FeyamListTile(
                            title: const Text('Casa'),
                            subtitle: const Text('Cra. 43A #1-50, Apto 1204 · Medellín, Antioquia'),
                            leading: FeyamIconTile(icon: CupertinoIcons.location_fill, color: kFeyamTint),
                            trailing: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(CupertinoIcons.pencil, size: 16, color: kFeyamTint),
                            ),
                            chevron: false,
                            isLast: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                      // Resumen pedido
                      FeyamListSection(
                        header: 'Resumen del pedido',
                        children: <Widget>[
                          for (var i = 0; i < _items.length; i++)
                            FeyamListTile(
                              title: Text(_items[i].title),
                              subtitle: Text('Cantidad: ${_items[i].qty}'),
                              detail: Text('\$ ${(_items[i].price * _items[i].qty).toStringAsFixed(2)}'),
                              chevron: false,
                              isLast: i == _items.length - 1,
                            ),
                        ],
                      ),
                      // Precio estimado
                      FeyamListSection(
                        header: 'Precio estimado',
                        children: <Widget>[
                          FeyamListTile(
                            title: const Text('Subtotal productos'),
                            detail: Text('\$ ${_subtotal.toStringAsFixed(2)}'),
                            chevron: false,
                          ),
                          FeyamListTile(
                            title: const Text('Servicio Feyam (12%)'),
                            detail: Text('\$ ${_service.toStringAsFixed(2)}'),
                            chevron: false,
                          ),
                          FeyamListTile(
                            title: const Text('Envío internacional'),
                            detail: const Text('\$ 9.27'),
                            chevron: false,
                          ),
                          FeyamListTile(
                            title: const Text('Total estimado', style: TextStyle(fontWeight: FontWeight.w700)),
                            detail: Text(
                              '\$ ${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: kFeyamTint),
                            ),
                            chevron: false,
                            isLast: true,
                          ),
                        ],
                      ),
                      // Disclaimer
                      Padding(
                        padding: EdgeInsets.fromLTRB(32 * scale, 4, 32 * scale, 16),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(CupertinoIcons.info_circle, size: 14, color: kFeyamLabelTer),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'El precio final puede variar según impuestos de aduana y tasa de cambio.',
                                style: TextStyle(fontSize: 12, color: kFeyamLabelTer, height: 1.4, fontFamily: '.SF Pro Text'),
                              ),
                            ),
                          ],
                        ),
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
                child: loading
                    ? const Center(child: CupertinoActivityIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: FeyamButton(
                          label: 'Confirmar pedido',
                          icon: CupertinoIcons.checkmark,
                          onPressed: onConfirm,
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
