import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/cart/domain/entities/cart_item_entity.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_event.dart';
import 'package:feyam/features/cart/presentation/bloc/cart_state.dart';
import 'package:feyam/features/cart/presentation/screens/checkout_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

// ─────────────────────────────────────────────────────────────────────────────
// Material
// ─────────────────────────────────────────────────────────────────────────────

// ── Feyam MD3 light tokens (derived from the brand seed palette) ──────────────
const _mSurface = Color(0xFFF7F8FB);
const _mCard = Color(0xFFFFFFFF);
const _mPrimary = Color(0xFF005997);
const _mPrimaryTint = Color(0x14005997);
const _mOnSurface = Color(0xFF1A1C1E);
const _mOnSurfaceVar = Color(0xFF5A5F66);
const _mOutline = Color(0xFFDDE1EA);
const _mError = Color(0xFFBA1A1A);

class _MaterialCartContent extends StatefulWidget {
  const _MaterialCartContent();

  @override
  State<_MaterialCartContent> createState() => _MaterialCartContentState();
}

class _MaterialCartContentState extends State<_MaterialCartContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(const CartLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Sane scale: phones land near 1.0 instead of ~0.55.
            final scale = (constraints.maxWidth / 390).clamp(0.85, 1.15);
            final cart = state.cart;
            final itemCount = (cart?.items.length) ?? 0;

            return DefaultTextStyle(
              style: const TextStyle(decoration: TextDecoration.none),
              child: ColoredBox(
                color: _mSurface,
                child: Column(
                  children: <Widget>[
                    _MaterialCartHeader(scale: scale, itemCount: itemCount),
                    Expanded(child: _buildMaterialBody(context, state, scale)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMaterialBody(BuildContext context, CartState state, double scale) {
    final l10n = AppLocalizations.of(context)!;

    if (state.status == CartStatus.loading || state.status == CartStatus.initial) {
      return const Center(child: CircularProgressIndicator(color: _mPrimary));
    }

    if (state.status == CartStatus.empty || state.cart == null || state.cart!.items.isEmpty) {
      return _MaterialCartEmpty(scale: scale);
    }

    if (state.status == CartStatus.failure) {
      return Center(
        child: Text(
          l10n.cartErrorTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _mOnSurfaceVar),
        ),
      );
    }

    final cart = state.cart!;
    final totalQty = cart.items.fold<int>(0, (s, i) => s + i.quantity);

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 20 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final item in cart.items) ...<Widget>[
                  _MaterialCartItemCard(
                    scale: scale,
                    item: item,
                    onRemove: () => context
                        .read<CartBloc>()
                        .add(CartItemRemoveRequested(item.itemId)),
                  ),
                  SizedBox(height: 10 * scale),
                ],
                SizedBox(height: 6 * scale),
                _MaterialCartTotals(
                  scale: scale,
                  total: cart.total,
                  totalQty: totalQty,
                ),
              ],
            ),
          ),
        ),
        _MaterialCheckoutBar(scale: scale, total: cart.total),
      ],
    );
  }
}

class _MaterialCartHeader extends StatelessWidget {
  const _MaterialCartHeader({required this.scale, required this.itemCount});

  final double scale;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _mSurface,
        border: Border(bottom: BorderSide(color: _mOutline)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * scale),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back, size: 24 * scale),
                  color: _mOnSurface,
                ),
                Expanded(
                  child: Text(
                    l10n.cartTitle,
                    style: TextStyle(
                      color: _mOnSurface,
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                if (itemCount > 0)
                  Padding(
                    padding: EdgeInsets.only(right: 12 * scale),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 4 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: _mPrimaryTint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$itemCount',
                        style: TextStyle(
                          color: _mPrimary,
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialCartItemCard extends StatelessWidget {
  const _MaterialCartItemCard({
    required this.scale,
    required this.item,
    required this.onRemove,
  });

  final double scale;
  final CartItemEntity item;
  final VoidCallback onRemove;

  String? get _variantLabel {
    final attrs = item.variantAttributes;
    if (attrs == null || attrs.isEmpty) return null;
    return attrs.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
  }

  String? get _notes {
    final n = item.notes?.trim();
    return (n == null || n.isEmpty) ? null : n;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _mCard,
        border: Border.all(color: _mOutline, width: 1),
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.all(14 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Thumbnail
          Container(
            width: 60 * scale,
            height: 60 * scale,
            decoration: BoxDecoration(
              color: _mSurface,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.productImageUrl != null
                ? Image.network(
                    item.productImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.inventory_2_outlined,
                      size: 28 * scale,
                      color: _mOnSurfaceVar,
                    ),
                  )
                : Icon(
                    Icons.inventory_2_outlined,
                    size: 28 * scale,
                    color: _mOnSurfaceVar,
                  ),
          ),
          SizedBox(width: 14 * scale),
          // Name / variant / notes / price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _mOnSurface,
                    fontSize: 15.5 * scale,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                if (_variantLabel != null) ...<Widget>[
                  SizedBox(height: 4 * scale),
                  Text(
                    _variantLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _mOnSurfaceVar,
                      fontSize: 12.5 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (_notes != null) ...<Widget>[
                  SizedBox(height: 3 * scale),
                  Text(
                    _notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _mOnSurfaceVar,
                      fontSize: 12 * scale,
                      height: 1.3,
                    ),
                  ),
                ],
                SizedBox(height: 8 * scale),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _mPrimary,
                    fontSize: 16.5 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          // Delete + stepper
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(2 * scale),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20 * scale,
                    color: _mError.withValues(alpha: 0.85),
                  ),
                ),
              ),
              SizedBox(height: 14 * scale),
              _MaterialQuantityStepper(scale: scale, item: item),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaterialQuantityStepper extends StatelessWidget {
  const _MaterialQuantityStepper({required this.scale, required this.item});

  final double scale;
  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final canDecrement = item.quantity > 1;

    return Container(
      height: 40 * scale,
      decoration: BoxDecoration(
        color: _mPrimaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _MaterialQuantityButton(
            scale: scale,
            icon: Icons.remove,
            enabled: canDecrement,
            onTap: () => context.read<CartBloc>().add(
                  CartItemQuantityUpdateRequested(item.itemId, item.quantity - 1),
                ),
          ),
          SizedBox(
            width: 26 * scale,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _mOnSurface,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _MaterialQuantityButton(
            scale: scale,
            icon: Icons.add,
            enabled: true,
            onTap: () => context.read<CartBloc>().add(
                  CartItemQuantityUpdateRequested(item.itemId, item.quantity + 1),
                ),
          ),
        ],
      ),
    );
  }
}

class _MaterialQuantityButton extends StatelessWidget {
  const _MaterialQuantityButton({
    required this.scale,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final double scale;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.square(
        dimension: 32 * scale,
        child: Icon(
          icon,
          size: 20 * scale,
          color: enabled ? _mPrimary : _mPrimary.withValues(alpha: 0.32),
        ),
      ),
    );
  }
}

class _MaterialCartTotals extends StatelessWidget {
  const _MaterialCartTotals({
    required this.scale,
    required this.total,
    required this.totalQty,
  });

  final double scale;
  final double total;
  final int totalQty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalStr = '\$${total.toStringAsFixed(2)}';

    return Container(
      decoration: BoxDecoration(
        color: _mCard,
        border: Border.all(color: _mOutline, width: 1),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      child: Column(
        children: <Widget>[
          _MaterialTotalRow(
            scale: scale,
            label: '${l10n.cartSubtotal} ($totalQty)',
            value: totalStr,
          ),
          SizedBox(height: 12 * scale),
          Divider(height: 1, thickness: 1, color: _mOutline),
          SizedBox(height: 12 * scale),
          _MaterialTotalRow(
            scale: scale,
            label: l10n.cartTotal,
            value: totalStr,
            isTotal: true,
          ),
        ],
      ),
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
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal ? _mOnSurface : _mOnSurfaceVar,
              fontSize: isTotal ? 16 * scale : 14 * scale,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? _mPrimary : _mOnSurface,
            fontSize: isTotal ? 18 * scale : 14 * scale,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MaterialCheckoutBar extends StatelessWidget {
  const _MaterialCheckoutBar({required this.scale, required this.total});

  final double scale;
  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: _mCard,
        border: Border(top: BorderSide(color: _mOutline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 16 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 52 * scale,
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final cart = context.read<CartBloc>().state.cart;
                    if (cart == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => CheckoutScreen(cart: cart)),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _mPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16 * scale),
                    ),
                    textStyle: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l10n.cartCheckoutMaterialButton),
                ),
              ),
              SizedBox(height: 10 * scale),
              Text(
                l10n.cartMaterialFootnote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _mOnSurfaceVar,
                  fontSize: 11.5 * scale,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialCartEmpty extends StatelessWidget {
  const _MaterialCartEmpty({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88 * scale,
              height: 88 * scale,
              decoration: const BoxDecoration(
                color: _mPrimaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 40 * scale,
                color: _mPrimary,
              ),
            ),
            SizedBox(height: 20 * scale),
            Text(
              l10n.cartEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _mOnSurface,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              l10n.cartEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _mOnSurfaceVar,
                fontSize: 14 * scale,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24 * scale),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.link, size: 18 * scale),
              label: Text(l10n.cartEmptyAction),
              style: FilledButton.styleFrom(
                backgroundColor: _mPrimaryTint,
                foregroundColor: _mPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 20 * scale,
                  vertical: 12 * scale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cupertino
// ─────────────────────────────────────────────────────────────────────────────

class _CupertinoCartContent extends StatefulWidget {
  const _CupertinoCartContent();

  @override
  State<_CupertinoCartContent> createState() => _CupertinoCartContentState();
}

class _CupertinoCartContentState extends State<_CupertinoCartContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(const CartLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.status == CartStatus.loading || state.status == CartStatus.initial) {
          return const ColoredBox(
            color: kFeyamBg,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (state.status == CartStatus.empty ||
            state.cart == null ||
            state.cart!.items.isEmpty) {
          return _buildEmptyState(context);
        }

        if (state.status == CartStatus.failure) {
          return _buildErrorState(context);
        }

        return _buildLoadedState(context, state.cart!);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ColoredBox(
      color: kFeyamBg,
      child: Column(
        children: <Widget>[
          CupertinoNavigationBar(
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(CupertinoIcons.chevron_back, size: 18),
                  const SizedBox(width: 2),
                  Text(l10n.navHome, style: const TextStyle(fontSize: 17)),
                ],
              ),
            ),
            middle: Text(l10n.navCart),
          ),
          Expanded(
            child: FeyamEmptyState(
              icon: CupertinoIcons.cart_fill,
              title: l10n.cartEmptyTitle,
              subtitle: l10n.cartEmptySubtitle,
              action: FeyamButton(
                label: l10n.cartEmptyAction,
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

  Widget _buildErrorState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ColoredBox(
      color: kFeyamBg,
      child: Column(
        children: <Widget>[
          CupertinoNavigationBar(
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(CupertinoIcons.chevron_back, size: 18),
                  const SizedBox(width: 2),
                  Text(l10n.navHome, style: const TextStyle(fontSize: 17)),
                ],
              ),
            ),
            middle: Text(l10n.navCart),
          ),
          Expanded(
            child: FeyamEmptyState(
              icon: CupertinoIcons.exclamationmark_circle,
              title: l10n.cartErrorTitle,
              subtitle: l10n.cartErrorSubtitle,
              action: FeyamButton(
                label: l10n.cartErrorRetry,
                icon: CupertinoIcons.refresh,
                variant: FeyamButtonVariant.tinted,
                small: true,
                onPressed: () =>
                    context.read<CartBloc>().add(const CartLoadRequested()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, cartEntity) {
    final l10n = AppLocalizations.of(context)!;
    final items = cartEntity.items as List<CartItemEntity>;
    final totalQty = items.fold(0, (s, i) => s + i.quantity);
    final total = cartEntity.total as double;

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
                      FeyamListSection(
                        header: '${items.length} producto${items.length > 1 ? 's' : ''}',
                        children: <Widget>[
                          for (var i = 0; i < items.length; i++)
                            _CupertinoCartRow(
                              item: items[i],
                              isLast: i == items.length - 1,
                              onRemove: () => context.read<CartBloc>().add(
                                    CartItemRemoveRequested(items[i].itemId),
                                  ),
                              onDecrement: () => context.read<CartBloc>().add(
                                    CartItemQuantityUpdateRequested(
                                      items[i].itemId,
                                      items[i].quantity - 1,
                                    ),
                                  ),
                              onIncrement: () => context.read<CartBloc>().add(
                                    CartItemQuantityUpdateRequested(
                                      items[i].itemId,
                                      items[i].quantity + 1,
                                    ),
                                  ),
                            ),
                        ],
                      ),
                      FeyamListSection(
                        header: 'Resumen',
                        children: <Widget>[
                          FeyamListTile(
                            title: Text('Subtotal ($totalQty items)'),
                            detail: Text('\$ ${total.toStringAsFixed(2)}'),
                            chevron: false,
                          ),
                          FeyamListTile(
                            title: const Text(
                              'Total estimado',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            detail: Text(
                              '\$ ${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: kFeyamLabel,
                              ),
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
                    onPressed: () {
                      final cart = context.read<CartBloc>().state.cart;
                      if (cart == null) return;
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (_) => CheckoutScreen(cart: cart),
                        ),
                      );
                    },
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

  final CartItemEntity item;
  final bool isLast;
  final VoidCallback onRemove;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  String? get _variantLabel {
    final attrs = item.variantAttributes;
    if (attrs == null || attrs.isEmpty) return null;
    return attrs.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
  }

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
                  clipBehavior: Clip.antiAlias,
                  child: item.productImageUrl != null
                      ? Image.network(
                          item.productImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            CupertinoIcons.cart,
                            size: 26,
                            color: kFeyamLabelSec,
                          ),
                        )
                      : const Icon(CupertinoIcons.cart, size: 26, color: kFeyamLabelSec),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: kFeyamLabel,
                          letterSpacing: -0.24,
                        ),
                      ),
                      if (_variantLabel != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          _variantLabel!,
                          style: const TextStyle(fontSize: 12, color: kFeyamLabelSec),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        '\$ ${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kFeyamTint,
                          letterSpacing: -0.41,
                        ),
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
                            child: Icon(
                              CupertinoIcons.minus_circled,
                              size: 22,
                              color: item.quantity <= 1 ? kFeyamLabelTer : kFeyamTint,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kFeyamLabel,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: onIncrement,
                            child: const Icon(
                              CupertinoIcons.plus_circled,
                              size: 22,
                              color: kFeyamTint,
                            ),
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
            Container(
              height: 0.5,
              color: kFeyamSepLight,
              margin: const EdgeInsets.only(left: 16),
            ),
        ],
      ),
    );
  }
}
