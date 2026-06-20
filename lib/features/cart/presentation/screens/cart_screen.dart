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
            final scale = (constraints.maxWidth / 706).clamp(0.54, 1.0);

            return ColoredBox(
              color: const Color(0xFFFAF9FE),
              child: Column(
                children: <Widget>[
                  _MaterialCartHeader(scale: scale),
                  Expanded(
                    child: _buildMaterialBody(context, state, scale),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMaterialBody(BuildContext context, CartState state, double scale) {
    if (state.status == CartStatus.loading || state.status == CartStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CartStatus.empty || state.cart == null || state.cart!.items.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.cartEmptyTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF778090),
            fontSize: 22 * scale,
          ),
        ),
      );
    }

    if (state.status == CartStatus.failure) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.cartErrorTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF778090),
          ),
        ),
      );
    }

    final cart = state.cart!;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        29 * scale,
        78 * scale,
        29 * scale,
        40 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _MaterialCartItemsCard(scale: scale, items: cart.items),
          SizedBox(height: 48 * scale),
          _MaterialCartTotals(scale: scale, total: cart.total, currencyCode: cart.currencyCode),
          SizedBox(height: 44 * scale),
          _MaterialCheckoutButton(scale: scale),
          SizedBox(height: 30 * scale),
          _MaterialCartFootnote(scale: scale),
        ],
      ),
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
            padding: EdgeInsets.symmetric(horizontal: 4 * scale),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back, size: 24 * scale),
                  color: const Color(0xFF111315),
                ),
                Expanded(
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
              ],
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
  final List<CartItemEntity> items;

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
              _MaterialCartItemRow(
                scale: scale,
                item: items[index],
                onRemove: () => context.read<CartBloc>().add(
                      CartItemRemoveRequested(items[index].itemId),
                    ),
              ),
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
  const _MaterialCartItemRow({
    required this.scale,
    required this.item,
    required this.onRemove,
  });

  final double scale;
  final CartItemEntity item;
  final VoidCallback onRemove;

  String get _variantLabel {
    final attrs = item.variantAttributes;
    if (attrs == null || attrs.isEmpty) return '';
    return attrs.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
  }

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
                  item.productName,
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
                '\$${item.totalPrice.toStringAsFixed(2)}',
                style: textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF5D6067),
                  fontSize: 31 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1.05,
                ),
              ),
              SizedBox(width: 8 * scale),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.delete_outline,
                  size: 28 * scale,
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          SizedBox(height: 30 * scale),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _variantLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF778090),
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
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
          _MaterialQuantityButton(
            scale: scale,
            icon: Icons.remove,
            onTap: () => context.read<CartBloc>().add(
                  CartItemQuantityUpdateRequested(item.itemId, item.quantity - 1),
                ),
          ),
          Text(
            '${item.quantity}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: CupertinoColors.black,
              fontSize: 29 * scale,
              fontWeight: FontWeight.w400,
            ),
          ),
          _MaterialQuantityButton(
            scale: scale,
            icon: Icons.add,
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
    required this.onTap,
  });

  final double scale;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 46 * scale,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(icon, size: 27 * scale, color: const Color(0xFF005FC8)),
      ),
    );
  }
}

class _MaterialCartTotals extends StatelessWidget {
  const _MaterialCartTotals({
    required this.scale,
    required this.total,
    required this.currencyCode,
  });

  final double scale;
  final double total;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalStr = '\$${total.toStringAsFixed(2)}';

    return Column(
      children: <Widget>[
        _MaterialTotalRow(
          scale: scale,
          label: l10n.cartSubtotal,
          value: totalStr,
        ),
        SizedBox(height: 22 * scale),
        Divider(height: 1, thickness: scale, color: const Color(0xFFDADDE7)),
        SizedBox(height: 24 * scale),
        _MaterialTotalRow(
          scale: scale,
          label: l10n.cartTotal,
          value: totalStr,
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
        onPressed: () {
          final cart = context.read<CartBloc>().state.cart;
          if (cart == null) return;
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => CheckoutScreen(cart: cart)),
          );
        },
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
                          errorBuilder: (_, __, _) => const Icon(
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
